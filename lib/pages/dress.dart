import 'package:flutter/material.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/screen1.dart';

class Dressing extends StatelessWidget {
  const Dressing({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: EventAppBar(title: 'Dressing'),
     //bottomNavigationBar: DefaultTabController(length: 10,animationDuration: Duration(seconds: 2), child: MyTabBar(),),
    
        
      
    body: Center(child: Text('Dressing',style: TextStyle(fontSize: 60),)),//Center(child: Text('Hello',style: TextStyle(fontSize: 100, ),))
    
    );
  }
}