import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:maroro/main.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProductCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Expanded(
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: stickerColor,
                borderRadius: BorderRadius.circular(10)),
            width: MediaQuery.of(context).size.width * 0.7,
            //height: MediaQuery.of(context).size.width,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: NetworkImage(data['mainPicPath']!),
                  fit: BoxFit.fitWidth,
                  height: 200,
                ),
                Text(
                  data['packageName']!,
                  style: const TextStyle(fontWeight: FontWeight.w200),
                ),
                Text(
                  '(${data['rate']!})',
                  textScaler: const TextScaler.linear(0.9),
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${data['description']!}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              primaryColor)),
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_edit_regular,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              primaryColor)),
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_eye_hide_regular,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              primaryColor)),
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
