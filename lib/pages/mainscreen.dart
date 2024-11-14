import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/ad_banner.dart';
import 'package:maroro/modules/flash_ad.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/flash_ad_view.dart';
import 'package:maroro/pages/package_browser.dart';
import 'package:maroro/pages/walkthough.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> services = [];

  @override
  void initState() {
    super.initState();
    getServices();
  }

  Future<void> getServices() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Services')
        .where('hidden', isEqualTo: 'false')
        .get();
    setState(() {
      services = querySnapshot.docs.map((doc) {
        return {
          'service': doc.id,
          'imagePath': doc['servicePic'] as String,
        };
      }).toList();
    });
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
            ShaderMask(
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
          services.isNotEmpty ? 'Categories' : '',
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
          itemCount: services.length,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 1,
            crossAxisSpacing: 20,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            String serviceName = services[index]['service']!;
            String imagePath = services[index]['imagePath']!;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServicePackageBrowser(
                      services: services,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Sticker(
                service: serviceName,
                imagepath: imagePath,
              ),
            );
          },
        ),
       
        Text(
          'FlashAds\u2122',
          textScaler: const TextScaler.linear(2),
          textAlign: TextAlign.center,
          style: GoogleFonts.merienda(),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('FlashAds').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No FlashAds\u2122 available');
              }

              final now = DateTime.now();
              final activeAds = snapshot.data!.docs.where((doc) {
                final adData = doc.data() as Map<String, dynamic>;
                final Timestamp? timestamp = adData['timeStamp'];

                if (timestamp == null) {
                  return false; // Skip if there's no timestamp
                }

                final DateTime adDateTime = timestamp.toDate();
                return now.difference(adDateTime).inHours < 24 &&
                    adData['hidden'] == 'false'; // Check if hidden is 'false'
              }).toList();

              if (activeAds.isEmpty) {
                return const Text('No active FlashAds\u2122 at the moment');
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeAds.length,
                  itemBuilder: (context, index) {
                    var adData =
                        activeAds[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashAdView(
                                  ads: activeAds,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.2), // Adjust the shadow color
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                  offset:
                                      Offset(0, 8), // Positioning the shadow
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.grey[700]!,
                                width: 4, // Thickness of the border
                              ),
                            ),
                            child: CircleAvatar(
                              minRadius: 100,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? stickerColor
                                  : stickerColorDark,
                              backgroundImage:
                                  CachedNetworkImageProvider(adData['adPic']),
                            ),
                          )),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
