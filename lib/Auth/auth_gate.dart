import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/pages/screen1.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const Screen1();
        } else {
          return const Home();
        }
      },
    );
  }
}
