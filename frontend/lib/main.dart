import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BookingPage(),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:3001/bookings'));
      if (response.statusCode == 200) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBooking() async {
    if (_selectedDay == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 'user-123', // In a real app, this would come from authentication
          'startTime': startDateTime.toUtc().toIso8601String(),
          'endTime': endDateTime.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully')),
        );
        _fetchBookings();
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Booking'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _startTime = time);
                        }
                      },
                      child: Text(_startTime == null
                          ? 'Select Start Time'
                          : _startTime!.format(context)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _endTime = time);
                        }
                      },
                      child: Text(_endTime == null
                          ? 'Select End Time'
                          : _endTime!.format(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createBooking,
                  child: const Text('Create Booking'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final start = DateTime.parse(booking['startTime']);
                      final end = DateTime.parse(booking['endTime']);
                      return ListTile(
                        title: Text('Booking ${booking['id']}'),
                        subtitle: Text(
                          '${DateFormat('MMM d, y').add_jm().format(start)} - '
                          '${DateFormat('MMM d, y').add_jm().format(end)}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 