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

class _CartState extends State<Cart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, double> _itemRates = {};
  final Map<String, int> _itemQuantities = {};

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
        if(widget.cartType == CartType.shared){
          return _firestore
            .collection(cartCollection)
            .where(userId, arrayContains: user.uid)
            //.orderBy('timeStamp', descending: true)
            .snapshots();
        }
        else{
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
    
      body: Stack(
        children: [StreamBuilder<QuerySnapshot>(
          stream: _getCartItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading cart items',
                  style: GoogleFonts.lateef(fontSize: 20),
                ),
              );
            }
        
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            final data = snapshot.data?.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList() ??
                [];
        
            if (data.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      widget.cartType == CartType.self
                          ? 'Your Shopping cart is empty.'
                          : 'You have no Shared Cart Items',
                      style: GoogleFonts.lateef(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        widget.cartType == CartType.self
                            ? 'Continue Shopping'
                            : 'Back',
                        style: GoogleFonts.lateef(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              );
            }
        
            return FutureBuilder<Map<String, double>>(
              future: _loadAllRates(data),
              builder: (context, ratesSnapshot) {
                if (ratesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
        
                if (ratesSnapshot.hasData) {
                  _itemRates.clear();
                  _itemRates.addAll(ratesSnapshot.data!);
                }
        
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20,
                          bottom: 5,
                          top: 50,
                        ),
                        child: Text(
                          widget.cartType == CartType.self
                              ? 'Cart'
                              : 'Shared Cart',
                          textScaler: const TextScaler.linear(2.7),
                          style: GoogleFonts.lateef(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(thickness: 0.1)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          String itemId = data[index]['package id'];
                          return CartView(
                            cartType:  widget.cartType,
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
                          );
                        },
                        childCount: data.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CartTotal(
                            itemRates: _itemRates,
                            itemQuantities: _itemQuantities,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  style: const ButtonStyle(
                                    elevation: WidgetStatePropertyAll(1),
                                  ),
                                  onPressed: () {
                                    // Implement checkout logic
                                  },
                                  child: const Text('Check Out'),
                                ),
                                TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Share Cart'),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(FluentSystemIcons
                                            .ic_fluent_share_regular)
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.2,
                            ),
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Continue Shopping'),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        widget.cartType == CartType.self
          ? Positioned(
            bottom: MediaQuery.of(context).size.width *0.05,
            right: MediaQuery.of(context).size.width *0.05,
            child: Stack(children: [
                FloatingActionButton(
                  tooltip: 'Plan with your partners',
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Sharedcart()));
                  },
                  child: Icon(CupertinoIcons.group),
                ),
                Positioned(
                  top: 3,
                  right: 10,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('Shared Carts')
                        .where('partnerIds', arrayContains: _auth.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // Get the number of documents in the Cart collection
                        int bookings = snapshot.data!.docs.length;
            
                        return Text(
                          '$bookings',
                          style: GoogleFonts.lateef(color: Colors.white),
                        );
                      } else {
                        return Text(
                          '0', // Show 0 if no data is available
                          style: GoogleFonts.lateef(color: Colors.white),
                        );
                      }
                    },
                  ),
                ),
              ]),
          )
          : SizedBox(),]
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
    return Column(
      children: [
        Text(
          "Total: ZAR ${_calculateTotal().toStringAsFixed(2)}",
          textScaler: const TextScaler.linear(2),
          style: GoogleFonts.lateef(),
        ),
        Text(
          "Deposit: ZAR ${_calculateTotal().toStringAsFixed(2)}",
          textScaler: const TextScaler.linear(1.3),
          style: GoogleFonts.lateef(),
        ),
      ],
    );
  }
}
