# Calendar Booking Application

A full-stack calendar booking application built with Flutter and Node.js.

## Features

- View available dates in a calendar
- Book time slots for meetings
- View all existing bookings
- Conflict detection for overlapping bookings
- Input validation for dates and times

## Prerequisites

- Node.js (v14 or higher)
- Flutter SDK
- npm or yarn package manager

## Project Structure

```
.
├── backend/           # Node.js backend
│   ├── src/
│   │   └── index.js   # Main server file
│   └── package.json   # Backend dependencies
└── frontend/          # Flutter frontend
    ├── lib/
    │   └── main.dart  # Main Flutter application
    └── pubspec.yaml   # Flutter dependencies
```

## Setup Instructions

###b Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   npm run dev
   ```

The backend server will run on http://localhost:3000

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the Flutter application:
   ```bash
   flutter run
   ```

## API Endpoints

### GET /bookings
Retrieve all bookings

### GET /bookings/:bookingId
Retrieve a specific booking by ID

### POST /bookings
Create a new booking

Request body:
```json
{
    "userId": "user-123",
    "startTime": "2025-03-01T10:00:00Z",
    "endTime": "2025-03-01T11:00:00Z"
}
```

## Error Handling

The API provides clear error messages for:
- Invalid date formats
- Missing required fields
- Booking conflicts
- Past date bookings
- Invalid time ranges

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request 