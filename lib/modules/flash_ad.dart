import 'package:flutter/material.dart';

class FlashAd extends StatelessWidget {
  const FlashAd({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10.0,left: 10,bottom: 10,right: 10),
      child: CircleAvatar(radius: 100,backgroundColor: Color(0xFF858585),),
    );
  }
}