import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/booking_form.dart';
import 'package:maroro/pages/cart.dart';
import 'package:maroro/pages/shared_cart.dart';
import 'package:maroro/pages/user_search.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CartView extends StatefulWidget {
  final Map<String, dynamic> data;
  final double rate;
  final VoidCallback onItemDeleted;
  final CartType cartType;

  const CartView({
    super.key,
    required this.data,
    required this.rate,
    required this.onItemDeleted, required this.cartType,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rateLoaded = false;
  bool pending = false;
  bool confirmed = false;
  late Stream<DocumentSnapshot> pendingStream;
  late Stream<DocumentSnapshot> confirmationStream;

  @override
  void initState() {
    super.initState();
    _loadRate();
    // Initialize the pending status stream
    pendingStream = _firestore
        .collection('Pending')
        .doc(widget.data['orderId'])
        .snapshots();

    // Listen to the stream and update state properly
    pendingStream.listen((snapshot) {
      if (mounted) {
        setState(() {
          pending = snapshot.exists;
        });
      }
    });
    confirmationStream = _firestore
        .collection('Confirmations')
        .doc(widget.data['orderId'])
        .snapshots();

    // Listen to the stream and update state properly
    confirmationStream.listen((snapshot) {
      if (mounted) {
        setState(() {
          confirmed = snapshot.exists;
        });
        if (confirmed) {
          DelightToastBar(
            builder: (context) => ToastCard(
              title: Text(
                'Cart',
                style: GoogleFonts.lateef(),
              ),
              subtitle: Text(
                "Booking Confirmed, ready for check out!",
                style: GoogleFonts.lateef(),
              ),
              leading: Icon(CupertinoIcons.info),
              trailing: Text(
                DateTime.now().toString(),
                style: GoogleFonts.lateef(),
              ),
            ),
          ).show(context);
        }
      }
    });
  }

  Future<void> _shareBooking() async {
    // Show search overlay
    final selectedUser = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return UserSearchDialog(
          currentUserId:
              _auth.currentUser!.uid, // Exclude current user from search
        );
      },
    );

    // If a user was selected
    if (selectedUser != null) {
      try {
        // Reference to Firestore
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Prepare booking data to be shared
        Map<String, dynamic> sharedBookingData = Map.from(widget.data);

        // Add a partnerIds field as an array
        sharedBookingData['partnerIds'] = [selectedUser['userId']];

        // Add a timestamp for when the booking was shared
        sharedBookingData['sharedAt'] = FieldValue.serverTimestamp();

        // Add the shared booking to the 'Shared Carts' collection
        try {
          // First, try to get the document
          final docSnapshot = await firestore
              .collection('Shared Carts')
              .doc(widget.data['orderId'])
              .get();

          if (docSnapshot.exists) {
            // Document exists, update by adding to the array
            await firestore
                .collection('Shared Carts')
                .doc(widget.data['orderId'])
                .update({
              'partnerIds': FieldValue.arrayUnion([selectedUser['userId']])
            });
          } else {
            // Document doesn't exist, create a new document
            await firestore
                .collection('Shared Carts')
                .doc(widget.data['orderId'])
                .set(sharedBookingData);
          }
          DelightToastBar(
          builder: (context) => ToastCard(
            title: Text(
              'Booking Shared',
              style: GoogleFonts.lateef(),
            ),
            subtitle: Text(
              "Booking shared with ${selectedUser['name']}",
              style: GoogleFonts.lateef(),
            ),
            leading: Icon(Icons.check_circle_outline),
          ),
        ).show(context);
        } catch (e) {
          print('Error handling shared cart: $e');
           DelightToastBar(
          builder: (context) => ToastCard(
            title: Text(
              'Share Failed',
              style: GoogleFonts.lateef(),
            ),
            subtitle: Text(
              "Unable to share booking: $e",
              style: GoogleFonts.lateef(),
            ),
            leading: Icon(Icons.error_outline),
          ),
        ).show(context);
          // Optional: Handle the error appropriately
        }

        // Show success toast
        
      } catch (e) {
        // Handle any errors
        print('Error sharing booking: $e');
         DelightToastBar(
          builder: (context) => ToastCard(
            title: Text(
              'Share Failed',
              style: GoogleFonts.lateef(),
            ),
            subtitle: Text(
              "Unable to share booking: $e",
              style: GoogleFonts.lateef(),
            ),
            leading: Icon(Icons.error_outline),
          ),
        ).show(context);
        
       
      }
    }
  }

  Future<void> _connectVendor() async {
    String name = '';
    final doc = await _firestore
        .collection('Packages')
        .doc(widget.data['package id'])
        .get();

    if (doc.exists) {
      final packageData = doc.data() as Map<String, dynamic>;
      name = packageData['packageName'];
    }

    if (!pending && !confirmed) {
      await _firestore
          .collection('Pending')
          .doc(widget.data['orderId'])
          .set(widget.data);

      DelightToastBar(
        builder: (context) => ToastCard(
          title: Text(
            'Cart',
            style: GoogleFonts.lateef(),
          ),
          subtitle: Text(
            "Your '$name' booking has been sent to the vendor for confirmation. You will be able to check out as soon as the Vendor confirms.",
            style: GoogleFonts.lateef(),
          ),
          leading: Icon(CupertinoIcons.info),
          trailing: Text(
            DateTime.now().toString(),
            style: GoogleFonts.lateef(),
          ),
        ),
      ).show(context);
    } else if (pending && !confirmed) {
      DelightToastBar(
        builder: (context) => ToastCard(
          title: Text(
            'Cart',
            style: GoogleFonts.lateef(),
          ),
          subtitle: Text(
            "Confirmation pending for '$name' booking...",
            style: GoogleFonts.lateef(),
          ),
          leading: CircularProgressIndicator(
            color: primaryColor,
          ),
          trailing: Text(
            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: GoogleFonts.lateef(),
          ),
        ),
      ).show(context);
    }
  }

  void _navigateToEditForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingForm(
          package_id: widget.data['package id'],
          isEditing: true,
          existingBookingData: widget.data,
        ),
      ),
    );
  }

  void _loadRate() async {
    print('Loading rate for package ${widget.data['package id']}');
    final doc = await _firestore
        .collection('Packages')
        .doc(widget.data['package id'])
        .get();

    if (doc.exists && !_rateLoaded) {
      final packageData = doc.data() as Map<String, dynamic>;
      final rateStr = packageData['rate'].toString().split('per')[0];
      final String numericPart = rateStr.replaceAll(RegExp(r'[^\d.]'), '');
      final rate = double.tryParse(numericPart) ?? 0.0;
      print('Loaded rate $rate for package ${widget.data['package id']}');
      _rateLoaded = true;
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

          return Stack(children: [
            Card(
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
                        child: confirmed
                            ? RateWidget(data: widget.data)
                            : Text(
                                packageData['rate'].toString().split('per')[0],
                                textScaler: const TextScaler.linear(4),
                                style:
                                    GoogleFonts.lateef(color: Colors.grey[500]),
                              ),
                      ),
                      Positioned(
                        top: 0,
                        left: MediaQuery.of(context).size.width * 0.3,
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
                                      width: MediaQuery.of(context).size.width *
                                          0.275,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.275,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.275,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              snapshot.data!
                                                  .get('business name'),
                                              style: GoogleFonts.lateef(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              widget.data['address'] !=
                                                      'Vendor Location'
                                                  ? widget.data['address']
                                                  : snapshot.data!
                                                      .get('address'),
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
                                        DateFormat('EEEE, MMMM d, y').format(widget
                                            .data['event date']
                                            .toDate()), // Convert to DateTime and format
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
                                  if (widget.data['guestCount'] != null)
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
                                        key != 'vendorId' &&
                                        key != 'timeStamp')
                                      _buildDetailRow(
                                        key,
                                        widget.data[key].toString().replaceAll(
                                            RegExp(r'[\[\]]'),
                                            ''), //strip all squre brackets
                                      ),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.285,
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
              right: 10,
              //top: 0,
              top: 10,
              child: PopupMenuButton(
                //color: secondaryColor,
                iconSize: 30,
                iconColor: Colors.grey[500],
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    //value: SampleItem.itemOne,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(FluentSystemIcons.ic_fluent_edit_regular),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Edit Booking',
                            style: GoogleFonts.lateef(fontSize: 20)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    //value: SampleItem.itemOne,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(FluentSystemIcons.ic_fluent_chat_regular),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Chat With Vendor',
                            style: GoogleFonts.lateef(fontSize: 20)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: _shareBooking,
                    //value: SampleItem.itemOne,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(FluentSystemIcons.ic_fluent_share_regular),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Share Booking',
                          style: GoogleFonts.lateef(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    //value: SampleItem.itemOne,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(FluentSystemIcons.ic_fluent_bookmark_regular),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Bookmark Package',
                            style: GoogleFonts.lateef(fontSize: 20)),
                      ],
                    ),
                  ),
                  if(widget.cartType == CartType.self)
                  PopupMenuItem(
                    onTap: () {
                      String? orderId = widget.data['orderId'];
                      _showDeleteConfirmation(context, orderId!);
                    },
                    //value: SampleItem.itemOne,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_delete_regular,
                          color: primaryColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Delete Booking',
                          style: GoogleFonts.lateef(
                              color: primaryColor, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 40,
                right: 20,
                child: InkWell(
                  onTap: _connectVendor,
                  child: Column(
                    children: [
                      Icon(
                        FluentSystemIcons.ic_fluent_checkmark_circle_regular,
                        color: pending && !confirmed
                            ? Colors.grey
                            : !pending && !confirmed
                                ? primaryColor
                                : accentColor,
                      ),
                      //const SizedBox(height: 10),
                      Text(
                        pending && !confirmed
                            ? 'Pending'
                            : !pending && !confirmed
                                ? 'Confirm'
                                : 'Confirmed',
                        style: GoogleFonts.lateef(
                          color: pending && !confirmed
                              ? Colors.grey
                              : !pending && !confirmed
                                  ? primaryColor
                                  : accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ))
          ]);
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

class RateWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const RateWidget({super.key, required this.data});

  Future<String> getRate() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Cart')
        .where('orderId', isEqualTo: data['orderId'])
        .get();

    if (snapshot.docs.isNotEmpty) {
      String rate = snapshot.docs.first.data()['rate'];
      return rate.split('per')[0].trim(); // Process as needed
    } else {
      return "Rate not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Loading...",
            textScaler: const TextScaler.linear(3),
            style: GoogleFonts.lateef(color: Colors.grey[500]),
          ); // Optional loading indicator
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text(
            "${snapshot.data}",
            textScaler: const TextScaler.linear(4),
            style: GoogleFonts.lateef(color: Colors.grey[500]),
          );
        }
      },
    );
  }
}
