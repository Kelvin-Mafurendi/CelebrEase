import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/modules/3_dot_menu.dart';
import 'package:maroro/pages/seller_profile_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FlashAdView extends StatefulWidget {
  final List<QueryDocumentSnapshot> ads;
  final int initialIndex;

  const FlashAdView({
    super.key,
    required this.ads,
    required this.initialIndex,
  });

  @override
  State<FlashAdView> createState() => _FlashAdViewState();
}

class _FlashAdViewState extends State<FlashAdView> {
  late PageController _pageController;
  late int _currentIndex;
  String packageId = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getDayOfWeek(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "Unknown";
    }
  }

  String _getTimeOfDay(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildAdPage(QueryDocumentSnapshot ad) {
    final adData = ad.data() as Map<String, dynamic>;
    packageId = adData['flashAdId'];

    final Timestamp timestamp = adData['timeStamp'];
    final DateTime dateTime =
        timestamp.toDate(); // Converts Firestore Timestamp to DateTime
    final String dayOfWeek = _getDayOfWeek(dateTime);
    final String timeOfDay = _getTimeOfDay(dateTime);
    final FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.2),
                    Colors.grey.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: adData['adPic'],
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                adData['title'] ?? 'No Title',
                                style: GoogleFonts.lateef(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (adData['userId'] == userId)
                                ThreeDotMenu(
                                  items: const [
                                    'Edit FlashAd',
                                    'Hide FlashAd',
                                    'Delete FlashAd'
                                  ],
                                  type: 'FlashAds',
                                  id: packageId,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            adData['description'] ?? 'No Description',
                            style: GoogleFonts.lateef(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    FluentSystemIcons.ic_fluent_flash_on_filled,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$dayOfWeek, $timeOfDay',
                                    style: GoogleFonts.lateef(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SellerProfileView(
                                          userId: adData['userId']),
                                    ),
                                  );
                                },
                                splashColor: Colors.grey,
                                child: Row(
                                  children: [
                                    Text(
                                      'Visit vendor',
                                      style: GoogleFonts.lateef(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      FluentSystemIcons
                                          .ic_fluent_arrow_forward_regular,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: widget.ads.length,
                effect: WormEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey.withOpacity(0.3),
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.ads.length,
      itemBuilder: (context, index) {
        return _buildAdPage(widget.ads[index]);
      },
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
