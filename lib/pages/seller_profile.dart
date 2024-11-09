import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/about_section.dart';
import 'package:maroro/modules/featured_card.dart';
import 'package:maroro/modules/product_card.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:maroro/pages/flash_ad_view.dart';
import 'package:maroro/pages/project_management.dart';
import 'package:maroro/pages/upload_post.dart';
import 'package:maroro/pages/vendor_calender.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final String userType;
  const Profile({super.key, required this.userType});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int stars = 5;

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser!.uid;
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
    // String userType = userType;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      scrollDirection: Axis.vertical,
      children: [
        Text(
          'Hi,',
          textScaler: const TextScaler.linear(2),
          textAlign: TextAlign.start,
          style: GoogleFonts.merienda(),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection(widget.userType)
                .where('userId', isEqualTo: userId)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.docs.isEmpty) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Theme.of(context).primaryColorDark.withOpacity(0.8),
                      accentColor,
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
                      color: Colors.white,
                    ),
                  ),
                );
              }

              // Assuming there is only one document returned (limit(1))
              Map<String, dynamic> userProfile =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              String? imagePath = userProfile['profilePic'] as String?;
              String brandName =
                  userProfile['business name'] as String? ?? 'Brand Name';
              String userType =
                  userProfile['userType'] as String? ?? 'Customer';
              String location =
                  userProfile['location'] as String? ?? 'Location';
              String category =
                  userProfile['category'] as String? ?? 'Category';
              String startTime =
                  userProfile['startTime'] as String? ?? 'Start Time';
              String endTime = userProfile['endTime'] as String? ?? 'End Time';
              //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Theme.of(context).primaryColorDark.withOpacity(0.8),
                      accentColor, // Accent Color
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        child: Text(
                          brandName != ''
                              ? userProfile['username'].toString().split(' ')[0]
                              : 'CelebrEaser', // Display first name
                          textScaler: const TextScaler.linear(1.5),
                          textAlign: TextAlign.start,
                          style: GoogleFonts.merienda(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: imagePath != null
                              ? Image.network(
                                  imagePath,
                                  width: 120,
                                  height: 130,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.person,
                                      size: 40, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userType == 'Vendors'
                                    ? brandName
                                    : userProfile['username'],
                                style: GoogleFonts.merienda(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userType,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    FluentSystemIcons
                                        .ic_fluent_location_regular,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.grey[600],
                                      ),
                                      //maxLines: 1,
                                      //overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              if (userType == 'Vendors')
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    category,
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              if (userType == 'Vendors')
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        startTime,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Text(' - ',
                                          style: TextStyle(color: Colors.grey)),
                                      Text(
                                        endTime,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10),
                    child: Row(
                      children: [
                        if (userType == 'Vendors')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '5.0',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w200),
                                  ),
                                  const SizedBox(width: 10),
                                  ...List.generate(
                                    stars,
                                    (index) => Icon(
                                      CupertinoIcons.star_fill,
                                      size: 12,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {},
                                child: const Text(
                                  'Reviews',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 25.0, top: 5),
                          child: InkWell(
                            splashColor: Colors.green,
                            onTap: () {
                              //provider
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile(
                                            isFirstSetup: brandName.isEmpty,
                                            initialData: const {},
                                            userType:
                                                userType, // Use this condition to determine if it's the first setup
                                          )));
                            },
                            child: Text(
                              brandName != '' ? 'Edit Profile' : 'Set Profile',
                              style: const TextStyle(
                                fontWeight: FontWeight.w200,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
        if (widget.userType == 'Vendors')
          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Divider(
              color: Color.fromARGB(255, 224, 210, 210),
            ),
          ),
        if (widget.userType == 'Vendors')
          AboutSection(
            userType: widget.userType,
          ),
        const Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Divider(
            color: Color.fromARGB(255, 224, 210, 210),
          ),
        ),
        if (widget.userType == 'Vendors')
          Row(
            children: [
              Text(
                'FlashAds',
                textScaler: const TextScaler.linear(1.2),
                style: GoogleFonts.merienda(),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        if (widget.userType == 'Vendors')
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('FlashAds').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No FlashAds\u2122 available');
                }

                final now = DateTime.now();
                final activeAds = snapshot.data!.docs.where((doc) {
                  final adData = doc.data() as Map<String, dynamic>;
                  final Timestamp? timestamp = adData['timeStamp'];

                  if (timestamp == null) {
                    return false; // Skip if there's no timestamp
                  }

                  final DateTime adDateTime = timestamp.toDate();
                  return now.difference(adDateTime).inHours < 24 &&
                      adData['userId'] == userId; // Check if hidden is 'false'
                }).toList();

                if (activeAds.isEmpty) {
                  return const Text('No active FlashAds\u2122 at the moment');
                }

                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeAds.length,
                    itemBuilder: (context, index) {
                      var adData =
                          activeAds[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlashAdView(
                                    ads: activeAds,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.2), // Adjust the shadow color
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                    offset:
                                        Offset(0, 8), // Positioning the shadow
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.grey[700]!,
                                  width: 4, // Thickness of the border
                                ),
                              ),
                              child: CircleAvatar(
                                minRadius: 100,
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? stickerColor
                                    : stickerColorDark,
                                backgroundImage:
                                    CachedNetworkImageProvider(adData['adPic']),
                              ),
                            )),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        if (widget.userType == 'Vendors')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DynamicForm(
                                formType: FormType.flashAd,
                              )));
                },
                style: const ButtonStyle(),
                child: const Text(
                  'Post a FlashAd\u2122',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        if (widget.userType == 'Vendors')
          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Divider(
              color: Color.fromARGB(255, 224, 210, 210),
            ),
          ),
        const SizedBox(
          height: 5,
        ),
        if (widget.userType == 'Vendors')
          Row(
            children: [
              Text(
                'Highlights',
                textScaler: const TextScaler.linear(1.2),
                style: GoogleFonts.merienda(),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        if (widget.userType == 'Vendors')
          StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Highlights')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot2) {
                if (snapshot2.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot2.connectionState == ConnectionState.waiting) {
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
                List<QueryDocumentSnapshot> highlights = snapshot2.data!.docs;

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
                            highlights[index].data() as Map<String, dynamic>;
                        return FeaturedCard(
                          data: highlightData,
                        );
                      }),
                );
              }),
        if (widget.userType == 'Vendors')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DynamicForm(formType: FormType.highlight)));
                  },
                  style: const ButtonStyle(),
                  child: const Text('Add New Highlight ')),
            ],
          ),
        if (widget.userType == 'Vendors')
          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Divider(
              color: Color.fromARGB(255, 224, 210, 210),
            ),
          ),
        if (widget.userType == 'Vendors')
          Row(
            children: [
              Text(
                'Packages',
                textScaler: const TextScaler.linear(1.2),
                style: GoogleFonts.merienda(),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        if (widget.userType == 'Vendors')
          StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Packages')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot3) {
                if (snapshot3.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot3.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
                if (!snapshot3.hasData || snapshot3.data == null) {
                  //print('No data available');
                  return const Text('No data available');
                }
                // Access the documents
                List<QueryDocumentSnapshot> packages = snapshot3.data!.docs;

                //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: packages.isNotEmpty
                        ? 145
                        : 10, // Constrain height to screen
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> packageData =
                            packages[index].data() as Map<String, dynamic>;
                        return ProductCard(
                          data: packageData,
                        );
                      }),
                );
              }),
        if (widget.userType == 'Vendors')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DynamicForm(formType: FormType.package)));
                  },
                  style: const ButtonStyle(),
                  child: const Text('Add New Package')),
            ],
          ),
        if (widget.userType == 'Vendors')
          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Divider(
              color: Color.fromARGB(255, 224, 210, 210),
            ),
          ),
        if (widget.userType == 'Vendors')
          Text(
            'Project Management',
            textScaler: const TextScaler.linear(1.2),
            style: GoogleFonts.merienda(),
          ),
        if (widget.userType == 'Vendors')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VendorCalendarManager(),
                    ),
                  );
                },
                style: const ButtonStyle(),
                child: const Text('Update Calendar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VendorProjectManagement(),
                    ),
                  );
                },
                style: const ButtonStyle(),
                child: const Text('Projects'),
              ),
            ],
          ),
        const SizedBox(height: 40),
        if (widget.userType ==
            'Vendors') // Increased space before social media icons
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
      ],
    );

    
  }
}