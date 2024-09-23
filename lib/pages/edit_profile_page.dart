import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  final bool isFirstSetup;

  const EditProfile({super.key, required this.isFirstSetup, required Map initialData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController brandController;
  late TextEditingController locationController;
  late TextEditingController categoryController;
  late TextEditingController aboutController;
  late TextEditingController startTimeController;
  late TextEditingController closeTimeController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> serviceCategories = [];

  @override
  void initState() {
    super.initState();
    final profileData = Provider.of<ChangeManager>(context, listen: false).profileData;
    brandController = TextEditingController(text: profileData['brandName'] ?? '');
    locationController = TextEditingController(text: profileData['location'] ?? '');
    categoryController = TextEditingController(text: profileData['category'] ?? '');
    aboutController = TextEditingController(text: profileData['about'] ?? '');
    startTimeController = TextEditingController(text: profileData['startTime'] ?? '');
    closeTimeController = TextEditingController(text: profileData['endTime'] ?? '');
    
    getServiceCategories();
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
          locationController.text.isNotEmpty &&
          categoryController.text.isNotEmpty &&
          aboutController.text.isNotEmpty &&
          startTimeController.text.isNotEmpty &&
          closeTimeController.text.isNotEmpty;
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
              buildTextField(locationController, 'Location'),
              buildDropdownMenu(context),
              buildTextField(startTimeController, 'Open Time'),
              buildTextField(closeTimeController, 'Close Time'),
              buildTextField(aboutController, 'About', maxLines: 5),
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
                  if (locationController.text != profileData['location']) {
                    updatedData['location'] = locationController.text;
                  }
                  if (categoryController.text != profileData['category']) {
                    updatedData['category'] = categoryController.text;
                  }
                  if (aboutController.text != profileData['about']) {
                    updatedData['about'] = aboutController.text;
                  }
                  if (startTimeController.text != profileData['startTime']) {
                    updatedData['startTime'] = startTimeController.text;
                  }
                  if (closeTimeController.text != profileData['endTime']) {
                    updatedData['endTime'] = closeTimeController.text;
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

  Widget buildDropdownMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownMenu<String>(
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

  @override
  void dispose() {
    brandController.dispose();
    locationController.dispose();
    categoryController.dispose();
    aboutController.dispose();
    startTimeController.dispose();
    closeTimeController.dispose();
    super.dispose();
  }
}