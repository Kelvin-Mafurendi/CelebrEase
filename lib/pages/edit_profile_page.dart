import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';

class EditProfile extends StatefulWidget {
  final bool isFirstSetup;

  const EditProfile({super.key, required this.isFirstSetup, required Map initialData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController brandController;
  late TextEditingController aboutController;
  String? selectedStartTime;
  String? selectedCloseTime;
  late TextEditingController categoryController;

  String? countryValue;
  String? stateValue;
  String? cityValue;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> serviceCategories = [];
  List<String> timeOptions = [];

  @override
  void initState() {
    super.initState();
    final profileData = Provider.of<ChangeManager>(context, listen: false).profileData;
    brandController = TextEditingController(text: profileData['brandName'] ?? '');
    aboutController = TextEditingController(text: profileData['about'] ?? '');
    selectedStartTime = profileData['startTime'] ?? '';
    selectedCloseTime = profileData['endTime'] ?? '';
    categoryController = TextEditingController(text: profileData['category'] ?? '');

    timeOptions = generateTimeOptions(); // Generate time options
    getServiceCategories();
  }

  List<String> generateTimeOptions() {
    List<String> options = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        options.add(time);
      }
    }
    return options;
  }

  Future<void> getServiceCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Services').get();
      setState(() {
        serviceCategories = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching service categories: $e');
    }
  }

  bool validateFields() {
    if (widget.isFirstSetup) {
      return brandController.text.isNotEmpty &&
          countryValue != null &&
          stateValue != null &&
          cityValue != null &&
          aboutController.text.isNotEmpty &&
          selectedStartTime != null &&
          selectedCloseTime != null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFirstSetup ? 'Set Up Profile' : 'Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AddProfileImage(),
              buildTextField(brandController, 'Brand Name'),
              buildLocationPicker(),
              buildDropdownMenu(context),
              buildTimeDropdown('Open Time', selectedStartTime, (value) {
                setState(() {
                  selectedStartTime = value;
                });
              }),
              buildTimeDropdown('Close Time', selectedCloseTime, (value) {
                setState(() {
                  selectedCloseTime = value;
                });
              }),
              buildTextField(aboutController, 'Describe your Business', maxLines: 5),
              const SizedBox(height: 20),
              MyButton(
                onTap: () {
                  if (!validateFields()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  Map<String, dynamic> updatedData = {};
                  final profileData = Provider.of<ChangeManager>(context, listen: false).profileData;

                  if (brandController.text != profileData['brandName']) {
                    updatedData['brandName'] = brandController.text;
                  }
                  if (countryValue != null && stateValue != null && cityValue != null) {
                    updatedData['location'] = '$cityValue, $stateValue, $countryValue';
                  }
                  if (aboutController.text != profileData['about']) {
                    updatedData['about'] = aboutController.text;
                  }
                  if (selectedStartTime != profileData['startTime']) {
                    updatedData['startTime'] = selectedStartTime;
                  }
                  if (selectedCloseTime != profileData['endTime']) {
                    updatedData['endTime'] = selectedCloseTime;
                  }

                  if (updatedData.isNotEmpty || widget.isFirstSetup) {
                    Provider.of<ChangeManager>(context, listen: false).changeProfiledata(updatedData);
                  }

                  Navigator.pop(context);
                },
                todo: widget.isFirstSetup ? 'Save Profile' : 'Save Changes',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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

  Widget buildDropdownMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownMenu<String>(
        width: 200,
        menuHeight:100,
        
        initialSelection: categoryController.text.isNotEmpty ? categoryController.text : null,
        onSelected: (String? value) {
          setState(() {
            categoryController.text = value ?? '';
          });
        },
        dropdownMenuEntries: serviceCategories.map((String category) {
          return DropdownMenuEntry(value: category, label: category);
        }).toList(),
      ),
    );
  }

  Widget buildTimeDropdown(String label, String? selectedTime, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<String>(
        value: selectedTime,
        hint: Text(label),
        isExpanded: true,
        items: timeOptions.map((time) {
          return DropdownMenuItem<String>(
            value: time,
            child: Text(time),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    brandController.dispose();
    aboutController.dispose();
    categoryController.dispose();
    super.dispose();
  }
}
