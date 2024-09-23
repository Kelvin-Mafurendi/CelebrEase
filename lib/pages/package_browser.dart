// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/ad_banner.dart';
import 'package:maroro/pages/package_view.dart';

class PackageBrowser extends StatefulWidget {
  final String service;
  final String imagePath;
  const PackageBrowser(
      {super.key, required this.service, required this.imagePath});

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
    EasyLoading.show(status: 'Loading packages...');
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
            'userId':doc['userId'] as String,
            // Add more fields as needed
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching packages: $e');
      // Consider showing an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load packages. Please try again.'),
        ),
      );
    } finally {
      EasyLoading.dismiss();
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
          expandedHeight: 350, // Adjust this value as needed
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(color: secondaryColor),
              child: Image.network(
                widget.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            title: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.service,
                    style: GoogleFonts.merienda(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        color: accentColor),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 10),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageView(
                          packageName: packageList[index]['name'].toString(),
                          imagePath: packageList[index]['imagePath'].toString(),
                          rate:packageList[index]['rate'].toString(),
                          userId:packageList[index]['userId'].toString(),
                          description:packageList[index]['description'].toString(),

                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: stickerColor,
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
                        //tileColor: accentColor,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${packageList[index]['imagePath']}',
                            width: 50,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          '${packageList[index]['name']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lateef(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        trailing: Text(
                          '${packageList[index]['rate']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lateef(fontSize: 15),
                        ),
                        subtitle: Text(
                          '${packageList[index]['description']},',
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(
                              0.9), //style: GoogleFonts.lateef(fontWeight: FontWeight.w300,fontSize: 18,),softWrap: true,
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Can't find what you are looking for? Try,",
                  textScaler: const TextScaler.linear(1.2),
                  style: GoogleFonts.lateef(),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
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
                  'CeleBundles',
                  style: GoogleFonts.merienda(
                    fontSize: 40,
                    color: Colors.white, // Use white or any contrasting color
                  ),
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            child: MyAdBanner(),
          ),
        ),
        const SliverToBoxAdapter(
          child: Spacer(),
        ),
      ],
    );
  }
}
