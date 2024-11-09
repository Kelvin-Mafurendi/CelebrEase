import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/cart_view.dart';
import 'package:maroro/pages/shared_cart.dart';

class Cart extends StatefulWidget {
  CartType cartType;
  Cart({super.key, required this.cartType});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, double> _itemRates = {};
  final Map<String, int> _itemQuantities = {};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Your existing methods remain the same
  Future<Map<String, double>> _loadAllRates(
      List<Map<String, dynamic>> cartItems) async {
    Map<String, double> rates = {};

    for (var item in cartItems) {
      String packageId = item['package id'];
      if (!rates.containsKey(packageId)) {
        final doc =
            await _firestore.collection('Packages').doc(packageId).get();
        if (doc.exists) {
          final packageData = doc.data() as Map<String, dynamic>;
          final rateStr = packageData['rate'].toString().split('per')[0];
          final String numericPart = rateStr.replaceAll(RegExp(r'[^\d.]'), '');
          rates[packageId] = double.tryParse(numericPart) ?? 0.0;
        }
      }
    }

    return rates;
  }

  Stream<QuerySnapshot> _getCartItems() {
    final user = _auth.currentUser;
    String cartCollection = 'Cart';
    String userId = 'userId';
    if (widget.cartType == CartType.shared) {
      cartCollection = 'Shared Carts';
      userId = 'partnerIds';
    }

    if (user != null) {
      print('Attempting to get cart items for user: ${user.uid}');

      try {
        if (widget.cartType == CartType.shared) {
          return _firestore
              .collection(cartCollection)
              .where(userId, arrayContains: user.uid)
              //.orderBy('timeStamp', descending: true)
              .snapshots();
        } else {
          return _firestore
              .collection(cartCollection)
              .where(userId, isEqualTo: user.uid)
              //.orderBy('timeStamp', descending: true)
              .snapshots();
        }
      } catch (e) {
        print('Error getting cart items: $e');
        // Optionally, you can rethrow the error to handle it at a higher level
        // throw e;
        return Stream.error('Error loading cart items: $e');
      }
    } else {
      print('User not authenticated. Cannot get cart items.');
      return Stream.error('User not authenticated. Cannot get cart items.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final data = snapshot.data?.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList() ??
                    [];

                if (data.isEmpty) {
                  return _buildEmptyState(context);
                }

                return FutureBuilder<Map<String, double>>(
                  future: _loadAllRates(data),
                  builder: (context, ratesSnapshot) {
                    if (ratesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (ratesSnapshot.hasData) {
                      _itemRates.clear();
                      _itemRates.addAll(ratesSnapshot.data!);
                    }

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: CustomScrollView(
                        slivers: [
                          _buildHeader(),
                          SliverToBoxAdapter(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Divider(thickness: 1),
                            ),
                          ),
                          _buildCartItems(data),
                          _buildFooter(context),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            if (widget.cartType == CartType.self)
              _buildSharedCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.cartType == CartType.self ? 'Your Cart' : 'Shared Cart',
              style: GoogleFonts.lateef(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.cartType == CartType.self
                    ? CupertinoIcons.cart
                    : FluentSystemIcons.ic_fluent_people_regular,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(List<Map<String, dynamic>> data) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          String itemId = data[index]['package id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: CartView(
                cartType: widget.cartType,
                key: ValueKey(itemId),
                data: data[index],
                rate: _itemRates[itemId] ?? 0.0,
                onItemDeleted: () {
                  if (mounted) {
                    setState(() {
                      _itemRates.remove(itemId);
                      _itemQuantities.remove(itemId);
                    });
                  }
                },
              ),
            ),
          );
        },
        childCount: data.length,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CartTotal(
                  itemRates: _itemRates,
                  itemQuantities: _itemQuantities,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Implement checkout logic
                  },
                  icon: const Icon(FluentSystemIcons.ic_fluent_payment_regular),
                  label: const Text('Check Out'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(FluentSystemIcons.ic_fluent_share_regular),
                  label: const Text('Share Cart'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(FluentSystemIcons.ic_fluent_arrow_left_regular),
              label: const Text('Continue Shopping'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedCartButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.width * 0.05,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Hero(
        tag: 'shared_cart_button',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                FloatingActionButton(
                  heroTag: null,
                  elevation: 0,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  tooltip: 'Plan with your partners',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Sharedcart()),
                    );
                  },
                  child: const Icon(CupertinoIcons.group),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('Shared Carts')
                          .where('partnerIds',
                              arrayContains: _auth.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.hasData ? snapshot.data!.docs.length : 0}',
                          style: GoogleFonts.lateef(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.cart,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.cartType == CartType.self
                  ? 'Your Shopping cart is empty'
                  : 'You have no Shared Cart Items',
              style: GoogleFonts.lateef(
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(FluentSystemIcons.ic_fluent_arrow_left_regular),
              label: Text(
                widget.cartType == CartType.self ? 'Start Shopping' : 'Go Back',
                style: GoogleFonts.lateef(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: GoogleFonts.lateef(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading cart items',
            style: GoogleFonts.lateef(
              fontSize: 20,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class CartTotal extends StatelessWidget {
  final Map<String, double> itemRates;
  final Map<String, int> itemQuantities;

  const CartTotal({
    super.key,
    required this.itemRates,
    required this.itemQuantities,
  });

  double _calculateTotal() {
    double total = 0.0;
    itemRates.forEach((itemId, rate) {
      int quantity = itemQuantities[itemId] ?? 0;
      total += rate * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: GoogleFonts.lateef(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              'ZAR ${total.toStringAsFixed(2)}',
              style: GoogleFonts.lateef(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deposit Required',
              style: GoogleFonts.lateef(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ZAR ${total.toStringAsFixed(2)}',
                style: GoogleFonts.lateef(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
