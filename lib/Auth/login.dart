import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/auth_service.dart';
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
    // Query 'Customers' collection
    final customerQuery = await _firestore.collection('Customers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (customerQuery.docs.isNotEmpty) return 'Customers';

    // Fallback to 'Vendors' collection if not found in 'Customers'
    final vendorQuery = await _firestore.collection('Vendors')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (vendorQuery.docs.isNotEmpty) return 'Vendors';

    return 'User not found';
  }

  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Display a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Authenticate user
        final authService = AuthService();
        UserCredential cred = await authService.signInwithEmailPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        // Dismiss loading indicator
        if (context.mounted) Navigator.of(context).pop();

        // Navigate user based on their type
        if (context.mounted) {
          String userId = cred.user!.uid;
          String userType = await getUserType(userId);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AuthGate(userType: userType)),
          );
        }
      } catch (e) {
        // Handle error scenario gracefully
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Error', style: TextStyle(color: Colors.red)),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK', style: TextStyle(color: Colors.blue)),
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0093E9), Color(0xFF80D0C7)], // Improved gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'CelebrEase',
                  style: GoogleFonts.merienda(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    const Text('Sign In', textAlign: TextAlign.center, style: TextStyle(fontSize: 26)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                        ),
                      ),
                    ),
                    _buildTextField('Email', emailController, false, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    }),
                    const SizedBox(height: 15),
                    _buildTextField('Password', passwordController, true, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Add forgot password functionality here
                        },
                        child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyButton(todo: 'Login', onTap: () => login(context)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Have No Account? ', style: TextStyle(color: Colors.black87)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/SignUp');
                          },
                          child: const Text('Sign Up', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildTextField(
      String hintText, TextEditingController controller, bool isObscure, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
      ),
    );
  }
}
