import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Expanded(
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10)),
            width: 250,
            //height: 200,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets\\img\\pam.jpg'),
                  fit: BoxFit.fill,
                ),
                const Text(
                  'Package Name',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
                const Text(
                  '(\$5/hour)',
                  textScaler: TextScaler.linear(0.9),
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Description of product. This the rhdhsdds ygfsdhd sau and so on and so on etc'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary)),
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_edit_regular,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary)),
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_eye_hide_regular,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary)),
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_delete_regular,
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
