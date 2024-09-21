import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isexpanded = false;
  void toggleTextExpansion() {
    setState(() {
      isexpanded = !isexpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('User Profiles').doc(userId).snapshots(),
      builder: (context, snapshot1) {
        if (snapshot1.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot1.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (!snapshot1.hasData || snapshot1.data == null) {
          //print('No data available');
          return const Text('No data available');
        }

        if (!snapshot1.data!.exists) {
          //print('Document does not exist');
          return const Text('Profile not found');
        }
        var userProfile = snapshot1.data!.data() as Map<String, dynamic>?;
        // Use null-aware operators and provide default values
        String about = userProfile?['about'] as String? ?? 'About';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              textScaler: TextScaler.linear(1.2),
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Text(
                  about,
                  maxLines: (isexpanded == false) ? 3 : null,
                  overflow: (isexpanded == false)
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ),
            InkWell(
              onTap: toggleTextExpansion,
              child: Text(
                (isexpanded == false) ? 'more' : 'less',
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
