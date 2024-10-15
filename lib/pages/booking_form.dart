import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/modules/textfield.dart';
import 'package:intl/intl.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController numberOfGuestsController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? selectedServiceType;

  final List<String> serviceTypes = [
    'Venue Rental',
    'Catering',
    'Photography',
    'Entertainment',
    'Decoration',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Booking Form',
                textAlign: TextAlign.center,
                style: GoogleFonts.lateef(fontSize: 35),
              ),
            ),
            buildTextField(nameController, 'Full Name'),
            
            buildDatePicker(),
            buildTimePicker('Start Time', selectedStartTime, (time) => setState(() => selectedStartTime = time)),
            buildTimePicker('End Time', selectedEndTime, (time) => setState(() => selectedEndTime = time)),
            buildLocationPicker(),
            buildTextField(addressController, 'Physical Address',maxlines: 4),
            buildTextField(eventTypeController, 'Event Type (e.g., Wedding, Birthday, Conference)'),
            buildTextField(numberOfGuestsController, 'Number of Guests', keyboardType: TextInputType.number),
            buildServiceTypeDropdown(),
            buildNotesField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process the form
                  print('Form is valid');
                  // Here you would typically send this data to your backend or process it further
                }
              },
              child: const Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType,int maxlines = 1}) {
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

  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
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

  Widget buildTimePicker(String label, TimeOfDay? selectedTime, Function(TimeOfDay?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: selectedTime != null ? selectedTime.format(context) : '',
        ),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            onChanged(pickedTime);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
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
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    notesController.dispose();
    eventTypeController.dispose();
    numberOfGuestsController.dispose();
    super.dispose();
  }
}