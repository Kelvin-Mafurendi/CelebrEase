import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/firebase_options.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/cake.dart';
import 'package:maroro/pages/chats.dart';
import 'package:maroro/pages/dress.dart';
import 'package:maroro/pages/add_highlight.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:maroro/pages/event.dart';
import 'package:maroro/pages/food.dart';
import 'package:maroro/pages/landing_page.dart';
import 'package:maroro/pages/mainscreen.dart';
import 'package:maroro/pages/make_up.dart';
import 'package:maroro/pages/mc.dart';
import 'package:maroro/pages/membership.dart';
import 'package:maroro/pages/music.dart';
import 'package:maroro/pages/my_events.dart';
import 'package:maroro/pages/notifications.dart';
import 'package:maroro/pages/photo.dart';
import 'package:maroro/pages/seller_profile.dart';
import 'package:maroro/pages/screen1.dart';
import 'package:maroro/pages/settings.dart';
import 'package:maroro/pages/trends.dart';
import 'package:maroro/pages/vendor.dart';
import 'package:maroro/pages/venue.dart';
import 'package:provider/provider.dart';

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
        primaryColor: const Color(0xFF1D2E4C), // Orange
        scaffoldBackgroundColor: const Color(0xFFAEBFAC), // Sage
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1D2E4C), // Orange
          secondary: Color(0xFF858585), // Bright Red
          surface: Color(0xFFE6E9DE), // Dark Red
          onPrimary: Color(0xFFF7F9F6),
          onSecondary: Colors.white,
          onSurface: Color(0xFF1D2E4C),
        ),
        drawerTheme: const DrawerThemeData(
          shadowColor: Color(0xFF1D2E4C),
          elevation: 20,
        ),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFAEBFAC), // sage
            foregroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Color(0xFF1D2E4C),
            ),
            actionsIconTheme: IconThemeData(
              color: Color(0xFF1D2E4C),
            )),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(130, 3, 0, 1), // Dark Red
          selectedItemColor: Color.fromARGB(255, 31, 80, 153),
          unselectedItemColor: Color(0xFF1D2E4C),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1D2E4C),
        ),
        dividerColor: const Color(0xFF1D2E4C),

        cardTheme: CardTheme(
          color: const Color.fromRGBO(130, 3, 0, 1), // Dark Red
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFFAEBFAC),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          //hintStyle: TextStyle(),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFCFC0BB),
          textTheme: ButtonTextTheme.primary,
        ),
        filledButtonTheme: const FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              Color(0xFF1D2E4C),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
      builder: EasyLoading.init(),
      routes: {
        '/main': (context) => const Mainscreen(),
        '/first': (context) => const Screen1(),
        '/Dressing': (context) => const Dressing(),
        '/Venues': (context) => const Venues(),
        '/Cakes': (context) => const Cakes(),
        '/Vendors': (context) => const Vendors(),
        '/Music': (context) => const Music(),
        '/Make-Up': (context) => const Make(),
        '/Food': (context) => const Food(),
        '/Photos': (context) => const Photos(),
        '/Mc': (context) => const Mc(),
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
        '/addhighlight': (context) => const AddHighlight(
              initialData: {},
            ),
        '/editProfile': (context) => const EditProfile(
              initialData: {},
            ),
      },
    );
  }
}
