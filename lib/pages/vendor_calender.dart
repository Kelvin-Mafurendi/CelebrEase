import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  
  // Add animation controller
  late AnimationController _controller;
  bool _isLoading = true;

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
  Future<List<TimeSlot>> _generateDefaultTimeSlots() async {
    List<TimeSlot> slots = [];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);

    try {
      // Fetch vendor data from Firebase
      final vendorId = _auth.currentUser!.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Vendors')
          .where('userId',isEqualTo: vendorId).limit(1)
          .get();
        var vendorSnapshot = snapshot.docs.first.data() as Map;
        String startTimeString = vendorSnapshot['startTime'];
        String endTimeString = vendorSnapshot['endTime'];

        // If both start and end times are available, parse them
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

  // Keep existing _loadAvailability, _saveAvailability, and _generateDefaultTimeSlots methods...

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    DateTime normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    
    setState(() {
      _isLoading = true;
    });

    List<TimeSlot> defaultTimeSlots = _availabilityMap[normalizedDate] ?? await _generateDefaultTimeSlots();

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDaySlots = defaultTimeSlots;
      _isLoading = false;
    });

    _showEnhancedTimeSlotsDialog();
  }

  void _showEnhancedTimeSlotsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Column(
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(_selectedDay!),
                style: GoogleFonts.lateef(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(thickness: 2),
            ],
          ).animate().fadeIn(duration: 400.ms),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedDaySlots.length,
              itemBuilder: (context, index) {
                final slot = _selectedDaySlots[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: ListTile(
                    leading: Icon(
                      _getStatusIcon(slot.status),
                      color: _getStatusColor(slot.status),
                    ),
                    title: Text(
                      '${slot.start.format(context)} - ${slot.end.format(context)}',
                      style: GoogleFonts.lateef(fontSize: 18),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      child: DropdownButton<SlotStatus>(
                        value: slot.status,
                        underline: const SizedBox(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: SlotStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              _getStatusText(status),
                              style: GoogleFonts.lateef(fontSize: 16),
                            ),
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
                    ),
                  ),
                ).animate().fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: index * 100),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lateef(fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveAvailability(_selectedDay!, _selectedDaySlots);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.lateef(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Icons.check_circle_outline;
      case SlotStatus.unavailable:
        return Icons.block;
      case SlotStatus.booked:
        return Icons.event_busy;
    }
  }

  Color _getStatusColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Colors.green;
      case SlotStatus.unavailable:
        return Colors.grey;
      case SlotStatus.booked:
        return Colors.red;
    }
  }

  String _getStatusText(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return 'Available';
      case SlotStatus.unavailable:
        return 'Unavailable';
      case SlotStatus.booked:
        return 'Booked';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Manage Your Schedule',
            style: GoogleFonts.lateef(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: accentColor.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.lateef(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, size: 28),
                    rightChevronIcon: const Icon(Icons.chevron_right, size: 28),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.lateef(fontSize: 16, fontWeight: FontWeight.bold),
                    weekendStyle: GoogleFonts.lateef(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.tips_and_updates, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Tap any date to manage your availability',
                    style: GoogleFonts.lateef(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          ],
        ),
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

enum SlotStatus { available, unavailable, booked }
