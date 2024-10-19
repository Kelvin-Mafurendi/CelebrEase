import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/pages/cart_view.dart';
import 'package:provider/provider.dart';

// New StatefulWidget for the total
class CartTotal extends StatefulWidget {
  final Map<String, double> itemRates;
  final Map<String, int> itemQuantities;

  const CartTotal({
    super.key,
    required this.itemRates,
    required this.itemQuantities,
  });

  @override
  State<CartTotal> createState() => _CartTotalState();
}

class _CartTotalState extends State<CartTotal> {
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  @override
  void didUpdateWidget(CartTotal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateTotal();
  }

  void _calculateTotal() {
    double newTotal = 0.0;
    widget.itemRates.forEach((itemId, rate) {
      int quantity = widget.itemQuantities[itemId] ?? 0;
      newTotal += rate * quantity;
    });
    setState(() {
      total = newTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Total: ZAR ${total.toStringAsFixed(2)}",
        textScaler: const TextScaler.linear(2),
        style: GoogleFonts.lateef(),
      ),
    );
  }
}

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Map<String, double> _itemRates = {};
  final Map<String, int> _itemQuantities = {};

  void _updateRate(String itemId, double rate) {
    print('Updating rate for item $itemId: $rate'); // Debug print
    if (mounted) {
      setState(() {
        _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 0) + 1;
        _itemRates[itemId] = rate;
        print('Current rates: $_itemRates'); // Debug print
        print('Current quantities: $_itemQuantities'); // Debug print
      });
    }
  }

  void _handleItemDeleted(String itemId) {
    setState(() {
      _itemRates.remove(itemId);
      _itemQuantities.remove(itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = Provider.of<ChangeManager>(context).bookings;

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        const Spacer(),
        if (data.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 5, top: 10),
            child: Text(
              'Cart',
              textScaler: TextScaler.linear(2.7),
              style: GoogleFonts.lateef(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(thickness: 0.1),
        ],
        data.isEmpty
            ? SizedBox(height: MediaQuery.of(context).size.height * 0.65)
            : SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        data.isEmpty
            ? Center(
                child: Text(
                  'Your Shopping cart is empty.',
                  style: GoogleFonts.lateef(fontSize: 20),
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String itemId = data[index]['package id'];
                  print('Building CartView for item $itemId'); // Debug print
                  return CartView(
                    key: ValueKey(itemId),
                    data: data[index],
                    onRateLoaded: _updateRate,
                    onItemDeleted: () => _handleItemDeleted(itemId),
                  );
                },
              ),
        if (data.isNotEmpty)
          CartTotal(
            itemRates: _itemRates,
            itemQuantities: _itemQuantities,
          ),
        if (data.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              style: const ButtonStyle(elevation: WidgetStatePropertyAll(1)),
              onPressed: () {},
              child: const Text('Check Out'),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue Shopping'),
          ),
        ),
        const SizedBox(height: 500),
      ],
    );
  }
}