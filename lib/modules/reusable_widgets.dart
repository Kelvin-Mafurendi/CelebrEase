import 'package:flutter/material.dart';
import 'package:maroro/Auth/auth_service.dart';

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
      actions: [
        IconButton.outlined(
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
          icon: const Icon(
            Icons.notifications,
           // color: Colors.white,
          ),
        )
      ],
    );
  }

  // Implementing PreferredSizeWidget requires this method
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // or any height you want
}

///Service sticker template
class Sticker extends StatelessWidget {
  const Sticker({super.key, required this.service, required this.icon});

  final String service;
  final String icon;

  static final Map<String, IconData> iconsMap = {
    'cake': Icons.cake_outlined,
    'venue': Icons.house_outlined,
    'dress': Icons.shop_2_outlined,
    'music': Icons.music_note_outlined,
    'food': Icons.food_bank_outlined,
    'photo': Icons.photo_camera_outlined,
    'vendor': Icons.storefront_outlined,
    'make': Icons.brush_outlined,
    'mic': Icons.mic_outlined,
    'event': Icons.event_outlined,
    'decor': Icons.curtains_closed_outlined,
    'hair': Icons.cut_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/$service');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconsMap[icon] ?? Icons.error,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              service,
              textScaler: const TextScaler.linear(0.5),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
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
          const DrawerHeader(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            duration: Duration(seconds: 10),
            curve: Curves.bounceInOut,
            child: CircleAvatar(
              radius: 150,
              backgroundImage: AssetImage('assets\\img\\logo.png'),
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