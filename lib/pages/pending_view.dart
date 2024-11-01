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
import 'package:maroro/modules/rate_editor.dart';
import 'package:maroro/pages/booking_form.dart';
import 'package:maroro/pages/cart.dart';
import 'package:maroro/pages/chart_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PendingView extends StatefulWidget {
  final Map<String, dynamic> data;
  final double rate;
  final VoidCallback onItemDeleted;

  const PendingView({
    super.key,
    required this.data,
    required this.rate,
    required this.onItemDeleted,
  });

  @override
  State<PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rateLoaded = false;
  bool pending = false;
  bool confirmed = false;
  bool _isEditingRate = false;
  late TextEditingController _rateController;
  late Stream<DocumentSnapshot> pendingStream;
  late Stream<DocumentSnapshot> confirmationStream;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController();
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
      }
    });
  }

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
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    String name = '';
    final doc = await _firestore
        .collection('Packages')
        .doc(widget.data['package id'])
        .get();

    if (doc.exists) {
      final packageData = doc.data() as Map<String, dynamic>;
      name = packageData['packageName'];
    }

    // Update the rate in Firebase if it was edited
    if (_isEditingRate) {
      await _firestore
          .collection('Cart')
          .doc(widget.data['orderId'])
          .update({'rate': '${_rateController.text} per person'});
      setState(() {
        _isEditingRate = false;
      });
    }else if(!_isEditingRate){
      await _firestore
          .collection('Cart')
          .doc(widget.data['orderId'])
          .update({'rate': '${widget.data['rate']} per person'});

    }

    if (pending && !confirmed) {
      await _firestore
          .collection('Confirmations')
          .doc(widget.data['orderId'])
          .set(widget.data);
      await _firestore
          .collection('Pending')
          .doc(widget.data['orderId'])
          .delete();
      DelightToastBar(
        builder: (context) => ToastCard(
          title: Text(
            'Cart Confirmations',
            style: GoogleFonts.lateef(),
          ),
          subtitle: Text(
            "Your '$name' confirmation has been sent to the customer. Now they can check out.",
            style: GoogleFonts.lateef(),
          ),
          leading: Icon(CupertinoIcons.info),
          trailing: Text(
            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: GoogleFonts.lateef(),
          ),
        ),
      ).show(context);
    } else if (confirmed && !pending) {
      DelightToastBar(
        builder: (context) => ToastCard(
          title: Text(
            'Cart',
            style: GoogleFonts.lateef(),
          ),
          subtitle: Text(
            "'$name' booking already confirmed...",
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

   void _showRateEditor(BuildContext context, String currentRate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RateEditOverlay(
        initialRate: currentRate,
        onSave: (newRate) async {
          // Update Firestore
          await _firestore
              .collection('Cart')
              .doc(widget.data['orderId'])
              .update({'rate': '$newRate per item'});
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
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

          // Set initial rate value if editing starts
          if (!_isEditingRate) {
            _rateController.text = formatRate(packageData['rate'].toString());
          }

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
                        bottom: 0,
                        left: 0,
                        child: Text(
                          packageData['rate'].toString().split('per')[0],
                          textScaler: const TextScaler.linear(4),
                          style: GoogleFonts.lateef(color: Colors.grey[500]),
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
                                        .collection('Customers')
                                        .doc(widget.data['userId'])
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
                                              snapshot.data!.get('username'),
                                              style: GoogleFonts.lateef(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              snapshot.data!.get('location'),
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
              bottom: 5,
              child: Column(
                children: [
                  IconButton(
                    onPressed: () =>
                        _startChat(context, widget.data['userId'], 'Customer'),
                    icon: Icon(
                      size: MediaQuery.of(context).size.width * 0.07,
                      FluentSystemIcons.ic_fluent_chat_regular,
                      color: primaryColor,
                    ),
                  ),
                  //const SizedBox(width: 4),
                  Text(
                    'Chat',
                    style: GoogleFonts.lateef(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
           
            Positioned(
                top: 20,
                right: 20,
                child: InkWell(
                  onTap: _confirmOrder,
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
                ),),

                 Positioned(
                right: 90,
                bottom: 5,
                child: InkWell(
                  onTap: () => _showRateEditor(
                    context,
                    formatRate(packageData['rate'].toString()),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        FluentSystemIcons.ic_fluent_edit_regular,
                        color: primaryColor,
                        size: MediaQuery.of(context).size.width * 0.07,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Edit',
                        style: GoogleFonts.lateef(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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


class RateEditOverlay extends StatefulWidget {
  final String initialRate;
  final Function(String) onSave;
  final VoidCallback onCancel;

  const RateEditOverlay({
    super.key,
    required this.initialRate,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<RateEditOverlay> createState() => _RateEditOverlayState();
}

class _RateEditOverlayState extends State<RateEditOverlay> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialRate);
    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.lateef(
                    color: Colors.grey[500],
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Edit Rate',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.lateef(),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onSave(_controller.text),
                      child: Text(
                        'Save',
                        style: GoogleFonts.lateef(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}