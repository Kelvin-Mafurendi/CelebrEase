import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/chats.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/seller_profile.dart';
import 'package:maroro/pages/trends.dart';
import 'package:provider/provider.dart';

class Screen1 extends StatefulWidget {
  final String userType;
  const Screen1({super.key, required this.userType});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  
  int selectedIndex = 0;
  Widget page = const Mainscreen();

  void changeIndex(int index) {
    setState(() {
      selectedIndex = index;
      switch (index) {
        case 0:
          page = const Mainscreen();
          break;
        case 1:
          page = const Trending();
          break;
        case 2:
          page = const Bundles();
          break;
        case 3:
          page = Chats(
            userType: widget.userType,
          );
          break;
        case 4:
          page = Profile(
            userType: widget.userType,
          );
          break;
        default:
          page = const Mainscreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('the value of userType:${widget.userType}');
    int bookings = Provider.of<ChangeManager>(context).bookings.length;
    
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        floatingActionButton: widget.userType == 'Customers'
            ? Positioned(
                top: 10,
                right: 10,
                child: Stack(children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  Positioned(right:10,top: 3,child: Text('$bookings',style: GoogleFonts.lateef(color: Colors.white),))
                ]))
            : null,
        drawer: selectedIndex == 0
            ? MyDrawer(
                userType: widget.userType,
              )
            : null,
        appBar: selectedIndex == 0 ? EventAppBar(title: '', userType:widget.userType,) : null,
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          //backgroundColor: const Color(0xFFF1E1D5),
          selectedItemColor: accentColor,
          unselectedItemColor: primaryColor,
          selectedFontSize: 10,
          currentIndex: selectedIndex,
          onTap: changeIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.speaker_zzz), label: 'Trending'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gift), label: 'CeleBundles'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_text), label: 'Chats'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person), label: 'Profile'),
          ],
        ),
        body: page,
      ),
    );
  }
}
