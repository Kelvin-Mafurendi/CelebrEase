import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      initialCountryCode: 'ZA', // Set the default country code
      onChanged: (phone) {
        // Manually update the controller with both country code and phone number
        controller.text = '${phone.countryCode}${phone.number}'; 
      },
    );
  }
}
