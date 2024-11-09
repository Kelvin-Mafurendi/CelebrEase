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
import 'package:maroro/pages/chart_screen.dart';
import 'package:maroro/pages/shared_cart.dart';
import 'package:maroro/pages/user_search.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class VendorCredentials {
  final String vendorId;
  final String vendorName;

  VendorCredentials({
    required this.vendorId,
    required this.vendorName,
  });
}

class CartView extends StatefulWidget {
  final Map<String, dynamic> data;
  final double rate;
  final VoidCallback onItemDeleted;
  final CartType cartType;

  const CartView({
    super.key,
    required this.data,
    required this.rate,
    required this.onItemDeleted,
    required this.cartType,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rateLoaded = false;
  bool pending = false;
  bool confirmed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Stream<DocumentSnapshot> pendingStream;
  late Stream<DocumentSnapshot> confirmationStream;

  @override
  void initState() {
    super.initState();
    _loadRate();
    _setupAnimations();
    _setupStreams();
  }

  Future<VendorCredentials?> vendorCreds(String packageId) async {
    try {
      final stream1 = await _firestore
          .collection('Packages')
          .where('packageId', isEqualTo: packageId)
          .limit(1)
          .get();

      if (stream1.docs.isEmpty) {
        throw Exception('Package not found');
      }

      String vendorId = stream1.docs.first.data()['userId'];

      final stream2 = await _firestore
          .collection('Vendors')
          .where('userId', isEqualTo: vendorId)
          .limit(1)
          .get();

      if (stream2.docs.isEmpty) {
        throw Exception('Vendor not found');
      }

      String vendorName = stream2.docs.first.data()['business name'];

      return VendorCredentials(
        vendorId: vendorId,
        vendorName: vendorName,
      );
    } catch (e) {
      print('Error fetching vendor credentials: $e');
      return null;
    }
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

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  void _setupStreams() {
    pendingStream = _firestore
        .collection('Pending')
        .doc(widget.data['orderId'])
        .snapshots();

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

    confirmationStream.listen((snapshot) {
      if (mounted) {
        setState(() {
          confirmed = snapshot.exists;
        });
        if (confirmed) {
          _showConfirmationToast();
        }
      }
    });
  }

  void _showConfirmationToast() {
    DelightToastBar(
      builder: (context) => ToastCard(
        title: Text('Cart', style: GoogleFonts.lateef()),
        subtitle: Text(
          "Booking Confirmed, ready for check out!",
          style: GoogleFonts.lateef(),
        ),
        leading:
            const Icon(CupertinoIcons.check_mark_circled, color: Colors.green),
        trailing: Text(
          DateFormat('HH:mm').format(DateTime.now()),
          style: GoogleFonts.lateef(),
        ),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('Packages')
              .doc(widget.data['package id'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error!'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Not Found!'));
            }

            Map<String, dynamic> packageData =
                snapshot.data!.data() as Map<String, dynamic>;

            return _buildMainCard(packageData);
          },
        ),
      ),
    );
  }

  Widget _buildMainCard(Map<String, dynamic> packageData) {
    return Card(
      elevation: 8,
      shadowColor: secondaryColor.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0.95),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildCardContent(packageData),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _connectVendor,
                child: _buildStatusBadge(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> packageData) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(packageData),
          const SizedBox(height: 20),
          _buildMainInfo(packageData),
          const SizedBox(height: 20),
          _buildDetailsSection(),
          const SizedBox(height: 16),
          _buildFooter(packageData),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> packageData) {
    return Row(
      children: [
        Hero(
          tag: 'package-${widget.data['package id']}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: packageData['packagePic'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                packageData['packageName'] ?? 'No name',
                style: GoogleFonts.lateef(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                packageData['serviceType'] ?? 'Unknown',
                style: GoogleFonts.lateef(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(Map<String, dynamic> packageData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Date',
            DateFormat('EEEE, MMMM d, y')
                .format((widget.data['event date'] as Timestamp).toDate()),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Time',
            "${widget.data['start']} to ${widget.data['end']}",
          ),
          if (widget.data['guestCount'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Guests',
              "${widget.data['guestCount']}",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.lateef(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lateef(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: GoogleFonts.lateef(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAdditionalDetails(),
          ],
        ),
      ),
      Positioned(
        right: 5,
        top: 5,
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
                  Text('Edit Booking', style: GoogleFonts.lateef(fontSize: 20)),
                ],
              ),
            ),
            if (widget.cartType == CartType.self)
              PopupMenuItem(
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (context.mounted) {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        // Fetch vendor credentials
                        VendorCredentials? credentials =
                            await vendorCreds(widget.data['package id']);

                        // Close loading dialog
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading dialog
                        }

                        if (credentials != null && context.mounted) {
                          // Call your existing _startChat method
                          await _startChat(
                            context,
                            credentials.vendorId,
                            credentials.vendorName,
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Unable to start chat. Please try again.'),
                            ),
                          );
                        }
                      } catch (e) {
                        // Close loading dialog and show error
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('An error occurred. Please try again.'),
                            ),
                          );
                        }
                      }
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(FluentSystemIcons.ic_fluent_chat_regular),
                    SizedBox(width: 10),
                    Text(
                      'Chat With Vendor',
                      style: GoogleFonts.lateef(fontSize: 20),
                    ),
                  ],
                ),
              ),
            if (widget.cartType == CartType.self)
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
            if (widget.cartType == CartType.self)
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
                      style:
                          GoogleFonts.lateef(color: primaryColor, fontSize: 20),
                    ),
                  ],
                ),
              ),
          ],
        ),
      )
    ]);
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
  if (context.mounted) {  // Add this check for safety
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
}
  Widget _buildAdditionalDetails() {
    return Column(
      children: widget.data.entries
          .where((entry) => ![
                'event date',
                'start',
                'end',
                'guests',
                'package id',
                'name',
                'address',
                'orderId',
                'userId',
                'selected_slots',
                'guestCount',
                'vendorId',
                'createdAt',
                'cartId',
                'hidden',
                'sharedAt',
                'partnerIds',
                'timeStamp'
              ].contains(entry.key))
          .map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildDetailRow(
                  entry.key,
                  entry.value.toString().replaceAll(RegExp(r'[\[\]]'), ''),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.lateef(fontSize: 15, fontWeight: FontWeight.w400),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            value,
            style:
                GoogleFonts.lateef(fontSize: 15, fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Map<String, dynamic> packageData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            confirmed
                ? 'Confirmed'
                : pending
                    ? 'Vendor Confirmation Pending'
                    : 'Unconfirmed',
            style: GoogleFonts.lateef(
              fontSize: 18,
              color: confirmed
                  ? Colors.green
                  : pending
                      ? Colors.orange
                      : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          packageData['rate'].toString().split('per')[0],
          style: GoogleFonts.lateef(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: confirmed
              ? Colors.green
              : pending
                  ? Colors.orange
                  : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              confirmed
                  ? Icons.check_circle
                  : pending
                      ? Icons.pending
                      : Icons.share,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              confirmed
                  ? 'Confirmed'
                  : pending
                      ? 'Pending'
                      : 'Confirm',
              style: GoogleFonts.lateef(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (keep existing helper methods and functionality)

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
