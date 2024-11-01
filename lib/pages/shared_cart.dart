import 'package:flutter/material.dart';
import 'package:maroro/pages/cart.dart';
enum CartType{shared,self}
class Sharedcart extends StatefulWidget {
  const Sharedcart({super.key});

  @override
  State<Sharedcart> createState() => _SharedcartState();
}

class _SharedcartState extends State<Sharedcart> {
  @override
  Widget build(BuildContext context) {
    return Cart(cartType:CartType.shared,);
  }
}