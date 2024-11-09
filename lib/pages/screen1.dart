import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/search_widget.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/cart.dart';
import 'package:maroro/pages/chats.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/pending.dart';
import 'package:maroro/pages/seller_profile.dart';
import 'package:maroro/pages/shared_cart.dart';
import 'package:maroro/pages/user_search.dart';
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
       /* case 1:
          page = const Trending();
          break;*/
        case 1:
          page = const Bundles();
          break;
        case 2:
          page = Chats(
            userType: widget.userType,
          );
          break;
        case 3:
          page = Profile(
            userType: widget.userType,
          );
          break;
        default:
          page = const Mainscreen();
      }
    });
  }

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  

  @override
  Widget build(BuildContext context) {
    String user = _auth.currentUser!.uid;
    print('the value of userType:${widget.userType}');

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
                    backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Cart(cartType: CartType.self)));
                    },
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  Positioned(
                    right: 10,
                    top: 3,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _fireStore.collection('Cart').where('userId',isEqualTo: _auth.currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // Get the number of documents in the Cart collection
                          int bookings = snapshot.data!.docs.length;

                          return Text(
                            '$bookings',
                            style: GoogleFonts.lateef(color: Colors.white),
                          );
                        } else {
                          return Text(
                            '0', // Show 0 if no data is available
                            style: GoogleFonts.lateef(color: Colors.white),
                          );
                        }
                      },
                    ),
                  ),
                ]),
              )
            : Positioned(
                top: 10,
                right: 10,
                child: Stack(children: [
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Pending()));
                    },
                    child: const Icon(FluentSystemIcons.ic_fluent_checkmark_circle_regular),
                  ),
                  Positioned(
                    right: 10,
                    top: 3,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _fireStore.collection('Pending').where('vendorId',isEqualTo: _auth.currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // Get the number of documents in the Cart collection
                          int bookings = snapshot.data!.docs.length;

                          return Text(
                            '$bookings',
                            style: GoogleFonts.lateef(color: Colors.white),
                          );
                        } else {
                          return Text(
                            '0', // Show 0 if no data is available
                            style: GoogleFonts.lateef(color: Colors.white),
                          );
                        }
                      },
                    ),
                  ),
                ]),
              ),
        drawer: selectedIndex == 0
            ? MyDrawer(
                userType: widget.userType,
              )
            : null,
        appBar: selectedIndex == 0
            ? EventAppBar(
                title: SearchWidget(currentUserId: user),
                userType: widget.userType,
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          //backgroundColor: const Color(0xFFF1E1D5),
          selectedItemColor: Theme.of(context).primaryColorDark.withOpacity(0.8),
          unselectedItemColor: primaryColor,
          selectedFontSize: 10,
          currentIndex: selectedIndex,
          onTap: changeIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'Home'),
            /*BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.speaker_zzz), label: 'Trending'),*/
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
