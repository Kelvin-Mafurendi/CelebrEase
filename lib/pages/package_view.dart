import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';
import 'package:maroro/pages/booking_form.dart';
import 'package:maroro/pages/seller_profile_view.dart';

class PackageView extends StatefulWidget {
  final String packageName;
  final String rate;
  final String description;
  final String userId;
  final String imagePath;
  final String package_id;

  const PackageView({
    super.key,
    required this.packageName,
    required this.rate,
    required this.description,
    required this.userId,
    required this.imagePath,
    required this.package_id,
  });

  @override
  State<PackageView> createState() => _PackageViewState();
}

class _PackageViewState extends State<PackageView> {
  bool isSelected = false;
  Map<String, dynamic>? packageDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageDetails();
  }

  Future<void> _loadPackageDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Packages')
          .doc(widget.package_id)
          .get();

      setState(() {
        packageDetails = doc.data();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading package details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDynamicOptions() {
    if (packageDetails == null ||
        !packageDetails!.containsKey('dynamicOptions') ||
        packageDetails!['dynamicOptions'].isEmpty) {
      return const SizedBox.shrink();
    }

    List<dynamic> options = packageDetails!['dynamicOptions'];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package Options',
              style: GoogleFonts.merienda(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => _buildOptionItem(option)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label as a heading with a divider
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['name'] ?? 'Option',
                  style: GoogleFonts.merienda(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Divider(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  thickness: 1,
                ),
              ],
            ),
          ),
          // Choices in a grid-like layout
          if (option['options'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (option['options'] as List).map((choice) {
                  return IntrinsicWidth(
                    // Add this widget
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            // Add this widget
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Add this
                              children: [
                                Flexible(
                                  // Add this widget
                                  child: Text(
                                    "${choice['text']}: ",
                                    style: GoogleFonts.kalam(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "+${choice['price']}",
                                  style: GoogleFonts.kalam(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRateDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Package Rate',
                      style: GoogleFonts.merienda(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.rate,
                      style: GoogleFonts.merienda(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingForm(package_id: widget.package_id),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              setState(() {
                isSelected = !isSelected;
              });
            },
            icon: Icon(
              isSelected ? Icons.bookmark : Icons.bookmark_border,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 450,
            floating: true,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.imagePath,
                    child: CachedNetworkImage(
                      imageUrl: widget.imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).brightness == Brightness.light
                            ? secondaryColor
                            : darkTheme.secondaryHeaderColor,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.packageName,
                style: GoogleFonts.merienda(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRateDisplay(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.merienda(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: GoogleFonts.kalam(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildDynamicOptions(),
                _buildActionButtons(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
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
                    icon: const Icon(CupertinoIcons.person),
                    label: const Text('Visit Vendor Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
