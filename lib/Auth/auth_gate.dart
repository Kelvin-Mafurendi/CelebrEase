import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/pages/screen1.dart';

class AuthGate extends StatelessWidget {
  final String userType; // Expecting initial userType here
  AuthGate({super.key, required this.userType});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserType() async {
    String userId = _auth.currentUser!.uid;

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // If userType is valid (not empty or null), use it directly
          if (userType.isNotEmpty) {
            return Screen1(userType: userType);
          }

          // If userType is null/empty, fetch it using FutureBuilder
          return FutureBuilder<String>(
            future: getUserType(),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (userTypeSnapshot.hasData &&
                  userTypeSnapshot.data != 'User not found') {
                // Use the fetched userType from Firestore
                return Screen1(
                  userType: userTypeSnapshot.data!,
                );
              } else {
                // Handle if user type not found or other errors
                return const Text('User type not found');
              }
            },
          );
        } else {
          return const Home(); // User is not authenticated
        }
      },
    );
  }
}
