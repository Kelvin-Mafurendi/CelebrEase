import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/Provider/theme_notifier.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  final String userType;
  const Settings({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final profileData =
        Provider.of<ChangeManager>(context, listen: false).profileData;

    // Variables for theme modes
    ThemeMode currentThemeMode = themeNotifier.themeMode;

    return Scaffold(
      appBar: AppBar(),
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
          const Divider(thickness: 0.1),
          const SizedBox(height: 20),
          Text(
            'Preferences',
            textScaler: const TextScaler.linear(2),
            style: GoogleFonts.lateef(),
          ),
          Column(
            children: [
              RadioListTile<ThemeMode>(
                title: Text('System Theme',
                    textScaler: const TextScaler.linear(1.5),
                    style: GoogleFonts.lateef()),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? mode) async {
                  if (mode != null) {
                    await themeNotifier.setThemeMode(mode);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text('Light Mode',
                    textScaler: const TextScaler.linear(1.5),
                    style: GoogleFonts.lateef()),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? mode) async {
                  if (mode != null) {
                    await themeNotifier.setThemeMode(mode);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text('Dark Mode',
                    textScaler: const TextScaler.linear(1.5),
                    style: GoogleFonts.lateef()),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? mode) async {
                  if (mode != null) {
                    await themeNotifier.setThemeMode(mode);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Account Settings',
            textScaler: const TextScaler.linear(2),
            style: GoogleFonts.lateef(),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    isFirstSetup: false,
                    userType: userType,
                    initialData: const {},
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
          SizedBox(height: 10),
          Text(
            'Change Password',
            textScaler: const TextScaler.linear(1.5),
            style: GoogleFonts.lateef(),
          ),
          SizedBox(height: 20),
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
