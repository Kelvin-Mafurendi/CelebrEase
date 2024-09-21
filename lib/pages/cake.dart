import 'package:flutter/material.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/screen1.dart';

class Cakes extends StatelessWidget {
  const Cakes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: EventAppBar(title: 'Cakes'),
      //bottomNavigationBar: DefaultTabController(length: 10,animationDuration: Duration(seconds: 2), child: MyTabBar(),),
    
        
      
    body: Center(child: Text('Cakes',style: TextStyle(fontSize: 100),)),//Center(child: Text('Hello',style: TextStyle(fontSize: 100, ),))
    
    );
  }
}