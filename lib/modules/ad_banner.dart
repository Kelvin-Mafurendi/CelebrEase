import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maroro/main.dart';

class MyAdBanner extends StatefulWidget {
  const MyAdBanner({super.key});

  @override
  State<MyAdBanner> createState() => _MyAdBannerState();
}

class _MyAdBannerState extends State<MyAdBanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> bannerImages = [];
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Fetch images and start auto-sliding when data is ready
    getBannerImages().then((_) {
      _startAutoSliding();
    });
  }

  Future<void> getBannerImages() async {
    EasyLoading.show();
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('banners').where('hidden',isEqualTo: 'false').get();
      setState(() {
        bannerImages.addAll(querySnapshot.docs.map((doc) => doc['bannerPic'] as String));
      });
    } catch (e) {
      print('Error fetching banner images: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _startAutoSliding() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (bannerImages.isNotEmpty && mounted) {
        setState(() {
          _currentPage++;
          if (_currentPage == bannerImages.length) {
            _currentPage = 0; // Loop back to the first page
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? stickerColor
            : stickerColorDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: bannerImages.isNotEmpty
          ? Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: bannerImages.length,
                  itemBuilder: (context, index) {
                    return AnimatedOpacity(
                      opacity: _currentPage == index ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: bannerImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Optional dot indicator
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      bannerImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 16 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
