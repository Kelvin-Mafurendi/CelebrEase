import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartView extends StatelessWidget {
  final Map<String, dynamic> data;
  CartView({super.key, required this.data});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('Packages')
            .doc(data['package id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Package not found');
          }

          Map<String, dynamic> packageData =
              snapshot.data!.data() as Map<String, dynamic>;

          return Card(
            child: Container(
              height: MediaQuery.of(context).size.width * 0.65,
              padding: EdgeInsets.all(15),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: Text(textScaler: TextScaler.linear(4),
                      "${packageData['rate'].toString().split('/')[0]}.00",
                      style: GoogleFonts.lateef(color: Colors.black38),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      packageData['packageName'] ?? 'No name',
                      style: GoogleFonts.lateef(fontSize: 18),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: packageData['mainPicPath'],
                                fit: BoxFit.cover,
                                width:
                                    MediaQuery.of(context).size.width * 0.275,
                                height:
                                    MediaQuery.of(context).size.width * 0.275,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            StreamBuilder<DocumentSnapshot>(
                                stream: _firestore
                                    .collection('Vendors')
                                    .doc(packageData['userId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.275,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          //data['name'].toString().split(' ')[0],
                                          snapshot.data!.get('business name'),
                                          style: GoogleFonts.lateef(
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          data['address'] != 'Vendor Location'
                                              ? "${data['address']}"
                                              : snapshot.data!.get('address'),
                                          style: GoogleFonts.lateef(
                                              fontWeight: FontWeight.w100),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Date: ",
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  data['event date'].toString().split(' ')[0],
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Time: ",
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${data['start']} to ${data['end']}",
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Guests: ",
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "${data['guests']}",
                                  style: GoogleFonts.lateef(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.285,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
