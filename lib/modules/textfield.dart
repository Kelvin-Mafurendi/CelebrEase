import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Icon? icon;
  const MyTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    this.icon
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          //fillColor: const Color.fromRGBO(95, 134, 112, 1),
          hintText: hintText,
          suffixIcon: icon,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            
      
          ),
        ),
      
      ),
    );
  }
}