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
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    // Variables for theme modes
    ThemeMode currentThemeMode = themeNotifier.themeMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 242, 255, 231),
            Color.fromARGB(255, 32, 32, 32),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.transparent
            : Theme.of(context).colorScheme.surface,
        //appBar: AppBar(),
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
            StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection(userType)
                    .where('userId', isEqualTo: userId)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.docs.isEmpty) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            accentColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        );
                      },
                      child: Text(
                        'CelebrEaser',
                        style: GoogleFonts.merienda(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  // Assuming there is only one document returned (limit(1))
                  Map<String, dynamic> userProfile =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  String brandName =
                      userProfile['business name'] as String? ?? 'Brand Name';

                  //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(
                            isFirstSetup: brandName.isEmpty,
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
                  );
                }),
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
      ),
    );
  }
}
