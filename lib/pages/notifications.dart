import 'package:flutter/material.dart';
import 'package:maroro/modules/reusable_widgets.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: EventAppBar(title: 'Notifications'),
      //bottomNavigationBar: DefaultTabController(length: 10,animationDuration: Duration(seconds: 2), child: MyTabBar(),),
    
        
      
    body: Center(child: Text('Notifications',style: TextStyle(fontSize: 100),)),//Center(child: Text('Hello',style: TextStyle(fontSize: 100, ),))
    
    );
  }
}