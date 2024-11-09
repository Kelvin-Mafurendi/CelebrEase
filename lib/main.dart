// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/auth_gate.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/Auth/signup.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/Provider/theme_notifier.dart';
import 'package:maroro/firebase_options.dart';
import 'package:maroro/modules/notification_service.dart';
import 'package:maroro/pages/bundles.dart';
import 'package:maroro/pages/cart.dart';
import 'package:maroro/pages/chart_screen.dart';
import 'package:maroro/pages/chats.dart';
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
import 'package:maroro/pages/shared_cart.dart';

import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
// Color constants remain the same for light mode
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

// Enhanced light mode ColorScheme
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
  // Adding surface variations for depth
  surfaceVariant: Color(0xFFE7F0D8),
  onSurfaceVariant: Color(0xFF121212),
  outline: Color(0xFF85876F),
);

// Enhanced dark theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    background: Color(0xFF1A1518), // Slightly warmer dark background
    onBackground: Color(0xFFF9F0F1),
    primary: Color(0xFFFF6B6D), // Brighter primary for dark mode
    onPrimary: Color(0xFF1A1518),
    secondary: Color(0xFFD4E5A5), // Lighter secondary for better contrast
    onSecondary: Color(0xFF1A1518),
    tertiary: Color(0xFFA8D67E), // Brighter accent
    onTertiary: Color(0xFF1A1518),
    surface: Color(0xFF231D20), // Slightly lighter than background
    onSurface: Color(0xFFF9F0F1),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    // Adding surface variations for depth
    surfaceVariant: Color(0xFF2D2426),
    onSurfaceVariant: Color(0xFFE6E1E5),
    outline: Color(0xFF958F94),
  ),
  // Enhanced card theme
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: const Color(0xFF958F94).withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
  ),
  // Enhanced button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 4,
      shadowColor: const Color(0xFFFF6B6D).withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  // Enhanced input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF231D20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF958F94)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF958F94)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6B6D), width: 2),
    ),
  ),
  // Enhanced text theme
  textTheme: GoogleFonts.lateefTextTheme(ThemeData.dark().textTheme).copyWith(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      letterSpacing: 0.15,
    ),
  ),
  // Enhanced dialog theme
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 16,
  ),
  // Enhanced bottom sheet theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF231D20),
    modalBackgroundColor: Color(0xFF231D20),
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final themeNotifier = ThemeNotifier();
  await themeNotifier.initialize();
  
  // Preload the Lateef font
  await GoogleFonts.pendingFonts([
    GoogleFonts.lateef(),
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChangeManager()),
        ChangeNotifierProvider.value(value: themeNotifier), // Use value provider
      ],
      child: const MyApp(),
    ),
  );
}    

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize notifications after building context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.initialize(context);
      LocalNotificationService.requestPermissions();
    });
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
                otherUserId: args['vendorId'],
                otherUserName: '',
              );
            },
        
            '/Profile': (context) => const Profile(userType: ''),
            '/Settings': (context) => const Settings(
                  userType: '',
                ),
            '/Bundles': (context) => const Bundles(),
            '/my_events': (context) => const MyEvents(),
            '/log_in': (context) => const LogIn(),
            '/SignUp': (context) => const SignUp(),
            '/Membership': (context) => const Membership(),
            '/notifications': (context) => const Notifications(),
            '/cart': (context) =>  Cart(cartType: CartType.self,),
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
