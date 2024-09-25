// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
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

  Future<void> register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authService = AuthService();
      try {
        // Check for unique fields
        if (await isFieldUnique('username', usernameController.text) &&
            await isFieldUnique('phone number', phoneNumberController.text)) {
          UserCredential cred = await authService.signUpwithEmailPassword(
              emailController.text, passwordController.text);
          await _firestore.collection('buyers').doc(cred.user!.uid).set({
            'name': nameController.text,
            'surname': surnameController.text,
            'phone number': phoneNumberController.text,
            'username': usernameController.text,
            'email': emailController.text,
            'buyer id': cred.user!.uid,
          }).whenComplete(() {
            setState(() {
              _formKey.currentState!.reset();
              emailController.clear();
              passwordController.clear();
              confirmPasswordController.clear();
              nameController.clear();
              surnameController.clear();
              usernameController.clear();
              phoneNumberController.clear();
            });
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
                      'Congratualations!\n You can now sign in.',
                      style: GoogleFonts.lateef(),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/log_in');
                          },
                          child: const Text('Sign In'))
                    ],
                  ));
        } else {
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    title: Text('Username or phone number already in use'),
                  ));
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    }
  }

  Future<bool> isFieldUnique(String field, String value) async {
    final QuerySnapshot result = await _firestore
        .collection('buyers')
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
      //String imagePath = result.files.first.path!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text('Create an Account', style: TextStyle(fontSize: 25)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: image != null
                          ? MemoryImage(image)
                          : const NetworkImage(
                              'https://commons.wikimedia.org/wiki/File:Profile_avatar_placeholder_large.png'),
                    ),
                     Positioned(right: 0,bottom: 0,child: IconButton(onPressed:()=>getImage(context) ,icon:const Icon(FluentSystemIcons.ic_fluent_camera_add_regular),),)
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
                MyButton(
                  todo: 'Sign Up ',
                  onTap: () => register(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Have an Account?'),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/log_in');
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
