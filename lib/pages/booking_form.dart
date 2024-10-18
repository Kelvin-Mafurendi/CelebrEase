import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/textfield.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:maroro/pages/vendor_calender.dart';
import 'package:provider/provider.dart';

class BookingForm extends StatefulWidget {
  final String package_id;
  const BookingForm({super.key, required this.package_id});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController numberOfGuestsController = TextEditingController();
  
  // Form state variables
  DateTime? selectedDate;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? selectedServiceType;
  String? _vendorId;
  
  // Lists and collections
  late List<String> serviceTypes = [];
  List<TimeSlot> _availableTimeSlots = [];
  List<TimeSlot> _selectedTimeSlots = [];

  // Constants for booking duration limits
  static const int MIN_BOOKING_HOURS = 1;
  static const int MAX_BOOKING_HOURS = 8;

  @override
  void initState() {
    super.initState();
    getServiceCategories();
    addressController.text = 'Vendor Location';
    _initializeVendorId();
  }

  Future<void> _initializeVendorId() async {
    final packageDoc = await FirebaseFirestore.instance
        .collection('Packages')
        .doc(widget.package_id)
        .get();

    if (packageDoc.exists) {
      setState(() {
        _vendorId = packageDoc.data()?['userId'];
      });
    }
  }

  Future<void> getServiceCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Services').get();
      setState(() {
        serviceTypes = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching service categories: $e');
    }
  }

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
      final selectedTime = selectedSlot.start.hour * 60 + selectedSlot.start.minute;
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
            'Booking duration must be between $MIN_BOOKING_HOURS and $MAX_BOOKING_HOURS hours'
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate() && _validateBookingDuration()) {
    try {
      final firstSlot = _selectedTimeSlots.first;
      final lastSlot = _selectedTimeSlots.last;
      
      Map<String, dynamic> data = {
        'package id': widget.package_id,
        'name': nameController.text,
        'event date': selectedDate,
        'start': _formatTimeOfDay(firstSlot.start),
        'end': _formatTimeOfDay(lastSlot.end),
        'selected_slots': _selectedTimeSlots.map((slot) => slot.toMap()).toList(),
        'country': countryValue,
        'state': stateValue,
        'city': cityValue,
        'address': addressController.text,
        'event': eventTypeController.text,
        'guests': numberOfGuestsController.text,
        'service type': selectedServiceType,
      };

      if (notesController.text.isNotEmpty) {
        data['extra notes'] = notesController.text;
      }

      bool success = await Provider.of<ChangeManager>(context, listen: false)
          .updateForm(data);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(success ? "Success" : "Error"),
            content: Text(success
                ? "Booking added to cart"
                : "Failed to add booking to cart"),
            actions: <Widget>[
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("An error occurred: ${e.toString()}"),
            actions: <Widget>[
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
                  subtitle: !canSelect && !isSelected ? 
                    Text(
                      'Must select consecutive slots',
                      style: TextStyle(color: Colors.red[300], fontSize: 12)
                    ) 
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

  

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, int maxlines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxlines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildLocationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectState(
        onCountryChanged: (value) {
          setState(() {
            countryValue = value;
          });
        },
        onStateChanged: (value) {
          setState(() {
            stateValue = value;
          });
        },
        onCityChanged: (value) {
          setState(() {
            cityValue = value;
          });
        },
      ),
    );
  }

  Widget buildServiceTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Service Type',
          border: OutlineInputBorder(),
        ),
        value: selectedServiceType,
        items: serviceTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedServiceType = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a service type';
          }
          return null;
        },
      ),
    );
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
      title: const Text('Booking Form'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField(nameController, 'Name'),
            buildDatePicker(),
            if (selectedDate != null) buildTimeSlotPicker(),
            buildLocationPicker(),
            buildTextField(addressController, 'Address'),
            buildTextField(eventTypeController, 'Event Type'),
            buildTextField(
              numberOfGuestsController, 
              'Number of Guests',
              keyboardType: TextInputType.number,
            ),
            buildServiceTypeDropdown(),
            buildNotesField(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit Booking'),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    notesController.dispose();
    eventTypeController.dispose();
    numberOfGuestsController.dispose();
    super.dispose();
  }
}
