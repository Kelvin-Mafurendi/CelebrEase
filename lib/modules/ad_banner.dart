import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyAdBanner extends StatefulWidget {
  const MyAdBanner({super.key});

  @override
  State<MyAdBanner> createState() => _MyAdBannerState();
}

class _MyAdBannerState extends State<MyAdBanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List bannerImages = [];

  getBannerImages() async{
    EasyLoading.show();
    return await _firestore
        .collection('banners')
        .get()
        .then((QuerySnapshot querySnapshot) {
      // ignore: avoid_function_literals_in_foreach_calls
      querySnapshot.docs.forEach((doc) {
        setState(
          () {
            bannerImages.add(
              doc['image'],
            );
          },
        );
      });
    }).whenComplete((){
      EasyLoading.dismiss();
    });
  }

  @override
  void initState() {
    getBannerImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 190,
      // padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10)),
      child: PageView.builder(
        itemCount: bannerImages.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
              child: Image.network(
            bannerImages[index],
            fit: BoxFit.fitWidth,
          ));
        },
      ),
    );
  }
}
