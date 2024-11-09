import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/main.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth > 600 ? 50 : 43; // Dynamic font size for "CelebrEase"
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar for a clean look
        elevation: 0, // Remove shadow for elegance
      ),
      body: Column(
        children: [
          const Spacer(),
          // Title with Gradient and Style
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white70,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).primaryColorDark.withOpacity(0.8),
                      accentColor, // Accent gradient color for CelebrEase name
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  'CelebrEase',
                  textScaler: const TextScaler.linear(1.02),
                  style: GoogleFonts.merienda(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2, // Elegant letter spacing
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Subtitle and Tagline
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Are You Planning an Event?',
              style: GoogleFonts.lateef(
                fontSize: 50,
                color: Theme.of(context).primaryColorDark.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'CelebrEase Got You!',
              style: GoogleFonts.lateef(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: accentColor.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Explore Button with Animated Touch
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogIn(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 8,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Explore',
                    style: GoogleFonts.lateef(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
