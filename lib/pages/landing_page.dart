import 'package:flutter/material.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/modules/reusable_widgets.dart';

//import 'package:maroro/pages/landing.dart';
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* leading: Image.asset(
          'assets/img/logo.png',
          colorBlendMode: BlendMode.color,
        ),*/
        //title: const Text('Dream Event'),
        //backgroundColor: const Color.fromRGBO(95, 134, 112, 1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/img/logo.png'),
              radius: 150,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Are You Planning an Event?',
              style: TextStyle(
                fontSize: 40,
                //color: Color.fromRGBO(255, 152, 0, 1),
                //fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Look No Further!\nWe have all your event needs and more.',
              style: TextStyle(
                fontSize: 16,
                //color: Color.fromRGBO(255, 152, 0, 1),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/log_in');
              },
              style: ElevatedButton.styleFrom(
                //backgroundColor: const Color.fromRGBO(130, 3, 0, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      //color:  Color.fromRGBO(255, 152, 0, 1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    //color: Color.fromRGBO(255, 152, 0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
