import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/pages/cart_view.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  double total = 0.0;
  final Map<String, double> _itemRates = {};
  final Map<String, int> _itemQuantities = {};

  @override
  void didUpdateWidget(Cart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate total whenever the widget updates
    setState(() {
      total = _calculateTotal();
    });
  }

  void _updateRate(String itemId, double rate) {
    print('Updating rate for item $itemId: $rate'); // Debug print
    if (mounted) {
      setState(() {
        // Update quantity and rate
        _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 0) + 1;
        _itemRates[itemId] = rate;
        print('Current rates: $_itemRates'); // Debug print
        print('Current quantities: $_itemQuantities'); // Debug print
      });
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    _itemRates.forEach((itemId, rate) {
      int quantity = _itemQuantities[itemId] ?? 0;
      total += rate * quantity;
    });
    print('Calculating total: $total'); // Debug print
    return total;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = Provider.of<ChangeManager>(context).bookings;

    // Calculate the total only once and store it
    total = _calculateTotal();

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
                    onRateLoaded: _updateRate, onItemDeleted:_calculateTotal,
                  );
                },
              ),
        if (data.isNotEmpty)
          Center(
            child: Text(
              "Total: \$${total.toStringAsFixed(2)}",
              textScaler: const TextScaler.linear(2),
              style: GoogleFonts.lateef(),
            ),
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
