import 'package:flutter/material.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/screen1.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: EventAppBar(title: 'Trends'),
      //bottomNavigationBar: DefaultTabController(length: 10, child: MyTabBar()),
        
      
    body: Center(child: Text('Trends',style: TextStyle(fontSize: 100),)),//Center(child: Text('Hello',style: TextStyle(fontSize: 100, ),))
    
    );
  }
}