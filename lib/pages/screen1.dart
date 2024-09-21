
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/chats.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/seller_profile.dart';
import 'package:maroro/pages/trends.dart';
class Screen1 extends StatefulWidget {
  const Screen1({super.key});

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
          page = const Chats();
          break;
        case 4:
          page = const Profile();
          break;
        default:
          page = const Mainscreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        ) ?? false;
      },
      child: Scaffold(
        drawer: selectedIndex == 0? const MyDrawer():null,
        appBar:selectedIndex == 0? const EventAppBar(title: ''):null,
        bottomNavigationBar: BottomNavigationBar(
          //backgroundColor: const Color(0xFFF1E1D5),
          //selectedItemColor: const Color.fromARGB(255, 165, 131, 108),
          //unselectedItemColor: const Color.fromARGB(255, 85, 75, 69),
          selectedFontSize: 10,
          currentIndex: selectedIndex,
          onTap: changeIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.speaker_zzz), label: 'Trending'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.gift), label: 'Bundles'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_text), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profile'),
          ],
        ),
        body: page,
      ),
    );
  }
}