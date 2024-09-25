import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/ad_banner.dart';
import 'package:maroro/modules/flash_ad.dart';
import 'package:maroro/modules/reusable_widgets.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> serviceList = {}; // Changed to Map<String, String>

  @override
  void initState() {
    super.initState();
    getServices();
  }

  Future<void> getServices() async {
    EasyLoading.show();
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Services').get();
      setState(() {
        serviceList.clear(); // Clear existing data before adding new
        for (var doc in querySnapshot.docs) {
          serviceList[doc.id] = doc['imagePath'] as String;
        }
      });
    } catch (e) {
      print('Error fetching services: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  TextEditingController locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
       
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to,',
              style: GoogleFonts.merienda(
                  fontSize: 40, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
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
          ],
        ),
        const Padding(
            padding: EdgeInsets.all(8.0),
            child:
                MyAdBanner() /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: 'What are you looking for?',
                    suffixIcon: Icon(Icons.search),
                    //focusColor: Color.fromARGB(255, 117, 102, 91),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                  ),
                ),
              ),
            ],
          ),*/
            ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Text(
            '', //'Craft Your Own Version of A Perfect Event',
            textScaler: const TextScaler.linear(1.5),
            textAlign: TextAlign.center,
            style: GoogleFonts.merienda(),
          ),
        ),
        Text(
          serviceList.isNotEmpty ? 'Categories' : '',
          textScaler: const TextScaler.linear(2),
          textAlign: TextAlign.center,
          style: GoogleFonts.merienda(),
        ),
        const SizedBox(
          height: 10,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviceList.length,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 1,
            crossAxisSpacing: 20,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            String serviceName = serviceList.keys.elementAt(index);
            String imagePath = serviceList[serviceName]!;
            return Sticker(
              service: serviceName,
              imagepath: imagePath,
            );
          },
        ),
        Text(
          'FlashAds',
          textScaler: const TextScaler.linear(2),
          textAlign: TextAlign.center,
          style: GoogleFonts.merienda(),
        ),
        const SizedBox(
          height: 10,
        ),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
            ],
          ),
        ),
      ],
    );
  }
}
