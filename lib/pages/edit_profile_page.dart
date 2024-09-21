// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required Map initialData});

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

  @override
  void initState() {
    super.initState();
    final profileData = Provider.of<ChangeManager>(context, listen: false).profileData;
    brandController = TextEditingController(text: profileData['brandName']);
    locationController = TextEditingController(text: profileData['location']);
    categoryController = TextEditingController(text: profileData['category']);
    aboutController = TextEditingController(text: profileData['about']);
    startTimeController = TextEditingController(text: profileData['startTime']);
    closeTimeController = TextEditingController(text: profileData['endTime']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: AddProfileImage(),
          ),
          buildTextField(brandController, 'Brand Name'),
          buildTextField(locationController, 'Location'),
          buildDropdownMenu(context),
          buildTextField(startTimeController, 'Open Time'),
          buildTextField(closeTimeController, 'Close Time'),
          buildTextField(aboutController, 'About', maxLines: 15),
          const SizedBox(height: 150),
          MyButton(
            onTap: () {
              Map<String, dynamic> updatedData = {};
              final profileData = Provider.of<ChangeManager>(context, listen: false).profileData;

             
              if (brandController.text != profileData['brandName'] && brandController.text != null) {
                updatedData['brandName'] = brandController.text;
              }
              if (locationController.text != profileData['location']&& locationController.text !=null) {
                updatedData['location'] = locationController.text;
              }
              if (categoryController.text != profileData['category']&& categoryController.text != null) {
                updatedData['category'] = categoryController.text;
              }
              if (aboutController.text != profileData['about']&& aboutController.text != null) {
                updatedData['about'] = aboutController.text;
              }
              if (startTimeController.text != profileData['startTime']&& startTimeController.text != null) {
                updatedData['startTime'] = startTimeController.text;
              }
              if (closeTimeController.text != profileData['endTime']&& closeTimeController.text != null) {
                updatedData['endTime'] = closeTimeController.text;
              }

              if (updatedData.isNotEmpty) {
                Provider.of<ChangeManager>(context, listen: false).changeProfiledata(updatedData);
              }

              Navigator.pop(context);
            },
            todo: 'Save Changes',
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: 1000,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDropdownMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: DropdownMenu(
                label: const Text('Category'),
                controller: categoryController,
                menuStyle: const MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromARGB(1, 1, 1, 1),
                  ),
                  maximumSize: WidgetStatePropertyAll(Size.fromHeight(100)),
                  //shape: WidgetStatePropertyAll(cir)),
                ),
                width: 500,
                initialSelection: categoryController.text,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Cakes', label: 'Cakes'),
                  DropdownMenuEntry(value: 'Venues', label: 'Venues'),
                  DropdownMenuEntry(value: 'Dressing', label: 'Dressing'),
                  DropdownMenuEntry(value: 'MC', label: 'MC'),
                  DropdownMenuEntry(value: 'Music', label: 'Music'),
                  DropdownMenuEntry(value: 'Food', label: 'Food'),
                  DropdownMenuEntry(value: 'Vendor', label: 'Vendor'),
                  DropdownMenuEntry(value: 'Decor', label: 'Decor'),
                  DropdownMenuEntry(
                      value: 'Event Planning', label: 'Event Planning'),
                  DropdownMenuEntry(value: 'Cosmetics', label: 'Cosmetics'),
                  DropdownMenuEntry(
                      value: 'Hair Dressing', label: 'Hair Dressing'),
                  DropdownMenuEntry(value: 'Photography', label: 'Photography'),
                ]),
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