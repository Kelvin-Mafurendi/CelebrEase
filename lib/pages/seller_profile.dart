import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/about_section.dart';
import 'package:maroro/modules/featured_card.dart';
import 'package:maroro/modules/product_card.dart';
import 'package:maroro/pages/edit_profile_page.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int stars = 5;

  int userType = 1;

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser!.uid;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      scrollDirection: Axis.vertical,
      children: [
        const Text(
          'Hi,',
          textScaler: TextScaler.linear(2),
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          Provider.of<ChangeManager>(context).profileData['brandName'] != ''
              ? Provider.of<ChangeManager>(context)
                  .profileData['brandName']
                  .toString()
                  .split(' ')[0]
              : 'User', // Display first name
          textScaler: const TextScaler.linear(1.5),
          textAlign: TextAlign.start,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection('User Profiles').doc(userId).snapshots(),
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
                return const Text('Profile not found');
              }
              var userProfile = snapshot1.data!.data() as Map<String, dynamic>?;
              // Use null-aware operators and provide default values
              String? imagePath = userProfile?['imagePath'] as String?;
              String brandName =
                  userProfile?['brandName'] as String? ?? 'Brand Name';
              String userType = userProfile?['userType'] as String? ?? 'User';
              String location =
                  userProfile?['location'] as String? ?? 'Location';
              String category =
                  userProfile?['category'] as String? ?? 'Category';
              String startTime =
                  userProfile?['startTime'] as String? ?? 'Start Time';
              String endTime = userProfile?['endTime'] as String? ?? 'End Time';
              //Provider.of<ChangeManager>(context, listen: false).loadProfileData(userProfile!);
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 125,
                    padding: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              // ignore: unnecessary_null_comparison
                              backgroundImage: imagePath != null
                                  ? NetworkImage(imagePath)
                                  : null,
                              backgroundColor: Colors.grey,
                              radius: 60, // Fallback color
                              // ignore: unnecessary_null_comparison
                              child: imagePath == null
                                  ? const Icon(Icons.person)
                                  : null, // Fallback icon
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brandName,
                                textScaler: const TextScaler.linear(1.2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userType,
                                textScaler: const TextScaler.linear(0.9),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w200),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    FluentSystemIcons
                                        .ic_fluent_location_regular,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () {},
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w200,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      startTime,
                                      textScaler: const TextScaler.linear(0.9),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w200,
                                        //decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const Text(' - '),
                                    Text(
                                      endTime,
                                      textScaler: const TextScaler.linear(0.9),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w200,
                                        //decoration: TextDecoration.underline,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '5.0',
                                  style: TextStyle(fontWeight: FontWeight.w200),
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
                              Navigator.pushNamed(context, '/editProfile');
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

        const Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Divider(
            color: Color.fromARGB(255, 224, 210, 210),
          ),
        ),
        const AboutSection(),

        const Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Divider(
            color: Color.fromARGB(255, 224, 210, 210),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FilledButton(
              onPressed: () {},
              style: const ButtonStyle(),
              child: const Text(
                'Post a FlashAd',
                style: TextStyle(),
              ),
            ),
            FilledButton(
              onPressed: () {},
              style: const ButtonStyle(),
              child: const Text(
                'Update Calender',
                style: TextStyle(),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Divider(
            color: Color.fromARGB(255, 224, 210, 210),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Row(
          children: [
            Text(
              'Highlights',
              textScaler: TextScaler.linear(1.2),
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Spacer(),
            Padding(
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
                  maxHeight: MediaQuery.of(context).size.height *
                      0.55, // Constrain height to screen
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
        Row(
          children: [
            FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addhighlight');
                },
                style: const ButtonStyle(),
                child: const Text('Add New Highlight ')),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Divider(
            color: Color.fromARGB(255, 224, 210, 210),
          ),
        ),
        const Row(
          children: [
            Text(
              'Packages',
              textScaler: TextScaler.linear(1.2),
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            Spacer(),
            Padding(
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
        StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    //ProductCard(),
                    // ProductCard(),
                    //ProductCard(),
                    // ProductCard(),
                  ],
                ),
              );
            }),
        Row(
          children: [
            FilledButton(
                onPressed: () {},
                style: const ButtonStyle(),
                child: const Text('Add New Package')),
          ],
        ),
        const SizedBox(height: 40), // Increased space before social media icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {},
              child: const Icon(
                Icons.facebook_outlined,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const FaIcon(
                FontAwesomeIcons.xTwitter,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const FaIcon(
                FontAwesomeIcons.instagram,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const FaIcon(
                FontAwesomeIcons.tiktok,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const FaIcon(
                FontAwesomeIcons.linkedin,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
