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
    required this.onRateLoaded, required this.onItemDeleted,
  });

  @override
  State<CartView> createState() => _CartViewState();
  
}

class _CartViewState extends State<CartView> {
 //final GlobalKey<_CartState> _cartKey = GlobalKey<_CartState>();
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
      final rateStr = packageData['rate'].toString().split('/')[0];
      final String numericPart = rateStr.replaceAll(RegExp(r'[^\d.]'), '');
      final rate = double.tryParse(numericPart) ?? 0.0;
      print(
          'Loaded rate $rate for package ${widget.data['package id']}'); // Debug print
      _rateLoaded = true;
      widget.onRateLoaded(widget.data['package id'], rate);
    }
  }
  // Helper method to format the rate for display
  String formatRate(String rateStr) {
    // Split the rate into value and unit (e.g., "₦5000/hour" -> ["₦5000", "hour"])
    List<String> parts = rateStr.split('/');
    if (parts.isNotEmpty) return parts[0];

    String valueWithCurrency = parts[0];

    // Find the currency symbol (first non-digit character)
    //String currencySymbol = RegExp(r'[^\d.]').firstMatch(valueWithCurrency)?.group(0) ?? '';
    
    // Extract numeric value
    String numericValue = valueWithCurrency.replaceAll(RegExp(r'[^\d.]'), '');

    // Format the display string
    return numericValue;
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String orderId) async {
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
                    widget.onItemDeleted(); 
                
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

          return Card(
            elevation: 10,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(15),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        String? orderId = widget.data['orderId'];
                        if (orderId != null) {
                          _showDeleteConfirmation(context, orderId);
                        }
                      },
                      icon: Icon(
                        FluentSystemIcons.ic_fluent_delete_regular,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: Text(
                      "${packageData['rate'].toString().split('/')[0]}.00",
                      textScaler: const TextScaler.linear(4),
                      style: GoogleFonts.lateef(color: Colors.grey[500]),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            packageData['category'] ?? 'Unknown',
                            style: GoogleFonts.lateef(fontSize: 18,fontWeight: FontWeight.w600),
                          ),
                          
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        packageData['packageName'] ?? 'No name',
                        style: GoogleFonts.lateef(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
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
                                height: 5,
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
                                  }),
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
                              Row(
                                children: [
                                  Text(
                                    "Guests: ",
                                    style: GoogleFonts.lateef(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "${widget.data['guests']}",
                                    style: GoogleFonts.lateef(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
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
          );
        },
      ),
    );
  }
}













