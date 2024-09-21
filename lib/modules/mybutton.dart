import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String todo;
  final VoidCallback onTap;

  const MyButton({super.key, required this.onTap, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton(
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(300, 60)),
          ),
          onPressed: onTap,
          child:  Text(todo)),
    );
  }
}
