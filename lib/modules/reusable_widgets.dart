import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/search_widget.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/package_browser.dart';
import 'package:maroro/pages/settings.dart';

///App bar template
class EventAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userType;
   EventAppBar({super.key, required this.title, required this.userType});

  final Widget title;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  void _showSearchDialog(BuildContext context) {
    String user = _auth.currentUser!.uid;
    showDialog(
      context: context,
      builder: (context) => SearchWidget(currentUserId: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
     // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      
      
    );
  }

  // Implementing PreferredSizeWidget requires this method
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // or any height you want
}
/// Service sticker template with enhanced visuals
/// Service sticker template with optimized visuals
class Sticker extends StatelessWidget {
  const Sticker({super.key, required this.service, required this.imagepath});

  final String service;
  final String imagepath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 0.5, // Adjust height as needed
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? stickerColor
                : stickerColorDark,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 4), // Slight shadow for depth
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imagepath,
              fit: BoxFit.cover, // Ensures the image fills the container proportionally
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(), // Optional loading indicator
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Space between image and text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Added padding for text
          child: Text(
            service,
            style: GoogleFonts.lateef(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
class MyDrawer extends StatelessWidget {
  final String userType;
  const MyDrawer({super.key, required this.userType});

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
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor,
                  secondaryColor,
                  Theme.of(context).primaryColorDark.withOpacity(0.8),
                      
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Theme.of(context).primaryColorDark.withOpacity(0.8),
                      accentColor,
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8.0),
              children: [
                DrawerTile(
                  name: 'M Y  E V E N T S',
                  icon: const Icon(Icons.event_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Events()),
                    );
                  },
                ),
                DrawerTile(
                  name: 'S E T T I N G S',
                  icon: const Icon(Icons.settings_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Settings(userType: userType),
                      ),
                    );
                  },
                ),
                DrawerTile(
                  name: 'S U B S C R I B E',
                  icon: const Icon(Icons.card_membership_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/Membership');
                  },
                ),
                DrawerTile(
                  name: 'N O T I F I C A T I O N S',
                  icon: const Icon(Icons.notifications_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/Notifications');
                  },
                ),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                  thickness: 1,
                ),
                DrawerTile(
                  name: 'L O G  O U T',
                  icon: const Icon(Icons.logout_outlined),
                  onTap: () => logOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatefulWidget {
  const DrawerTile({
    super.key,
    required this.name,
    required this.onTap,
    required this.icon,
  });
  final Icon icon;
  final String name;
  final Function()? onTap;

  @override
  _DrawerTileState createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ListTile(
          leading: widget.icon,
          title: Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
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