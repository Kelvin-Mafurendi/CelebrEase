import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children:  [
        const SizedBox(height: 500,),
        Center(child: Text('Your Shopping cart is empty.',style: GoogleFonts.lateef(fontSize: 20),),),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
          child: FilledButton(onPressed: (){Navigator.pop(context);}, child: const Text('Continue Shopping')),
        )


      ],
    );
  }
}
