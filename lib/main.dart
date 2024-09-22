// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/firebase_options.dart';
import 'package:maroro/pages/add_package.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/chats.dart';
import 'package:maroro/pages/add_highlight.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/pages/membership.dart';
import 'package:maroro/pages/my_events.dart';
import 'package:maroro/pages/notifications.dart';
import 'package:maroro/pages/seller_profile.dart';
import 'package:maroro/pages/screen1.dart';
import 'package:maroro/pages/settings.dart';
import 'package:maroro/pages/trends.dart';
import 'package:provider/provider.dart';





/*const textColor = Color(0xFF090609);
const backgroundColor = Color(0xFFf4fcee);
const primaryColor = Color(0xFFa265a2);
const primaryFgColor = Color(0xFF090609);
const secondaryColor = Color(0xFFa0c6a7);
const secondaryFgColor = Color(0xFF090609);
const accentColor = Color(0xFF8cb1ba);
const accentFgColor = Color(0xFF090609);*///colour schem2
  
/*const textColor = Color(0xFF080a07);
const backgroundColor = Color(0xFFf4fcee);
const primaryColor = Color(0xFF7d986f);
const primaryFgColor = Color(0xFF080a07);
const secondaryColor = Color(0xFFb1c7b4);
const secondaryFgColor = Color(0xFF080a07);
const accentColor = Color(0xFF8faf9b);
const accentFgColor = Color(0xFF080a07);*/
  
const textColor = Color(0xFF0d0506);
const backgroundColor = Color(0xFFfcf8f8);
const primaryColor = Color(0xFFbb5355);
const primaryFgColor = Color(0xFFfdf9f9);
const secondaryColor = Color(0xFFcbd594);
const secondaryFgColor = Color(0xFF0d0506);
const accentColor = Color(0xFF95c771);
const accentFgColor = Color(0xFF0d0506);
const stickerColor = Color(0xFFF3F1E4);
const profileCardColor = Color(0xFFEFD7D7);
  
const colorScheme = ColorScheme(
  brightness: Brightness.light,
  background: backgroundColor,
  onBackground: textColor,
  primary: primaryColor,
  onPrimary: primaryFgColor,
  secondary: secondaryColor,
  onSecondary: secondaryFgColor,
  tertiary: accentColor,
  onTertiary: accentFgColor,
  surface: backgroundColor,
  onSurface: textColor,
  error: Brightness.light == Brightness.light ? Color(0xffB3261E) : Color(0xffF2B8B5),
  onError: Brightness.light == Brightness.light ? Color(0xffFFFFFF) : Color(0xff601410),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChangeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        //primaryColor: const Color(0xFF1D2E4C), // Orange
        scaffoldBackgroundColor: backgroundColor, // Sage
        //navigationDrawerTheme: const NavigationDrawerThemeData(indicatorColor: primaryColor,iconTheme: WidgetStatePropertyAll(IconThemeData(color: primaryColor))),
        colorScheme: colorScheme,
      ),
      home: const AuthGate(),
      builder: EasyLoading.init(),
      routes: {
        '/main': (context) => const Mainscreen(),
        '/first': (context) => const Screen1(),
        '/Events': (context) => const Events(),
        '/Chats': (context) => const Chats(),
        '/Trending': (context) => const Trending(),
        '/Profile': (context) => const Profile(),
        '/Settings': (context) => const Settings(),
        '/Bundles': (context) => const Bundles(),
        '/my_events': (context) => const MyEvents(),
        '/log_in': (context) => LogIn(),
        '/SignUp': (context) => const SignUp(),
        '/Membership': (context) => const Membership(),
        '/notifications': (context) => const Notifications(),
        '/addPackage': (context) => const AddPackage(
              initialData: {},
            ),
        '/addhighlight': (context) => const AddHighlight(
              initialData: {},
            ),
        '/editProfile': (context) => EditProfile(
              isFirstSetup: Provider.of<ChangeManager>(context, listen: false)
                      .profileData['brandName']
                      ?.isEmpty ??
                  true,
              initialData: const {},
            ),
      },
    );
  }
}
