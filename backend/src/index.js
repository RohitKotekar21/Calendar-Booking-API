const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const moment = require('moment');

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for bookings
const bookings = [];

// Validation middleware
const validateBooking = (req, res, next) => {
    const { userId, startTime, endTime } = req.body;
    
    if (!userId || !startTime || !endTime) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const start = moment(startTime);
    const end = moment(endTime);

    if (!start.isValid() || !end.isValid()) {
        return res.status(400).json({ error: 'Invalid date format' });
    }

    if (start.isAfter(end)) {
        return res.status(400).json({ error: 'Start time must be before end time' });
    }

    if (start.isBefore(moment())) {
        return res.status(400).json({ error: 'Cannot book in the past' });
    }

    next();
};

// Check for booking conflicts
const checkBookingConflicts = (req, res, next) => {
    const { startTime, endTime } = req.body;
    const newStart = moment(startTime);
    const newEnd = moment(endTime);

    const conflict = bookings.some(booking => {
        const existingStart = moment(booking.startTime);
        const existingEnd = moment(booking.endTime);
        
        return (newStart.isBetween(existingStart, existingEnd) ||
                newEnd.isBetween(existingStart, existingEnd) ||
                (newStart.isSameOrBefore(existingStart) && newEnd.isSameOrAfter(existingEnd)));
    });

    if (conflict) {
        return res.status(409).json({ error: 'Booking conflicts with existing booking' });
    }

    next();
};

// Routes
app.get('/bookings', (req, res) => {
    res.json(bookings);
});

app.get('/bookings/:bookingId', (req, res) => {
    const booking = bookings.find(b => b.id === req.params.bookingId);
    if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
    }
    res.json(booking);
});

app.post('/bookings', validateBooking, checkBookingConflicts, (req, res) => {
    const { userId, startTime, endTime } = req.body;
    const newBooking = {
        id: uuidv4(),
        userId,
        startTime,
        endTime,
        createdAt: new Date().toISOString()
    };
    
    bookings.push(newBooking);
    res.status(201).json(newBooking);
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}); 