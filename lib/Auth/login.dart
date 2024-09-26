import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/mybutton.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserType(String userId) async {
    // Check if the user exists in the 'Customers' collection
    var customerDocument =
        await _firestore.collection('Customers').doc(userId).get();
    if (customerDocument.exists) {
      return 'Customers';
    }

    // If not found in 'Customers', check the 'Vendors' collection
    var vendorDocument =
        await _firestore.collection('Vendors').doc(userId).get();
    if (vendorDocument.exists) {
      return 'Vendors';
    }

    // Return some default value if not found in either collection
    return 'User not found';
  }

  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create instance of auth
      final authService = AuthService();

      try {
        // Try to sign in
        UserCredential cred = await authService.signInwithEmailPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        // Remove loading indicator
        if (context.mounted) Navigator.of(context).pop();

        // Navigate to first page, replacing the login page
        if (context.mounted){
          String userId = cred.user!.uid.toString();
          String userType = await getUserType(userId);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AuthGate( userType:userType)),
            (route) => false,
          );
        }
      } catch (e) {
        // Remove loading indicator
        if (context.mounted) Navigator.of(context).pop();

        // Show error dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
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
                      colors: [primaryColor, secondaryColor, accentColor])),
            ),
            title: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all()),
                child: Text(
                  'CelebrEase',
                  style: GoogleFonts.merienda(fontSize: 30),
                )),
          ),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text('Sign In', style: TextStyle(fontSize: 25)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: CachedNetworkImageProvider(
                        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Add forgot password functionality here
                        },
                        child: const Text('Forgot Password?'),
                      )
                    ],
                  ),
                ),
                MyButton(todo: 'Login', onTap: () => login(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Have No Account?',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/SignUp');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
          ),
        ),
      ],
    );
  }
}
