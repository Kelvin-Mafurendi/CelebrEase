import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maroro/main.dart';

class FlashAd extends StatefulWidget {
  const FlashAd({super.key});

  @override
  State<FlashAd> createState() => _FlashAdState();
}

class _FlashAdState extends State<FlashAd> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, left: 10, bottom: 10, right: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('FlashAds').snapshots(),
        builder: (context, snapshot1) {
          if (snapshot1.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot1.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (!snapshot1.hasData || snapshot1.data!.docs.isEmpty) {
            return const Text('No data available');
          }

          // Data exists, return your UI with the fetched documents
          final flashAds = snapshot1.data!.docs; // List of flashAds documents

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: flashAds.length,
            itemBuilder: (context, index) {
              var ad = flashAds[index].data() as Map<String, dynamic>;
              return Container(
                width: MediaQuery.of(context).size.width - 30,
                height: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).brightness == Brightness.light? stickerColor:stickerColorDark,
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(15),child: CachedNetworkImage(imageUrl: ad['mainPicPath'],fit: BoxFit.cover,)),
              );
            },
          );
        },
      ),
    );
  }
}
