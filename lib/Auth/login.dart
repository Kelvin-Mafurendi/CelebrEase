import 'package:flutter/material.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:maroro/modules/textfield.dart';

class LogIn extends StatelessWidget {
  LogIn({super.key});

  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  Future<void> login(BuildContext context) async {
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
      await authService.signInwithEmailPassword(
        emailcontroller.text.trim(),
        passwordcontroller.text.trim(),
      );

      // Remove loading indicator
      if (context.mounted) Navigator.of(context).pop();

      // Navigate to first page, replacing the login page
      if (context.mounted) {
        // In your login function

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 200,
                //color: Color.fromRGBO(130, 3, 0, 1),
              ),
              MyTextField(
                  controller: emailcontroller,
                  obscureText: false,
                  hintText: 'Email'),
              MyTextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  hintText: 'Password'),
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                       // color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              MyButton(todo: 'Login', onTap: () => login(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New User?',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/SignUp');
                    },
                    child: const Text('Sign Up',
                        style: TextStyle(
                         // color: Colors.black,
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
