import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/3_dot_menu.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:maroro/pages/flash_ad_view.dart';
import 'package:maroro/pages/highlight_view.dart';
import 'package:maroro/pages/package_view.dart';
import 'package:maroro/pages/project_management.dart';
import 'package:maroro/pages/upload_post.dart';
import 'package:maroro/pages/vendor_calender.dart';

class Profile extends StatefulWidget {
  final String userType;
  const Profile({super.key, required this.userType});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(widget.userType)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final userProfile =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildProfileHeader(userProfile),
              _buildMainContent(userProfile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_profile.png', height: 200),
          const SizedBox(height: 20),
          Text(
            'Let\'s Set Up Your Shop!',
            style:
                GoogleFonts.merienda(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Create Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProfile(
                        isFirstSetup: false,
                        userType: widget.userType,
                        initialData: {}))),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Profile Cover Image with Gradient Overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    profile['coverPic'] ?? 'default_cover_url',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
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
            ),
            // Profile Info Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                          profile['profilePic'] ?? 'default_avatar_url',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['business name'] ?? 'Your Business Name',
                              style: GoogleFonts.merienda(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              profile['category'] ?? 'Category',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfile(
                                    isFirstSetup: false,
                                    userType: widget.userType,
                                    initialData: {}))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuickStats(profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('5.0', 'Rating'),
          _buildStat(profile['totalProjects']?.toString() ?? '0', 'Projects'),
          _buildStat(profile['totalReviews']?.toString() ?? '0', 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMainContent(Map<String, dynamic> profile) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'About',
              _buildAboutSection(profile),
              icon: Icons.info_outline,
            ),
            _buildSection(
              'FlashAds',
              _buildFlashAdsSection(),
              icon: Icons.flash_on,
              action: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DynamicForm(formType: FormType.flashAd))),
                child: const Text('+ Create New'),
              ),
            ),
            _buildSection(
              'Highlights',
              _buildHighlightsSection(),
              icon: Icons.star_outline,
              action: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DynamicForm(formType: FormType.highlight))),
                child: const Text('+ Add New'),
              ),
            ),
            _buildSection(
              'Packages',
              _buildPackagesSection(),
              icon: Icons.inventory_2_outlined,
              action: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DynamicForm(formType: FormType.package))),
                child: const Text('+ Add Package'),
              ),
            ),
            _buildSection(
              'Project Management',
              _buildCalendar([
                {
                  'icon': Icons.calendar_month,
                  'label': 'Update Calendar',
                  'destination': 'calendar'
                },
                {
                  'icon': Icons.manage_accounts,
                  'label': 'Manage Projects',
                  'destination': 'projects'
                },
                {
                  'icon': Icons.play_for_work,
                  'label': 'Test and Play and Test and Play',
                  'destination': ''
                }
              ]),
              icon: Icons.work,
            ),
            _buildSection(
              'Social Media',
              _buildSocialMediaLinks(),
              icon: Icons.share,
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content,
      {IconData? icon, Widget? action}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.merienda(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (action != null) action,
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            profile['business description'] ??
                'Tell your customers about your business...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w200)),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(profile['location'] ?? 'Location', Icons.location_on),
            _buildChip('${profile['startTime']} - ${profile['endTime']}',
                Icons.access_time),
            _buildChip(profile['category'] ?? 'Category', Icons.category),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildFlashAdsSection() {
    return SizedBox(
      height: 180,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('FlashAds')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ads = snapshot.data!.docs;

          if (ads.isEmpty) {
            return _buildEmptyStateCard(
              'No FlashAds Yet',
              'Share quick updates and special offers with your customers',
              Icons.flash_on,
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index].data() as Map<String, dynamic>;
              return _buildFlashAdCard(ad, ads, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildFlashAdCard(Map<String, dynamic> ad,
      List<QueryDocumentSnapshot> ads, int initialIndex) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FlashAdView(ads: ads, initialIndex: initialIndex))),
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: ad['adPic'],
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    ad['title'] ?? 'Flash Ad',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Highlights')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final highlights = snapshot.data!.docs;

          if (highlights.isEmpty) {
            return _buildEmptyStateCard(
              'No Highlights Yet',
              'Showcase your best work and achievements',
              Icons.star,
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final highlight =
                  highlights[index].data() as Map<String, dynamic>;
              return _buildHighlightCard(highlight);
            },
          );
        },
      ),
    );
  }

  Widget _buildHighlightCard(Map<String, dynamic> highlight) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HighlightView(
                  packageName: highlight['packageName'],
                  rate: highlight['rate'],
                  description: highlight['description'],
                  userId: highlight['userId'],
                  imagePath: highlight['highlightPic']))),
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: highlight['highlightPic'],
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    highlight['packageName'] ?? 'Highlight',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesSection() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Packages')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packages = snapshot.data!.docs;

          if (packages.isEmpty) {
            return _buildEmptyStateCard(
              'No Packages Yet',
              'Create packages to showcase your services',
              Icons.inventory_2,
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index].data() as Map<String, dynamic>;
              return _buildPackageCard(package);
            },
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PackageView(
                    packageName: package['packageName'],
                    rate: package['rate'],
                    description: package['description'],
                    userId: package['userId'],
                    imagePath: package['packagePic'],
                    package_id: package['packageId'],
                  ))),
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: package['packagePic'],
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    package['packageName'] ?? 'Package',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(String a, String b, Widget) {
    return Text('Package Card');
  }

  Widget _buildSocialMediaLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialIcon(FontAwesomeIcons.facebook),
        _buildSocialIcon(FontAwesomeIcons.xTwitter),
        _buildSocialIcon(FontAwesomeIcons.instagram),
        _buildSocialIcon(FontAwesomeIcons.tiktok),
        _buildSocialIcon(FontAwesomeIcons.linkedin),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.withOpacity(0.2)
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
        //color: primaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildCalendar(List<Map<String, dynamic>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) => GestureDetector(
                  onTap: () {
                    // Handle navigation based on destination
                    if (item['destination'] == 'calendar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorCalendarManager(),
                        ),
                      );
                    }
                    if (item['destination'] == 'projects') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorProjectManagement(),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(right: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: Icon(item['icon']),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Text(
                                item['label'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
