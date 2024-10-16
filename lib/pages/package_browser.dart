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

  @override
  void initState() {
    super.initState();
    getPackages();
  }

  Future<void> getPackages() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Packages')
          .where('category', isEqualTo: widget.service)
          .get();
      setState(() {
        packageList = querySnapshot.docs.map((doc) {
          return {
            'name': doc['packageName'] as String,
            'description': doc['description'] as String,
            'rate': doc['rate'] as String,
            'imagePath': doc['mainPicPath'] as String,
            'userId': doc['userId'] as String,
            'package_id':doc.id.toString()
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching packages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load packages. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      slivers: [
        SliverAppBar(
          iconTheme: const IconThemeData(color: accentColor),
          floating: true,
          pinned: true,
          stretch: true,
          expandedHeight: 350,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? secondaryColor
                    : darkTheme.secondaryHeaderColor,
              ),
              child: CachedNetworkImage(
                imageUrl: widget.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              widget.service,
              style: GoogleFonts.merienda(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                color: accentColor,
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageView(
                          packageName: packageList[index]['name']!,
                          imagePath: packageList[index]['imagePath']!,
                          rate: packageList[index]['rate']!,
                          userId: packageList[index]['userId']!,
                          description: packageList[index]['description']!,
                          package_id: packageList[index]['package_id']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.light
                        ? stickerColor
                        : stickerColorDark,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.bottom,
                        minTileHeight: 200,
                        minVerticalPadding: 15,
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: packageList[index]['imagePath']!,
                            width: 50,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          packageList[index]['name']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lateef(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        trailing: Text(
                          packageList[index]['rate']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lateef(fontSize: 15),
                        ),
                        subtitle: Text(
                          packageList[index]['description']!,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: packageList.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            child: MyAdBanner(),
          ),
        ),
      ],
    );
  }
}