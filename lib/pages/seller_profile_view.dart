import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/featured_card.dart';
import 'package:maroro/modules/product_card.dart';
import 'package:maroro/pages/booking_form.dart';
import 'package:maroro/pages/chart_screen.dart';

class SellerProfileView extends StatefulWidget {
  final String userId;
  //final String package_id;
  const SellerProfileView({super.key, required this.userId,});

  @override
  State<SellerProfileView> createState() => _SellerProfileViewState();
}

class _SellerProfileViewState extends State<SellerProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _startChat(
      BuildContext context, String vendorId, String vendorName) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = currentUserId.compareTo(vendorId) < 0
        ? '${currentUserId}_$vendorId'
        : '${vendorId}_$currentUserId';

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create a new chat document if it doesn't exist
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, vendorId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    // Navigate to the ChatScreen
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      chatId: chatId,
      vendorId: vendorId,
      vendorName: vendorName,
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    //final String userId = _auth.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('Vendors').doc(widget.userId).snapshots(),
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
          if (!snapshot1.hasData || snapshot1.data == null) {
            //print('No data available');
            return const Text('No data available');
          }

          if (!snapshot1.data!.exists) {
            //print('Document does not exist');
            return ShaderMask(
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
                'CelebrEaser',
                style: GoogleFonts.merienda(
                  fontSize: 40,
                  color: Colors.white, // Use white or any contrasting color
                ),
              ),
            );
          }
          var userProfile = snapshot1.data!.data() as Map<String, dynamic>?;
          // Use null-aware operators and provide default values
          String? imagePath = userProfile?['imagePath'] as String?;
          String brandName =
              userProfile?['business name'] as String? ?? 'Brand Name';
          String location = userProfile?['location'] as String? ?? 'Location';
          String category = userProfile?['category'] as String? ?? 'Category';
          String startTime =
              userProfile?['startTime'] as String? ?? 'Start Time';
          String endTime = userProfile?['endTime'] as String? ?? 'End Time';
          String about =
              userProfile?['business description'] as String? ?? 'About';
          //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
          return CustomScrollView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            slivers: [
              SliverAppBar(
                iconTheme: const IconThemeData(color: accentColor),
                floating: true,
                pinned: true,
                stretch: true,
                expandedHeight: 350, // Adjust this value as needed
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: imagePath!,
                    fit: BoxFit.cover,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          brandName,
                          style: GoogleFonts.merienda(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(
                height: 10,
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.light
                        ? stickerColor
                        : stickerColorDark,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                  FluentSystemIcons.ic_fluent_location_regular),
                              Flexible(
                                child: Text(
                                  location,
                                  style: GoogleFonts.lateef(
                                    fontSize: 25,
                                  ),
                                  //overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 10), // Add some spacing between rows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Business Hours:',
                                  style: GoogleFonts.lateef(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w100),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '$startTime - $endTime',
                                  style: GoogleFonts.lateef(
                                    fontSize: 25,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'About',
                    style: GoogleFonts.merienda(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    about,
                    style: GoogleFonts.kalam(fontSize: 18),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Divider(
                    color: Colors.black12,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    'Highlights',
                    style: GoogleFonts.merienda(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('Highlights')
                        .where('userId', isEqualTo: widget.userId)
                        .snapshots(),
                    builder: (context, snapshot2) {
                      if (snapshot2.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot2.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                      if (!snapshot2.hasData || snapshot2.data == null) {
                        //print('No data available');
                        return const Text('No data available');
                      }
                      // Access the documents
                      List<QueryDocumentSnapshot> highlights =
                          snapshot2.data!.docs;

                      //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: highlights.isNotEmpty
                              ? 145
                              : 10, // Constrain height to screen
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: highlights.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> highlightData =
                                  highlights[index].data()
                                      as Map<String, dynamic>;
                              return FeaturedCard(
                                data: highlightData,
                              );
                            }),
                      );
                    }),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Divider(
                    color: Colors.black12,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    'Packages',
                    style: GoogleFonts.merienda(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('Packages')
                        .where('userId', isEqualTo: widget.userId)
                        .snapshots(),
                    builder: (context, snapshot2) {
                      if (snapshot2.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot2.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                      if (!snapshot2.hasData || snapshot2.data == null) {
                        //print('No data available');
                        return const Text('No data available');
                      }
                      // Access the documents
                      List<QueryDocumentSnapshot> highlights =
                          snapshot2.data!.docs;

                      //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: highlights.isNotEmpty
                              ? 145
                              : 10, // Constrain height to screen
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: highlights.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> highlightData =
                                  highlights[index].data()
                                      as Map<String, dynamic>;
                              return ProductCard(
                                data: highlightData,
                              );
                            }),
                      );
                    }),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Divider(
                    color: Colors.black12,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>BookingForm(package_id: ''),),);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Book Now'),
                      ),
                    ),
                    FilledButton(
                      onPressed: () =>
                          _startChat(context, widget.userId, brandName),
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent),
                      ),
                      child:  Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Chat Now',style: TextStyle(color: Theme.of(context).brightness == Brightness.light?Colors.black:Colors.white),),
                            SizedBox(width: 10),
                            Icon(CupertinoIcons.arrow_right,color: Theme.of(context).brightness == Brightness.light?Colors.black:Colors.white,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        color: primaryColor,
                        Icons.facebook_outlined,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const FaIcon(
                        color: primaryColor,
                        FontAwesomeIcons.xTwitter,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const FaIcon(
                        color: primaryColor,
                        FontAwesomeIcons.instagram,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const FaIcon(
                        color: primaryColor,
                        FontAwesomeIcons.tiktok,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const FaIcon(
                        color: primaryColor,
                        FontAwesomeIcons.linkedin,
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
            ],
          );
        });
  }
}
