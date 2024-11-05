import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatefulWidget {
  final String userType;
  const AboutSection({super.key, required this.userType});

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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(widget.userType)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots(),
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
          return const Text('No data available');
        }

        Map<String, dynamic> userProfile =
            snapshot1.data!.docs.first.data() as Map<String, dynamic>;

        // Use null-aware operators and provide default values
        String about =
            userProfile['business description'] as String? ?? 'About';
            print('userProfile data: $userProfile');

        if (userProfile['userType'] == 'Vendors') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                textScaler: const TextScaler.linear(
                    1.2), // Corrected to `textScaleFactor`
                style: GoogleFonts.merienda(),
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Text(
                    about,
                    maxLines: isexpanded ? null : 3,
                    overflow: isexpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              InkWell(
                onTap: toggleTextExpansion,
                child: Text(
                  isexpanded ? 'less' : 'more',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Handle other user types or return an empty container
          return const SizedBox(
            height: 10,
          ); // Or any other placeholder widget
        }
      },
    );
  }
}
