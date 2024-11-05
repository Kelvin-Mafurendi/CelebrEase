import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/3_dot_menu.dart';
import 'package:maroro/pages/highlight_view.dart';

class FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const FeaturedCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HighlightView(
              packageName: data['packageName'],
              rate: data['rate'],
              description: data['description'],
              userId: data['userId'],
              imagePath: data['highlightPic'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 120,
          child: Card(
            elevation: 4,
            color:Theme.of(context).brightness == Brightness.light? stickerColor:stickerColorDark,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: CachedNetworkImage
                    (
                      imageUrl:data['highlightPic'] ?? '',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      
                    ),
                  ),
                ),
                Positioned(
                  left: 128, // 120 (image width) + 8 (padding)
                  top: 0,
                  right: 8,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['packageName'] ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lateef(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        data['rate'] ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lateef(
                          fontWeight: FontWeight.w100,
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          data['description'] ?? 'N/A',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if(userId == data['userId'])
                Positioned(
                  right: 0,
                  top: 0,
                  child: ThreeDotMenu(
                    items: const ['Edit Highlight', 'Hide Highlight', 'Delete Highlight'],
                    type: 'Highlights',
                    id: data['highlightId'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
