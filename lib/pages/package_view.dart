import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/seller_profile_view.dart';

class PackageView extends StatefulWidget {
  final String packageName;
  final String rate;
  final String description;
  final String userId;
  final String imagePath;

  const PackageView(
      {super.key,
      required this.packageName,
      required this.rate,
      required this.description,
      required this.userId,
      required this.imagePath});

  @override
  State<PackageView> createState() => _PackageViewState();
}

class _PackageViewState extends State<PackageView> {
  bool isSelected = false;

  updatePin() {
    setState(() {
      if (isSelected == false) {
        isSelected = true;
      } else {
        isSelected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      slivers: [
        SliverAppBar(
          iconTheme: const IconThemeData(color: accentColor),
          floating: true,
          pinned: true,
          stretch: true,
          expandedHeight: 350, // Adjust this value as needed
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(color: secondaryColor),
              child: CachedNetworkImage(
                imageUrl: widget.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.packageName,
                    style: GoogleFonts.merienda(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        color: accentColor),
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Positioned(
              top: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        updatePin();
                      },
                      isSelected: isSelected,
                      selectedIcon: const Icon(
                        FluentSystemIcons.ic_fluent_pin_filled,
                        color: primaryColor,
                        size: 40,
                      ),
                      icon: const Icon(
                        FluentSystemIcons.ic_fluent_pin_regular,
                        color: primaryColor,
                        size: 40,
                      )),
                  //SizedBox(width: 20,),
                  //Icon(FluentSystemIcons.ic_fluent_heart_regular,size: 40,),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.description,
              style: GoogleFonts.kalam(fontSize: 18),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 10,
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Book Now'),
                  )),
              FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerProfileView(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.transparent)),
                  child:  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Visit Vendor',
                          style: TextStyle(color:Theme.of(context).brightness==Brightness.light? Colors.black:Colors.white),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Icon(
                          CupertinoIcons.arrow_right,
                          color: Theme.of(context).brightness==Brightness.light? Colors.black:Colors.white,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Divider(
              color: Colors.black12,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Card(
                      color:Theme.of(context).brightness == Brightness.light?const Color.fromARGB(255, 211, 208, 186):stickerColorDark,
                       
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        height: 100,
                        //width: 150,
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            widget.rate,
                            textScaler: const TextScaler.linear(0.4),
                            style: GoogleFonts.merienda(
                              fontSize: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                   Positioned(
                      left: 37,
                      bottom: 73,
                      child: CircleAvatar(
                        backgroundColor:Theme.of(context).brightness == Brightness.light? backgroundColor:Colors.black,
                        radius: 12,
                      ))
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
