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
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data =
        Provider.of<ChangeManager>(context).bookings;
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Provider.of<ChangeManager>(context).bookings.isEmpty
            ? SizedBox(
          height: MediaQuery.of(context).size.height *0.65,
        ): SizedBox(
          height: MediaQuery.of(context).size.height *0.05,
        ),
        Provider.of<ChangeManager>(context).bookings.isEmpty
            ? Center(
                child: Text(
                  'Your Shopping cart is empty.',
                  style: GoogleFonts.lateef(fontSize: 20),
                ),
              )
            : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: data.length,
              shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context,index){
                  return CartView(data: data[index]);
                }),
        Provider.of<ChangeManager>(context).bookings.isNotEmpty
            ?Center(child: Text('Total: ',textScaler: TextScaler.linear(2),style: GoogleFonts.lateef(),)):SizedBox(),
        Provider.of<ChangeManager>(context).bookings.isNotEmpty
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child:
                    ElevatedButton(onPressed: () {}, child: Text('Check Out')),
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continue Shopping')),
        ),
        
        SizedBox(height: 50,)
      ],
    );
  }
}
