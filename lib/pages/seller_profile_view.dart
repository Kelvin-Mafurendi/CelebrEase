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
  const SellerProfileView({super.key, required this.userId});

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
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, vendorId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          otherUserId: vendorId,
          otherUserName: vendorName,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.light
          ? stickerColor.withOpacity(0.7)
          : stickerColorDark.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lateef(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.lateef(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.merienda(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Vendors')
            .where('userId', isEqualTo: widget.userId)
            .limit(1)
            .snapshots(),
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
            return const Text('No data available');
          }

          var userProfile = snapshot1.data!.docs.first;
          String? imagePath = userProfile['profilePic'];
          String brandName = userProfile['business name'] as String? ?? 'Brand Name';
          String location = userProfile['location'] as String? ?? 'Location';
          String category = userProfile['category'] as String? ?? 'Category';
          String startTime = userProfile['startTime'] as String? ?? 'Start Time';
          String endTime = userProfile['endTime'] as String? ?? 'End Time';
          String about = userProfile['business description'] as String? ?? 'About';

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imagePath!,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      brandName,
                      style: GoogleFonts.merienda(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  icon: FluentSystemIcons.ic_fluent_location_regular,
                                  title: 'Location',
                                  value: location,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoCard(
                                  icon: Icons.access_time_rounded,
                                  title: 'Business Hours',
                                  value: '$startTime - $endTime',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('About'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 0,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade50
                                  : Colors.grey.shade900,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  about,
                                  style: GoogleFonts.kalam(
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Highlights'),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('Highlights')
                                .where('userId', isEqualTo: widget.userId)
                                .where('hidden', isEqualTo: 'false')
                                .snapshots(),
                            builder: (context, snapshot2) {
                              if (!snapshot2.hasData) {
                                return const SizedBox(height: 145);
                              }
                              List<QueryDocumentSnapshot> highlights = snapshot2.data!.docs;
                              return Container(
                                height: highlights.isNotEmpty ? 145 : 10,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: highlights.length,
                                  itemBuilder: (context, index) {
                                    return FeaturedCard(
                                      data: highlights[index].data() as Map<String, dynamic>,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Packages'),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('Packages')
                                .where('userId', isEqualTo: widget.userId)
                                .snapshots(),
                            builder: (context, snapshot2) {
                              if (!snapshot2.hasData) {
                                return const SizedBox(height: 145);
                              }
                              List<QueryDocumentSnapshot> packages = snapshot2.data!.docs;
                              return Container(
                                height: packages.isNotEmpty ? 145 : 10,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: packages.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                      data: packages[index].data() as Map<String, dynamic>,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: FilledButton(
                              onPressed: () => _startChat(context, widget.userId, brandName),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.chat_bubble_2, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat Now',
                                    style: GoogleFonts.merienda(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade50
                                  : Colors.grey.shade900,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSocialIcon(FontAwesomeIcons.facebook),
                                _buildSocialIcon(FontAwesomeIcons.xTwitter),
                                _buildSocialIcon(FontAwesomeIcons.instagram),
                                _buildSocialIcon(FontAwesomeIcons.tiktok),
                                _buildSocialIcon(FontAwesomeIcons.linkedin),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FaIcon(
        icon,
        color: primaryColor,
        size: 20,
      ),
    );
  }
}