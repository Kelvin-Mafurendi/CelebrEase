import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class VendorCalendarManager extends StatefulWidget {
  const VendorCalendarManager({super.key});

  @override
  State<VendorCalendarManager> createState() => _VendorCalendarManagerState();
}

class _VendorCalendarManagerState extends State<VendorCalendarManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeSlot>> _availabilityMap = {};
  List<TimeSlot> _selectedDaySlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final vendorId = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('vendor_availability')
          .doc(vendorId)
          .collection('dates')
          .get();

      Map<DateTime, List<TimeSlot>> newAvailabilityMap = {};
      for (var doc in snapshot.docs) {
        final date = DateTime.parse(doc.id);
        final slots = (doc.data()['slots'] as List)
            .map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
            .toList();
        newAvailabilityMap[DateTime(date.year, date.month, date.day)] = slots;
      }

      setState(() {
        _availabilityMap = newAvailabilityMap;
      });
    } catch (e) {
      print('Error loading availability: $e');
    }
  }

  Future<void> _saveAvailability(DateTime date, List<TimeSlot> slots) async {
    try {
      final vendorId = _auth.currentUser!.uid;
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      // Update Firestore
      await _firestore
          .collection('vendor_availability')
          .doc(vendorId)
          .collection('dates')
          .doc(dateStr)
          .set({
        'slots': slots.map((slot) => slot.toMap()).toList(),
      });

      // Update local state
      setState(() {
        _availabilityMap[DateTime(date.year, date.month, date.day)] = slots;
        _selectedDaySlots = slots;
      });
    } catch (e) {
      print('Error saving availability: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save availability: ${e.toString()}')),
      );
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
  // Normalize the date to avoid time component issues
  DateTime normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

  // Check if time slots exist or generate them asynchronously
  List<TimeSlot> defaultTimeSlots = _availabilityMap[normalizedDate] ?? await _generateDefaultTimeSlots();

  setState(() {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _selectedDaySlots = defaultTimeSlots;
  });

  _showTimeSlotsDialog();
}


  Future<List<TimeSlot>> _generateDefaultTimeSlots() async {
    
    List<TimeSlot> slots = [];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
    
    try {
      // Fetch vendor data from Firebase
      final vendorId = _auth.currentUser!.uid;
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(vendorId)
          .get();

      if (vendorSnapshot.exists) {
        // Retrieve start and end time strings
        String? startTimeString = vendorSnapshot['startTime'];
        String? endTimeString = vendorSnapshot['endTime'];

        // If both start and end times are available, parse them
        if (startTimeString != null && endTimeString != null) {
          List<String> startParts = startTimeString.split(':');
          List<String> endParts = endTimeString.split(':');

          startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );

          endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        }
      }
    } catch (e) {
      // Print error and fall back to default times if any issues occur
      print('Error fetching vendor times: $e');
    }

    for (int hour = startTime.hour; hour < endTime.hour; hour++) {
      slots.add(
        TimeSlot(
          start: TimeOfDay(hour: hour, minute: 0),
          end: TimeOfDay(hour: hour + 1, minute: 0),
          status: SlotStatus.available,
        ),
      );
    }
    return slots;
  }

  void _showTimeSlotsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(DateFormat('yyyy-MM-dd').format(_selectedDay!)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedDaySlots.length,
              itemBuilder: (context, index) {
                final slot = _selectedDaySlots[index];
                return ListTile(
                  title: Text('${slot.start.format(context)} - ${slot.end.format(context)}'),
                  trailing: DropdownButton<SlotStatus>(
                    value: slot.status,
                    items: SlotStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        setDialogState(() {
                          _selectedDaySlots[index] = slot.copyWith(status: newStatus);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _saveAvailability(_selectedDay!, _selectedDaySlots);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Calendar',
          textScaler: TextScaler.linear(1.5),
          style: GoogleFonts.lateef(),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tap on any date to manage time slots',
              style: GoogleFonts.lateef(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final SlotStatus status;

  TimeSlot({
    required this.start,
    required this.end,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'status': status.toString(),
    };
  }

  static TimeSlot fromMap(Map<String, dynamic> map) {
    final startParts = map['start'].split(':');
    final endParts = map['end'].split(':');
    return TimeSlot(
      start: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      end: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      status: SlotStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
    );
  }

  TimeSlot copyWith({
    TimeOfDay? start,
    TimeOfDay? end,
    SlotStatus? status,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }
}

enum SlotStatus {
  available,
  unavailable,
  booked
}