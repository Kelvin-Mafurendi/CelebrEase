import 'package:flutter/material.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/screen1.dart';

class Bundles extends StatelessWidget {
  const Bundles({super.key});

  @override
  Widget build(BuildContext context) {
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
      child:  Scaffold(
       backgroundColor:Theme.of(context).brightness == Brightness.light? Colors.transparent:Theme.of(context).colorScheme.surface, body: Center(
            child: Text(
          'Bundles',
          style: TextStyle(fontSize: 100),
        )), //Center(child: Text('Hello',style: TextStyle(fontSize: 100, ),))
      ),
    );
  }
}
