import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/pages/cart_view.dart';
import 'package:maroro/pages/pending_view.dart';

class Pending extends StatefulWidget {
  const Pending({super.key});

  @override
  State<Pending> createState() => _PendingState();
}

class _PendingState extends State<Pending> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, double> _itemRates = {};
  final Map<String, int> _itemQuantities = {};
  
  Future<Map<String, double>> _loadAllRates(List<Map<String, dynamic>> cartItems) async {
    Map<String, double> rates = {};
    
    for (var item in cartItems) {
      String packageId = item['package id'];
      if (!rates.containsKey(packageId)) {
        final doc = await _firestore.collection('Packages').doc(packageId).get();
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

  if (user != null) {
    print('Attempting to get cart items for user: ${user.uid}'); 

    try {
      return _firestore
          .collection('Pending')
          .where('vendorId', isEqualTo: user.uid)
          //.orderBy('timeStamp', descending: true)
          .snapshots();
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
    return StreamBuilder<QuerySnapshot>(
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
            .toList() ?? [];

        if (data.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'You have no Pending Cart Confirmations',
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
                  child: const Text('Continue selling'),
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
                      'Cart Confirmations',
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
                      return PendingView(
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
                      SizedBox(height: 30,),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2,
                        ),
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Continue Selling'),
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
    return Center(
      child: Text(
        "Total: ZAR ${_calculateTotal().toStringAsFixed(2)}",
        textScaler: const TextScaler.linear(2),
        style: GoogleFonts.lateef(),
      ),
    );
  }
}