import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/cart.dart';
import 'package:provider/provider.dart';

class CartView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, double) onRateLoaded;
  final VoidCallback onItemDeleted;

  const CartView({
    super.key,
    required this.data,
    required this.onRateLoaded,
    required this.onItemDeleted,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _rateLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  void _loadRate() async {
    print(
        'Loading rate for package ${widget.data['package id']}'); // Debug print
    final doc = await _firestore
        .collection('Packages')
        .doc(widget.data['package id'])
        .get();

    if (doc.exists && !_rateLoaded) {
      final packageData = doc.data() as Map<String, dynamic>;
      final rateStr = packageData['rate'].toString().split('per')[0];
      final String numericPart = rateStr.replaceAll(RegExp(r'[^\d.]'), '');
      final rate = double.tryParse(numericPart) ?? 0.0;
      print(
          'Loaded rate $rate for package ${widget.data['package id']}'); // Debug print
      _rateLoaded = true;
      widget.onRateLoaded(widget.data['package id'], rate);
    }
  }

  String formatRate(String rateStr) {
    List<String> parts = rateStr.split('per');
    if (parts.isNotEmpty) return parts[0];
    String valueWithCurrency = parts[0];
    String numericValue = valueWithCurrency.replaceAll(RegExp(r'[^\d.]'), '');
    return numericValue;
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String orderId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Remove Item',
            style: GoogleFonts.lateef(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to remove booking item from your cart?',
            style: GoogleFonts.lateef(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.lateef(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Remove',
                style: GoogleFonts.lateef(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Provider.of<ChangeManager>(context, listen: false)
                    .removeFromCart(orderId);
                widget
                    .onItemDeleted(); // This will now trigger the update in the parent
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('Packages')
            .doc(widget.data['package id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Package not found');
          }

          Map<String, dynamic> packageData =
              snapshot.data!.data() as Map<String, dynamic>;


          return Stack(
            children: [Card(
              elevation: 10,
              shadowColor: secondaryColor,
              surfaceTintColor: Theme.of(context).cardColor,
              child: Container(
                width: MediaQuery.of(context).size.width * 1.5,
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Stack(
                    children: [
                      
                      Positioned(
                        //right: 0,
                        bottom: 0,
                        left: 0,
                        child: Text(
                          "${packageData['rate'].toString().split('per')[0]}",
                          textScaler: const TextScaler.linear(4),
                          style: GoogleFonts.lateef(color: Colors.grey[500]),
                        ),
                      ),
                      Positioned(
                        top: 0 ,
                        left: MediaQuery.of(context).size.width *0.3,
                        //right: 0,
                        child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  packageData['serviceType'] ?? 'Unknown',
                                  style: GoogleFonts.lateef(
                                      fontSize: 20, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            packageData['packageName'] ?? 'No name',
                            style: GoogleFonts.lateef(fontSize: 18),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: _firestore
                                        .collection('Vendors')
                                        .doc(packageData['userId'])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return SizedBox(
                                        width: MediaQuery.of(context).size.width *
                                            0.275,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              snapshot.data!.get('business name'),
                                              style: GoogleFonts.lateef(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              widget.data['address'] !=
                                                      'Vendor Location'
                                                  ? widget.data['address']
                                                  : snapshot.data!.get('address'),
                                              style: GoogleFonts.lateef(
                                                  fontWeight: FontWeight.w100),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 80,
                                  ),
                                ],
                              ),
                              const SizedBox(
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
                                        widget.data['event date']
                                            .toString()
                                            .split(' ')[0],
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
                                        "${widget.data['start']} to ${widget.data['end']}",
                                        style: GoogleFonts.lateef(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  if(widget.data['guestCount'] != null)
                                  Row(
                                    children: [
                                      Text(
                                        "Guests: ",
                                        style: GoogleFonts.lateef(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      
                                      Text(
                                        "${widget.data['guestCount']}",
                                        style: GoogleFonts.lateef(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  // Add other details from booking form here
                                  for (var key in widget.data.keys)
                                    if (key != 'event date' &&
                                        key != 'start' &&
                                        key != 'end' &&
                                        key != 'guests' &&
                                        key != 'package id' &&
                                        key != 'name' &&
                                        key != 'address' &&
                                        key != 'orderId' &&
                                        key != 'userId' &&
                                        key != 'selected_slots' &&
                                        key != 'guestCount' &&
                                        key != 'timeStamp')
                                      _buildDetailRow(
                                          key, widget.data[key].toString()),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width * 0.285,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                      right: 5,
                      //top: 0,
                      bottom: 5,
                      child: IconButton(
                        onPressed: () {
                          String? orderId = widget.data['orderId'];
                          if (orderId != null) {
                            _showDeleteConfirmation(context, orderId);
                          }
                        },
                        icon: Icon(
                          size: MediaQuery.of(context).size.width * 0.1,
                          FluentSystemIcons.ic_fluent_delete_regular,
                          color: primaryColor,
                        ),
                      ),
                    ),]
          );
        },
      ),
    );
  }
  

  Widget _buildDetailRow(String label, String value) {
    return Row(
      
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.lateef(fontSize: 15, fontWeight: FontWeight.w400),
        ),
        Text(
          value,
          style: GoogleFonts.lateef(fontSize: 15, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}
