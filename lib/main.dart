// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/Provider/theme_notifier.dart';
import 'package:maroro/firebase_options.dart';
import 'package:maroro/pages/add_package.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/cart.dart';
import 'package:maroro/pages/chart_screen.dart';
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

const textColor = Color(0xFF0d0506);
const backgroundColor = Color.fromARGB(255, 242, 255, 231);
const primaryColor = Color(0xFFbb5355);
const primaryFgColor = Color(0xFFfdf9f9);
const secondaryColor = Color(0xFFcbd594);
const secondaryFgColor = Color(0xFF0d0506);
const accentColor = Color(0xFF95c771);
const accentFgColor = Color(0xFF0d0506);
const stickerColor = Color(0xFFF3F1E4);
const profileCardColor = Color(0xFFEFD7D7);
const stickerColorDark = Color(0xFF4A4743);
const profileCardColorDark = Color(0xFF5D4B4B);

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
  error: Color(0xffB3261E),
  onError: Color(0xffFFFFFF),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    background: Color(0xFF070303),
    onBackground: Color(0xFFf9f0f1),
    primary: Color(0xFFab4446),
    onPrimary: Color(0xFFf9f0f1),
    secondary: Color(0xFF636a29),
    onSecondary: Color(0xFFf9f0f1),
    tertiary: Color(0xFF5c8e39),
    onTertiary: Color(0xFF070303),
    surface: Color(0xFF070303),
    onSurface: Color(0xFFf9f0f1),
    error: Color(0xffF2B8B5),
    onError: Color(0xff601410),
  ),
  scaffoldBackgroundColor: const Color(0xFF070303),
  cardColor: const Color(0xFF5D4B4B),
);




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChangeManager()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
      ],
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

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: backgroundColor,
            colorScheme: colorScheme,
          ),
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: AuthGate(userType: ''),
          builder: EasyLoading.init(),
          routes: {
            '/main': (context) => const Mainscreen(),
            '/first': (context) => const Screen1(userType: ''),
            '/Events': (context) => const Events(),
            '/Chats': (context) => const Chats(
                  userType: '',
                ),
            '/ChatScreen': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
              return ChatScreen(
                chatId: args['chatId'],
                vendorId: args['vendorId'],
                vendorName: '',
              );
            },
            '/Trending': (context) => const Trending(),
            '/Profile': (context) => const Profile(userType: ''),
            '/Settings': (context) => const Settings(userType: '',),
            '/Bundles': (context) => const Bundles(),
            '/my_events': (context) => const MyEvents(),
            '/log_in': (context) => const LogIn(),
            '/SignUp': (context) => const SignUp(),
            '/Membership': (context) => const Membership(),
            '/notifications': (context) => const Notifications(),
            '/cart': (context) => const Cart(),
            '/addPackage': (context) => const AddPackage(initialData: {}),
            '/addhighlight': (context) => const AddHighlight(initialData: {}),
            '/editProfile': (context) => EditProfile(
                  isFirstSetup:
                      Provider.of<ChangeManager>(context, listen: false)
                              .profileData['brandName']
                              ?.isEmpty ??
                          true,
                  initialData: const {},
                  userType: '',
                ),
          },
        );
      },
    );
  }
}