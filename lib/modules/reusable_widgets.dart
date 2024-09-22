import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/package_browser.dart';

///App bar template
class EventAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EventAppBar({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      /*leading: Padding(
          padding: const EdgeInsets.all(5),
          child: GestureDetector(onTap: (){
            Navigator.pushNamed(context, '/');//retrun to the Landing Page if logog is rtapped.
          }, child: const CircleAvatar(backgroundImage: AssetImage('assets\\img\\logo.png'),)),),*/
      /*actions: [
        IconButton.outlined(
          color: primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
          icon: const Icon(
            color: primaryColor,
            Icons.notifications,
            // color: Colors.white,
          ),
        )
      ],*/
    );
  }

  // Implementing PreferredSizeWidget requires this method
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // or any height you want
}

///Service sticker template
class Sticker extends StatelessWidget {
  const Sticker({super.key, required this.service, required this.imagepath});

  final String service;
  final String imagepath;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PackageBrowser(service:service, imagePath: imagepath,), // Replace with your target screen
              ),
              
            );
          },
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width *
                0.5, // Adjust height as needed
            decoration: BoxDecoration(
              color: stickerColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(imagepath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Add some space between image and text
        Text(
          service,
          style: GoogleFonts.lateef(
            fontSize: 20,
          ),
          //textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> logOut(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.SignOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          //const Spacer(),
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            duration: const Duration(seconds: 10),
            curve: Curves.decelerate,
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary, // Primary Color
                      accentColor, // Accent Color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Text(
                  'CelebrEase',
                  style: GoogleFonts.merienda(
                    fontSize: 40,
                    color: Colors.white, // Use white or any contrasting color
                  ),
                ),
              ),
            ),
          ),

          //sconst Divider(indent: 20,endIndent: 40,),
          /*DrawerTile(name: 'L O G I N',icon: const Icon(Icons.login_outlined),onTap: () {Navigator.pop(context);
          Navigator.pushNamed(context, '/log_in');} ,),*/
          DrawerTile(
            name: 'M Y  E V E N T S',
            icon: const Icon(
              Icons.event_outlined,
              //color: Color.fromRGBO(130, 3, 0, 1),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my_events');
            },
          ),
          //DrawerTile(name: 'T R E N D S',icon: const Icon(Icons.trending_up_outlined),onTap: () {Navigator.pop(context);} ,),
          DrawerTile(
            name: 'S E T T I N G S',
            icon: const Icon(
              Icons.settings_outlined,
              // color: Color.fromRGBO(130, 3, 0, 1),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/Settings');
            },
          ),
          DrawerTile(
            name: 'S U B S C R I B E',
            icon: const Icon(
              Icons.card_membership_outlined,
              //color: Color.fromRGBO(130, 3, 0, 1),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/Membership');
            },
          ),
          DrawerTile(
            name: 'N O T I F I C A T I O N S',
            icon: const Icon(
              Icons.notifications_outlined,
              //color: Color.fromRGBO(130, 3, 0, 1),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/Notifications');
            },
          ),
          const Spacer(),
          DrawerTile(
            name: 'L O G  O U T',
            icon: const Icon(
              Icons.logout_outlined,
              // color: Color.fromRGBO(130, 3, 0, 1),
            ),
            onTap: () => logOut(context),
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile(
      {super.key, required this.name, required this.onTap, required this.icon});
  final Icon icon;
  final String name;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(
        name,
        style: const TextStyle(
            //color: Color.fromRGBO(130, 3, 0, 1),
            ),
      ),
      onTap: onTap,
    );
  }
}

/*

class MyTabBar extends StatelessWidget {
  const MyTabBar({super.key});

  
  

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      //controller:tabController,,
      tabs: [
        Tab(text: 'Home',icon: Icon(Icons.home)),
        Tab(text: 'Trending',icon: Icon(Icons.newspaper)),
        Tab(text: 'Bundles',icon: Icon(Icons.card_giftcard),),
        Tab(text: 'Chats',icon: Icon(Icons.chat)),
       
        Tab(text: 'Profile',icon: Icon(Icons.person)),
      ],
      textScaler: TextScaler.linear(0.6),
      labelColor: Color.fromARGB(255, 165, 131, 108),
      indicatorColor: Color.fromARGB(255, 165, 131, 108),
      dividerColor: Color.fromARGB(255, 165, 131, 108),
      unselectedLabelColor:Color.fromARGB(255, 85, 75, 69),
    );
  }
}*/