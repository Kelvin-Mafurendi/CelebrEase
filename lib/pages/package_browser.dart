import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/ad_banner.dart';
import 'package:maroro/pages/package_view.dart';

class ServicePackageBrowser extends StatefulWidget {
  final List<Map<String, String>> services;
  final int initialIndex;

  const ServicePackageBrowser({
    super.key,
    required this.services,
    required this.initialIndex,
  });

  @override
  State<ServicePackageBrowser> createState() => _ServicePackageBrowserState();
}

class _ServicePackageBrowserState extends State<ServicePackageBrowser> {
  late PageController _pageController;
  late int _currentIndex;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.services.length,
        itemBuilder: (context, index) {
          return PackageBrowser(
            service: widget.services[index]['service']!,
            imagePath: widget.services[index]['imagePath']!,
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class PackageBrowser extends StatefulWidget {
  final String service;
  final String imagePath;

  const PackageBrowser({
    super.key,
    required this.service,
    required this.imagePath,
  });

  @override
  State<PackageBrowser> createState() => _PackageBrowserState();
}

class _PackageBrowserState extends State<PackageBrowser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> packageList = [];
  final bool _disposed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPackages();
  }

  Future<void> getPackages() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Packages')
          .where('serviceType', isEqualTo: widget.service)
          .where('hidden', isEqualTo: 'false')
          .get();

      if (!_disposed && mounted) {
        setState(() {
          packageList = querySnapshot.docs.map((doc) {
            return {
              'name': doc['packageName'] as String,
              'description': doc['description'] as String,
              'rate': doc['rate'] as String,
              'imagePath': doc['packagePic'] as String,
              'userId': doc['userId'] as String,
              'package_id': doc.id.toString()
            };
          }).toList();
        });
      }
    } catch (e) {
      if (!_disposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load packages. Please try again.'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          iconTheme: const IconThemeData(color: accentColor, size: 28),
          floating: true,
          pinned: true,
          stretch: true,
          expandedHeight: 450,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.imagePath,
                  child: CachedNetworkImage(
                    imageUrl: widget.imagePath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).brightness == Brightness.light
                          ? secondaryColor
                          : darkTheme.secondaryHeaderColor,
                    ),
                  ),
                ),
                // Gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              widget.service,
              style: GoogleFonts.merienda(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: accentColor,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      curve: Curves.easeOutQuart,
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PackageView(
                                    packageName: packageList[index]['name']!,
                                    imagePath: packageList[index]['imagePath']!,
                                    rate: packageList[index]['rate']!,
                                    userId: packageList[index]['userId']!,
                                    description: packageList[index]
                                        ['description']!,
                                    package_id: packageList[index]
                                        ['package_id']!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? stickerColor
                                    : stickerColorDark,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: packageList[index]['imagePath']!,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: packageList[index]
                                              ['imagePath']!,
                                          width: 120,
                                          height: 160,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              packageList[index]['name']!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.lateef(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              packageList[index]
                                                  ['description']!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black87
                                                    : Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: accentColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                packageList[index]['rate']!,
                                                style: GoogleFonts.lateef(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: accentColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: packageList.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: MyAdBanner(),
          ),
        ),
      ],
    );
  }
}
