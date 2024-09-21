import 'package:flutter/material.dart';
import 'package:maroro/modules/ad_banner.dart';
import 'package:maroro/modules/flash_ad.dart';
import 'package:maroro/modules/reusable_widgets.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  @override
  void initState() {
    super.initState();
    //print('MainScreen On');
  }

  TextEditingController locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: MyAdBanner()/*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: 'What are you looking for?',
                    suffixIcon: Icon(Icons.search),
                    //focusColor: Color.fromARGB(255, 117, 102, 91),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                  ),
                ),
              ),
            ],
          ),*/
        ),
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Text(
            '',//'Craft Your Own Version of A Perfect Event',
            textScaler: TextScaler.linear(1.5),
            textAlign: TextAlign.center,
            style: TextStyle(
              // color: Color.fromRGBO(255, 152, 0, 1),
              fontSize: 0,
              //fontStyle: FontStyle.italic,
              fontFamily: 'Cupertino',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
              'Categories',
              textScaler: TextScaler.linear(2),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
        Wrap(
          children: [
            Sticker(service: 'Dressing', icon: 'dress'),
            Sticker(service: 'Venues', icon: 'venue'),
            Sticker(service: 'Cakes', icon: 'cake'),
            Sticker(service: 'Vendors', icon: 'vendor'),
            Sticker(service: 'Music', icon: 'music'),
            Sticker(service: 'Make-Up', icon: 'make'),
            Sticker(service: 'Food', icon: 'food'),
            Sticker(service: 'Photos', icon: 'photo'),
            Sticker(service: 'Mc', icon: 'mic'),
            Sticker(service: 'Events', icon: 'event'),
            Sticker(service: 'Decor', icon: 'decor'),
            Sticker(service: 'Hair', icon: 'hair'),
          ],
        ),
        SizedBox(height: 10,),
        Text(
              'FlashAds',
              textScaler: TextScaler.linear(2),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
              FlashAd(),
            ],
          ),
        ),
      ],
    );
  }
}
