import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/textfield.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:provider/provider.dart';

class BookingForm extends StatefulWidget {
  final String package_id;
  const BookingForm({super.key, required this.package_id});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController numberOfGuestsController =
      TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? selectedServiceType;
  late List<String> serviceTypes = [];

  String formatTimeOfDay(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return '';
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> getServiceCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Services').get();
      setState(() {
        serviceTypes = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching service categories: $e');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    getServiceCategories();
    addressController.text = 'Vendor Location';
    super.initState();
  }

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
            buildTimePicker('Start Time', selectedStartTime,
                (time) => setState(() => selectedStartTime = time)),
            buildTimePicker('End Time', selectedEndTime,
                (time) => setState(() => selectedEndTime = time)),
            buildLocationPicker(),
            buildTextField(addressController, 'Physical Address', maxlines: 4),
            buildTextField(eventTypeController,
                'Event Type (e.g., Wedding, Birthday, Conference)'),
            buildTextField(numberOfGuestsController, 'Number of Guests',
                keyboardType: TextInputType.number),
            buildServiceTypeDropdown(),
            buildNotesField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Submit button pressed"); // Debug print
                if (_formKey.currentState!.validate()) {
                  print("Form is valid"); // Debug print
                  try {
                    Map<String, dynamic> data = {
                      'package id': widget.package_id,
                      'name': nameController.text,
                      'event date': selectedDate,
                      'start': formatTimeOfDay(selectedStartTime),
                      'end': formatTimeOfDay(selectedEndTime),
                      'country': countryValue,
                      'state': stateValue,
                      'city': cityValue,
                      'address': addressController.text,
                      'event': eventTypeController.text,
                      'guests': numberOfGuestsController.text,
                      'service type': selectedServiceType,
                    };
                    if (notesController.text != '') {
                      data['extra notes'] = notesController.text;
                    }

                    print("Calling updateForm"); // Debug print
                    bool success =
                        await Provider.of<ChangeManager>(context, listen: false)
                            .updateForm(data);

                    print("updateForm result: $success"); // Debug print

                    // Show AlertDialog instead of SnackBar
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
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (success) {
                                  Navigator.pop(
                                      context); // Go back to previous screen
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    print("Error caught: $e"); // Debug print
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("An error occurred: ${e.toString()}"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("OK"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  print("Form is not valid"); // Debug print
                }
              },
              child: const Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
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

  Widget buildTimePicker(
      String label, TimeOfDay? selectedTime, Function(TimeOfDay?) onChanged) {
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
