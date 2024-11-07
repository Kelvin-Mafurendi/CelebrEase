import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfile extends StatefulWidget {
  final bool isFirstSetup;
  final String userType;

  const EditProfile({
    super.key,
    required this.isFirstSetup,
    required this.userType,
    required Map initialData,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController brandController;
  late TextEditingController aboutController;
  late TextEditingController categoryController;
  late TextEditingController addressController;
  String? selectedStartTime;
  String? selectedCloseTime;
  String? countryValue;
  String? stateValue;
  String? cityValue;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> serviceCategories = [];

  @override
  void initState() {
    super.initState();
    initializeControllers();
    getServiceCategories();
  }

  Future<void> initializeControllers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await _firestore
          .collection(widget.userType)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      final data = docSnapshot.docs.first.data();
      setState(() {
        nameController = TextEditingController(text: data['name'] ?? '');
        surnameController = TextEditingController(text: data['surname'] ?? '');
        emailController = TextEditingController(text: data['email'] ?? '');
        phoneNumberController =
            TextEditingController(text: data['phone number'] ?? '');
        brandController =
            TextEditingController(text: data['business name'] ?? '');
        aboutController =
            TextEditingController(text: data['business description'] ?? '');
        categoryController =
            TextEditingController(text: data['category'] ?? '');
        addressController = TextEditingController(text: data['address'] ?? '');
        selectedStartTime = data['startTime'];
        selectedCloseTime = data['endTime'];

        String? location = data['location'];
        List<String> locationParts = location!.split(', ');
        if (locationParts.length == 3) {
          cityValue = locationParts[0];
          stateValue = locationParts[1];
          countryValue = locationParts[2];
        }
            });
    }
  }

  Future<void> getServiceCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Services').get();
      setState(() {
        serviceCategories = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching service categories: $e');
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AddImage(
                  dataType: 'profile',
                  fieldName: 'profilePic',
                ),
                buildTextField(nameController, 'Name'),
                buildTextField(surnameController, 'Surname'),
                buildEmailField(),
                buildPhoneField(),
                buildLocationPicker(),
                if (widget.userType == 'Vendors') ...[
                  buildTextField(brandController, 'Business Name'),
                  buildTextField(addressController, 'Business Address'),
                  buildCategoryDropdown(),
                  buildTextField(aboutController, 'About Business',
                      maxLines: 5),
                  buildTimeField('Start Time', selectedStartTime,
                      (time) => setState(() => selectedStartTime = time)),
                  buildTimeField('End Time', selectedCloseTime,
                      (time) => setState(() => selectedCloseTime = time)),
                ],
                const SizedBox(height: 20),
                MyButton(
                  onTap: () => updateProfile(context),
                  todo: 'Save Changes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IntlPhoneField(
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
        initialCountryCode: 'ZA',
        controller: phoneNumberController,
      ),
    );
  }

  Widget buildLocationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
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

  Widget buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value:
            categoryController.text.isNotEmpty ? categoryController.text : null,
        decoration: const InputDecoration(
          labelText: 'Business Category',
          border: OutlineInputBorder(),
        ),
        items: serviceCategories.map((category) {
          return DropdownMenuItem(value: category, child: Text(category));
        }).toList(),
        onChanged: (value) =>
            setState(() => categoryController.text = value ?? ''),
      ),
    );
  }

  Widget buildTimeField(
      String label, String? selectedTime, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        controller: TextEditingController(text: selectedTime),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            String formattedTime =
                '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
            onChanged(formattedTime);
          }
        },
      ),
    );
  }

  void updateProfile(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String user = auth.currentUser!.uid;
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedData = {};

      void updateIfChanged(String key, String value, String? originalValue) {
        if (value.isNotEmpty && value != originalValue) {
          updatedData[key] = value;
        }
      }

      final profileData =
          Provider.of<ChangeManager>(context, listen: false).profileData;

      updateIfChanged('name', nameController.text, profileData['name']);
      updateIfChanged(
          'surname', surnameController.text, profileData['surname']);
      updateIfChanged('email', emailController.text, profileData['email']);
      updateIfChanged('phone number', phoneNumberController.text,
          profileData['phone number']);

      if (countryValue != null && stateValue != null && cityValue != null) {
        String newLocation = '$cityValue, $stateValue, $countryValue';
        if (newLocation != profileData['location']) {
          updatedData['location'] = newLocation;
        }
      }

      if (widget.userType == 'Vendors') {
        updateIfChanged('business name', brandController.text,
            profileData['business name']);
        updateIfChanged('business description', aboutController.text,
            profileData['business description']);
        updateIfChanged(
            'category', categoryController.text, profileData['category']);
        updateIfChanged(
            'address', addressController.text, profileData['address']);
        updateIfChanged(
            'startTime', selectedStartTime!, profileData['startTime']);
        updateIfChanged('endTime', selectedCloseTime!, profileData['endTime']);
      }

      if (updatedData.isNotEmpty) {
        Provider.of<ChangeManager>(context, listen: false).handleData(
          newData: updatedData,
          dataType: 'profile',
          collection: widget.userType,
          operation: OperationType.update,
          documentId: user,
          fileFields: {'profilePic':'Profile Images'}
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes were made')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    brandController.dispose();
    aboutController.dispose();
    categoryController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
