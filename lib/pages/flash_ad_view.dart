import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/pages/seller_profile_view.dart';

class FlashAdView extends StatefulWidget {
  final List<QueryDocumentSnapshot> ads;
  final int initialIndex;

  const FlashAdView({
    Key? key,
    required this.ads,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FlashAdView> createState() => _FlashAdViewState();
}

class _FlashAdViewState extends State<FlashAdView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getDayOfWeek(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "Unknown";
    }
  }

  String _getTimeOfDay(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildAdPage(QueryDocumentSnapshot ad) {
    final adData = ad.data() as Map<String, dynamic>;
    final DateTime dateTime = DateTime.parse(adData['timeStamp']);
    final String dayOfWeek = _getDayOfWeek(dateTime);
    final String timeOfDay = _getTimeOfDay(dateTime);

    return Column(
      children: [
        const Spacer(),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: adData['mainPicPath'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: GoogleFonts.lateef(fontWeight: FontWeight.w100),
            ),
            const SizedBox(width: 10),
            Text(
              timeOfDay,
              style: GoogleFonts.lateef(fontWeight: FontWeight.w100),
            ),
          ],
        ),
        ListTile(
          title: Text(
            adData['title'] ?? 'No Title',
            style: GoogleFonts.lateef(fontSize: 25),
          ),
          subtitle: Text(
            adData['description'] ?? 'No Description',
            style: GoogleFonts.lateef(fontSize: 18),
          ),
          leading: const Icon(FluentSystemIcons.ic_fluent_flash_on_filled),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfileView(userId: adData['userId']),
                    ),
                  );
                },
                splashColor: Colors.grey,
                child: const Text('Visit vendor'),
              ),
              const SizedBox(width: 10),
              const Icon(FluentSystemIcons.ic_fluent_arrow_forward_regular),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flash Ad ${_currentIndex + 1}/${widget.ads.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.ads.length,
        itemBuilder: (context, index) {
          return _buildAdPage(widget.ads[index]);
        },
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}