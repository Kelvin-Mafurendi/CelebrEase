import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final dynamic todo;
  final VoidCallback onTap;

  const MyButton({super.key, required this.onTap, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(300, 60)),
            elevation: WidgetStatePropertyAll(2),
          ),
          onPressed: onTap,
          child:  Text(todo,style: const TextStyle(letterSpacing: 5),)),
    );
  }
}
