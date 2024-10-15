import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/theme_notifier.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:provider/provider.dart'; // Ensure provider is imported

class Settings extends StatelessWidget {
  final String userType;
  const Settings({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final themeNotifier =
        Provider.of<ThemeNotifier>(context); // Access the theme notifier

    return Scaffold(
      appBar: AppBar(
          //title: const Text('Settings'),
          ),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          const Spacer(),
          Text(
            'Settings',
            textScaler: TextScaler.linear(2.7),
            style: GoogleFonts.lateef(fontWeight: FontWeight.bold),
          ),
          const Divider(
            thickness: 0.1,
          ),
          const SizedBox(height: 20),
          Text(
            'Preferences',
            textScaler: const TextScaler.linear(2),
            style: GoogleFonts.lateef(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dark mode',
                textScaler: const TextScaler.linear(1.5),
                style: GoogleFonts.lateef(),
              ),
              Switch(
                value: themeNotifier.themeMode ==
                    ThemeMode.dark, // Check current theme
                onChanged: (bool isDark) {
                  themeNotifier.setThemeMode(
                    isDark ? ThemeMode.dark : ThemeMode.light,
                  ); // Change theme mode
                },
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Account Settings',
            textScaler: const TextScaler.linear(2),
            style: GoogleFonts.lateef(),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    isFirstSetup: true,
                    initialData: const {},
                    userType:
                        userType, 
                  ),
                ),
              );
            },
            child: Text(
              'Edit Profile',
              textScaler: const TextScaler.linear(1.5),
              style: GoogleFonts.lateef(),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Change Password',
            textScaler: const TextScaler.linear(1.5),
            style: GoogleFonts.lateef(),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Privacy & Security',
            textScaler: const TextScaler.linear(2),
            style: GoogleFonts.lateef(),
          ),
        ],
      ),
    );
  }
}
