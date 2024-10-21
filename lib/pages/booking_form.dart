import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/form_field_maps.dart';
//import 'package:maroro/pages/vendor_calender.dart';
import 'package:provider/provider.dart';

class BookingForm extends StatefulWidget {
  final String package_id;

  const BookingForm({
    Key? key,
    required this.package_id,
  }) : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  String? _selectedService;
  Map<String, dynamic> _serviceData = {};
  List<TimeSlot> _availableTimeSlots = [];
  List<TimeSlot> _selectedTimeSlots = [];
  bool _isLoading = false;
  String? _vendorId;
  String? _serviceType;
  DateTime? selectedDate;
  Timer? _debounce;

  // Constants for booking duration limits
  static const int MIN_BOOKING_HOURS = 1;
  static const int MAX_BOOKING_HOURS = 8;


  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController numberOfGuestsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    //getServiceCategories();
    addressController.text = 'Vendor Location';
    _initializeVendorId(); //and load initial data
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    nameController.dispose();
    addressController.dispose();
    notesController.dispose();
    eventTypeController.dispose();
    numberOfGuestsController.dispose();
    super.dispose();
  }

  Future<void> _initializeVendorId() async {
    try {
      final packageDoc = await FirebaseFirestore.instance
          .collection('Packages')
          .doc(widget.package_id)
          .get();

      if (packageDoc.exists && mounted) {
        setState(() {
          _vendorId = packageDoc.data()?['userId'];
          _serviceType = packageDoc.data()?['serviceType'];
          _selectedService = _serviceType;
        });
      }
    } catch (e) {
      print('Error initializing vendor ID: $e');
    }
  }

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTimeSlots();
    }
  }*/

  Future<void> _loadAvailableTimeSlots(DateTime date) async {
    if (_vendorId == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final doc = await FirebaseFirestore.instance
        .collection('vendor_availability')
        .doc(_vendorId)
        .collection('dates')
        .doc(dateStr)
        .get();

    List<TimeSlot> slots;
    if (doc.exists) {
      slots = (doc.data()?['slots'] as List?)
              ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
              .where((slot) => slot.status == SlotStatus.available)
              .toList() ??
          await _generateDefaultTimeSlots();
    } else {
      slots = await _generateDefaultTimeSlots();
    }

    setState(() {
      _availableTimeSlots = slots;
      _selectedTimeSlots.clear(); // Reset selections when date changes
    });
  }

  Future<List<TimeSlot>> _generateDefaultTimeSlots() async {
    List<TimeSlot> slots = [];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);

    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(_vendorId)
          .get();

      if (vendorSnapshot.exists) {
        String? startTimeString = vendorSnapshot['startTime'];
        String? endTimeString = vendorSnapshot['endTime'];

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

  bool _canSelectSlot(TimeSlot slot, int index) {
    if (_selectedTimeSlots.isEmpty) return true;

    final slotTime = slot.start.hour * 60 + slot.start.minute;

    for (var selectedSlot in _selectedTimeSlots) {
      final selectedTime =
          selectedSlot.start.hour * 60 + selectedSlot.start.minute;
      final timeDiff = (slotTime - selectedTime).abs();

      if (timeDiff == 60) return true;
    }

    return false;
  }

  String _getSelectedTimeRange() {
    if (_selectedTimeSlots.isEmpty) return '';

    final firstSlot = _selectedTimeSlots.first;
    final lastSlot = _selectedTimeSlots.last;

    return '${firstSlot.start.format(context)} - ${lastSlot.end.format(context)}';
  }

  bool _validateBookingDuration() {
    if (_selectedTimeSlots.isEmpty) return false;

    int totalHours = _selectedTimeSlots.length;
    if (totalHours < MIN_BOOKING_HOURS || totalHours > MAX_BOOKING_HOURS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking duration must be between $MIN_BOOKING_HOURS and $MAX_BOOKING_HOURS hours'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // UI Building Methods
  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
              : '',
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null && pickedDate != selectedDate) {
            setState(() {
              selectedDate = pickedDate;
            });
            await _loadAvailableTimeSlots(pickedDate);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget buildTimeSlotPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Time Slots (Select multiple slots for longer bookings)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimum booking: $MIN_BOOKING_HOURS hour(s), Maximum: $MAX_BOOKING_HOURS hours',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: _availableTimeSlots.length,
              itemBuilder: (context, index) {
                final slot = _availableTimeSlots[index];
                final isSelected = _selectedTimeSlots.contains(slot);
                final timeString =
                    '${_formatTimeOfDay(slot.start)} - ${_formatTimeOfDay(slot.end)}';
                final canSelect = _canSelectSlot(slot, index);

                return CheckboxListTile(
                  title: Text(timeString),
                  value: isSelected,
                  enabled: slot.status == SlotStatus.available && canSelect,
                  subtitle: !canSelect && !isSelected
                      ? Text('Must select consecutive slots',
                          style:
                              TextStyle(color: Colors.red[300], fontSize: 12))
                      : null,
                  onChanged: (bool? value) {
                    if (value != null && canSelect) {
                      setState(() {
                        if (value) {
                          _selectedTimeSlots.add(slot);
                        } else {
                          _selectedTimeSlots.remove(slot);
                        }
                        _selectedTimeSlots.sort((a, b) =>
                            (a.start.hour * 60 + a.start.minute)
                                .compareTo(b.start.hour * 60 + b.start.minute));
                      });
                    }
                  },
                );
              },
            ),
          ),
          if (_selectedTimeSlots.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Selected Time Range: ${_getFormattedTimeRange()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Updated helper method for 24-hour format
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

// If you need to parse this format back to TimeOfDay, you can add this helper
  TimeOfDay parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

// For displaying the selected time range
  String _getFormattedTimeRange() {
    if (_selectedTimeSlots.isEmpty) return '';
    final startTime = _selectedTimeSlots.first.start;
    final endTime = _selectedTimeSlots.last.end;
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  Widget buildNotesField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: notesController,
        decoration: const InputDecoration(
          labelText: 'Additional Notes',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Form"),
      ),
      body: _selectedService == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildDatePicker(),
                    if (selectedDate != null) buildTimeSlotPicker(),
                    if (_selectedService != null) ..._buildCustomFields(),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit Booking'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Function to build dynamic custom fields based on the selected service
  List<Widget> _buildCustomFields() {
    if (_selectedService == null ||
        !serviceFields.containsKey(_selectedService)) {
      return [];
    }

    return serviceFields[_selectedService]?.map((field) {
          // Create a controller if it doesn't exist
          if (!_controllers.containsKey(field['name'])) {
            _controllers[field['name']] = TextEditingController(
                text: _serviceData[field['name']]?.toString() ?? '');
          }

          switch (field['type']) {
            case 'date':
              return _buildDateField(field);
            case 'number':
              return _buildNumberField(field);
            case 'text':
              return _buildTextField(field);
            case 'multiline':
              return _buildMultilineTextField(field);
            case 'select':
              return _buildDropdownField(field);
            case 'multiselect':
              return _buildMultiselectField(field);
            default:
              return SizedBox.shrink();
          }
        }).toList() ??
        [];
  }

// Add this map to your state class
  final Map<String, TextEditingController> _controllers = {};

  Widget _buildTextField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr, // Explicitly set text direction
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = int.tryParse(value) ?? 0;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMultilineTextField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        //textDirection: ,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _serviceData[field['name']] ?? '',
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null) {
            setState(() {
              // Save the formatted date as a string
              _serviceData[field['name']] =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        items: (field['options'] as List)
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMultiselectField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field['label']),
          ...(field['options'] as List).map((option) {
            return CheckboxListTile(
              title: Text(option.toString()),
              value: _serviceData[field['name']]?.contains(option) ?? false,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _serviceData[field['name']] ??= [];
                    (_serviceData[field['name']] as List).add(option);
                  } else {
                    (_serviceData[field['name']] as List).remove(option);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // Submit form logic
  Future _submitForm() async {
    if (_formKey.currentState!.validate() && _validateBookingDuration()) {
      try {
        final firstSlot = _selectedTimeSlots.first;
        final lastSlot = _selectedTimeSlots.last;

        // Basic booking data [1]
        Map<String, dynamic> data = {
          'package id': widget.package_id,
          'name': nameController.text,
          'event date': selectedDate,
          'start': _formatTimeOfDay(firstSlot.start),
          'end': _formatTimeOfDay(lastSlot.end),
          'selected_slots':
              _selectedTimeSlots.map((slot) => slot.toMap()).toList(),
          'address': addressController.text,
          'event': eventTypeController.text,
          'guests': numberOfGuestsController.text,
        };

        // Add extra notes if provided [2]
        if (notesController.text.isNotEmpty) {
          data['extra notes'] = notesController.text;
        }

        // Add data from _serviceData to the booking data
        data.addAll(_serviceData);

        // Update form data using state management [2]
        bool success = await Provider.of<ChangeManager>(context, listen: false)
            .updateForm(data);

        // Show result dialog [2, 3]
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(success ? "Success" : "Error"),
              content: Text(success
                  ? "Booking added to cart"
                  : "Failed to add booking to cart"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Show error dialog [3]
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text("An error occurred: ${e.toString()}"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
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
