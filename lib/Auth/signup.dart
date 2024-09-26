// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String? selectedStartTime;
  String? selectedCloseTime;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String userType = 'Customers';
  List<String> serviceCategories = [];
  Future<void> getServiceCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Services').get();
      setState(() {
        serviceCategories = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching service categories: $e');
    }
  }

  Future<void> register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authService = AuthService();
      try {
        // Check for unique fields
        if (await isFieldUnique('username', usernameController.text) &&
            await isFieldUnique('phone number', phoneNumberController.text)) {
          UserCredential cred = await authService.signUpwithEmailPassword(
              emailController.text, passwordController.text);

          // Create a new document in the 'Vendors' or 'Customers' collection
          Map<String, dynamic> userData = {
            'name': nameController.text,
            'surname': surnameController.text,
            'phone number': phoneNumberController.text,
            'username': usernameController.text,
            'location': '$cityValue, $stateValue, $countryValue',
            'email': emailController.text,
            'userId': cred.user!.uid,
          };

          // Add additional fields for vendors
          if (userType == 'Vendors') {
            userData.addAll({
              'business name': businessNameController.text,
              'business description':aboutController.text,
              'location': '$cityValue, $stateValue, $countryValue',
              'category': categoryController.text,
              'startTime': selectedStartTime,
              'endTime': selectedCloseTime,
              'address':addressController.text,
             
            });
          }

          Provider.of<ChangeManager>(context,listen: false).changeProfiledata(userData,userType); 
            setState(() {
              _formKey.currentState!.reset();
              emailController.clear();
              passwordController.clear();
              confirmPasswordController.clear();
              nameController.clear();
              surnameController.clear();
              usernameController.clear();
              phoneNumberController.clear();
              businessNameController.clear();
              //businessDescriptionController.clear();
              addressController.clear();
              aboutController.clear();
              categoryController.clear();
              selectedStartTime = null;
              selectedCloseTime = null;
              countryValue = null;
              stateValue = null;
              cityValue = null;
            });
          

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: backgroundColor,
              icon: const Icon(
                FluentSystemIcons.ic_fluent_checkmark_circle_regular,
                size: 100,
              ),
              title: Text(
                'Congratulations!\n You can now sign in.',
                style: GoogleFonts.lateef(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/log_in');
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('Username or phone number already in use'),
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
  }

  Future<bool> isFieldUnique(String field, String value) async {
    final QuerySnapshot result = await _firestore
        .collection(userType)
        .where(field, isEqualTo: value)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  dynamic image;

  getImage(context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (result != null) {
      setState(() {
        image = result.files.first.bytes;
      });
    }
  }

  @override
  void initState() {
    getServiceCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          floating: true,
          expandedHeight: 300,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                    accentColor,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all()),
                    child: Text(
                      'CelebrEase',
                      style: GoogleFonts.merienda(fontSize: 40),
                    )),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      userType = 'Customers';
                    });
                  },
                  child: Text(
                    'Customer',
                    style: GoogleFonts.lateef(
                      color: userType == 'Customers'
                          ? const Color.fromARGB(255, 214, 214, 214)
                          : Colors.black,
                      fontSize: userType == 'Customers' ? 25 : 20,
                    ),
                  ),
                ),
                const Text('| '),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      userType = 'Vendors';
                    });
                  },
                  child: Text(
                    'Vendor',
                    style: GoogleFonts.lateef(
                      color: userType == 'Vendors'
                          ? const Color.fromARGB(255, 214, 214, 214)
                          : Colors.black,
                      fontSize: userType == 'Vendors' ? 25 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text('Create a $userType Account',
                    style: const TextStyle(fontSize: 25)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Stack(children: [
                    AddProfileImage(),
                    
                  ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: surnameController,
                          decoration: const InputDecoration(
                            hintText: 'Surname',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your surname';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    initialCountryCode: 'ZA',
                    onChanged: (phone) {
                      phoneNumberController.text =
                          '${phone.countryCode}${phone.number}';
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ),
                buildLocationPicker(),
                if (userType == 'Vendors')
                  buildTextField(addressController, 'Enter Physical Address...',
                      maxLines: 5),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                if (userType == 'Vendors')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      controller: businessNameController,
                      decoration: const InputDecoration(
                        hintText: 'Business Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your business name';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (userType == 'Vendors')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
                    child: DropdownMenu<String>(
                      hintText: 'Select Business category',
                      width: 400,
                      menuHeight: 100,
                      initialSelection: categoryController.text.isNotEmpty
                          ? categoryController.text
                          : null,
                      onSelected: (String? value) {
                        setState(() {
                          categoryController.text = value ?? '';
                        });
                      },
                      dropdownMenuEntries:
                          serviceCategories.map((String category) {
                        return DropdownMenuEntry(
                            value: category, label: category);
                      }).toList(),
                    ),
                  ),
                
                
                if (userType == 'Vendors')
                  buildTextField(aboutController, 'Describe your Business',
                      maxLines: 5),
                const SizedBox(height: 20),
                
                
                if (userType == 'Vendors')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Start Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      readOnly: true, // To prevent manual input
                      controller:
                          TextEditingController(text: selectedStartTime),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          // Ensure leading zeros for hour and minute
                          String formattedTime =
                              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                          setState(() {
                            selectedStartTime = formattedTime;
                          });
                        }
                      },
                      validator: (value) {
                        if (selectedStartTime == null ||
                            selectedStartTime!.isEmpty) {
                          return 'Please select a start time';
                        }
                        return null;
                      },
                    ),
                  ),
                if (userType == 'Vendors')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Close Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      readOnly: true, // Prevent manual input
                      controller:
                          TextEditingController(text: selectedCloseTime),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          // Format hour and minute to always show two digits
                          String formattedTime =
                              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                          setState(() {
                            selectedCloseTime = formattedTime;
                          });
                        }
                      },
                      validator: (value) {
                        if (selectedCloseTime == null ||
                            selectedCloseTime!.isEmpty) {
                          return 'Please select a closing time';
                        }
                        return null;
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: MyButton(
                    todo: 'Register',
                    onTap: () => register(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
          ),
        )
      ],
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
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
}
