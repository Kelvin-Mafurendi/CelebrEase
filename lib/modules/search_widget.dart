import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maroro/pages/flash_ad_view.dart';
import 'package:maroro/pages/highlight_view.dart';
import 'package:maroro/pages/package_view.dart';
import 'package:maroro/pages/seller_profile_view.dart';

class SearchWidget extends StatefulWidget {
  final String currentUserId;
  final List<String>? searchTypes;

  const SearchWidget({
    super.key,
    required this.currentUserId,
    this.searchTypes,
  });

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> _searchContent(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final searchConfigs = _getSearchConfigs();
      final activeSearchConfigs = _getActiveSearchConfigs(searchConfigs);
      final results = await _performSearch(query, activeSearchConfigs);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getSearchConfigs() {
    return {
      'Vendors': {
        'searchFields': ['searchName', 'searchUsername'],
        'displayFields': {'title': 'business name', 'subtitle': 'category'},
        'type': 'profile'
      },
      'Packages': {
        'searchFields': ['searchPackageName'],
        'displayFields': {'title': 'packageName', 'subtitle': 'rate'},
        'type': 'package'
      },
      'Highlights': {
        'searchFields': ['searchPackageName'],
        'displayFields': {'title': 'packageName', 'subtitle': 'vendorName'},
        'type': 'highlight'
      },
      'FlashAds': {
        'searchFields': ['searchTitle', 'searchDescription'],
        'displayFields': {'title': 'title', 'subtitle': 'vendorName'},
        'type': 'flashAd'
      },
    };
  }

  Map<String, dynamic> _getActiveSearchConfigs(
      Map<String, dynamic> searchConfigs) {
    return widget.searchTypes != null
        ? Map.fromEntries(searchConfigs.entries
            .where((e) => widget.searchTypes!.contains(e.value['type'])))
        : searchConfigs;
  }

  Future<List<Map<String, dynamic>>> _performSearch(
    String query,
    Map<String, dynamic> activeSearchConfigs,
  ) async {
    String lowercaseQuery = query.toLowerCase().trim();
    List<Map<String, dynamic>> results = [];
    Set<String> uniqueIds = {};

    for (var entry in activeSearchConfigs.entries) {
      final collectionName = entry.key;
      final config = entry.value;
      final searchFields = config['searchFields'] as List<String>;

      for (var searchField in searchFields) {
        final query = await FirebaseFirestore.instance
            .collection(collectionName)
            .where(searchField, arrayContainsAny: [
              lowercaseQuery,
              ...List.generate(lowercaseQuery.length,
                  (i) => lowercaseQuery.substring(0, i + 1))
            ])
            .limit(10)
            .get();

        for (var doc in query.docs) {
          if (!uniqueIds.contains(doc.id)) {
            var data = doc.data();
            data['id'] = doc.id;
            data['contentType'] = config['type'];

            if (config['type'] == 'profile' &&
                data['userId'] == widget.currentUserId) {
              continue;
            }

            if (config['type'] != 'profile' && data['userId'] != null) {
              try {
                QuerySnapshot vendorSnapshot = await FirebaseFirestore.instance
                    .collection('Vendors')
                    .where('userId', isEqualTo: data['userId'])
                    .limit(1)
                    .get();

                if (vendorSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic>? vendorData =
                      vendorSnapshot.docs.first.data() as Map<String, dynamic>?;
                  if (vendorData != null) {
                    data['vendorName'] =
                        vendorData['business name'] ?? 'Unknown Vendor';
                  } else {
                    data['vendorName'] = 'Unknown Vendor';
                  }
                }
              } catch (e) {
                print('Error fetching vendor details: $e');
                data['vendorName'] = 'Unknown Vendor';
              }
            }
            results.add(data);
            uniqueIds.add(doc.id);
          }
        }
      }
    }

    return results;
  }

  void _navigateToContentView(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    switch (item['contentType']) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfileView(userId: item['userId']),
          ),
        );
        break;
      case 'package':
        final packageData =
            await _fireStore.collection('Packages').doc(item['id']).get();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageView(
              package_id: item['id'],
              packageName: packageData['packageName'],
              rate: packageData['rate'],
              description: packageData['description'],
              userId: packageData['userId'],
              imagePath: packageData['packagePic'],
            ),
          ),
        );
        break;
      case 'highlight':
        final highlightData =
            await _fireStore.collection('Highlights').doc(item['id']).get();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HighlightView(
              packageName: highlightData['packageName'],
              rate: highlightData['rate'],
              description: highlightData['description'],
              userId: highlightData['userId'],
              imagePath: highlightData['highlightPic'], package_id: highlightData['highlightId'],
            ),
          ),
        );
        break;
      case 'flashAd':
        List<QueryDocumentSnapshot> ads =
            await _fetchActiveFlashAds(item['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashAdView(
              ads: ads,
              initialIndex: 0,
            ),
          ),
        );
        break;
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchActiveFlashAds(
      String flashAdId) async {
    final now = DateTime.now();
    final snapshot = await _fireStore.collection('FlashAds').get();
    return snapshot.docs.where((doc) {
      final adData = doc.data();
      final Timestamp? timestamp = adData['timeStamp'];

      if (timestamp == null) {
        return false; // Skip if there's no timestamp
      }

      final DateTime adDateTime = timestamp.toDate();
      return now.difference(adDateTime).inHours < 24 &&
          adData['hidden'] == 'false' &&
          adData['flashAdId'] == flashAdId;
    }).toList();
  }

  Widget _buildResultTile(Map<String, dynamic> item) {
    Widget listTile;

    switch (item['contentType']) {
      case 'profile':
        listTile = ListTile(
          leading: CircleAvatar(
            child: Text((item['business name']?[0] ?? '?').toUpperCase()),
          ),
          title: Text(item['business name'] ?? 'Unknown'),
          subtitle: Text('@${item['username'] ?? 'unnamed'}'),
          contentPadding: EdgeInsets.all(0),
        );
        break;
      case 'package':
        listTile = ListTile(
          leading: Icon(Icons.shopping_bag),
          title: Text(item['packageName'] ?? 'Unnamed Package'),
          subtitle: Text('by ${item['vendorName'] ?? 'Unknown'}'),
          trailing: Text(item['rate']?.toString().split('per')[0] ?? ''),
          contentPadding: EdgeInsets.all(0),
        );
        break;
      case 'highlight':
        listTile = ListTile(
          leading: Icon(Icons.highlight),
          title: Text(item['packageName'] ?? 'Untitled Highlight'),
          subtitle: Text('by ${item['vendorName'] ?? 'Unknown'}'),
          contentPadding: EdgeInsets.all(0),
        );
        break;
      case 'flashAd':
        listTile = ListTile(
          leading: Icon(Icons.flash_on),
          title: Text(item['title'] ?? 'Untitled Ad'),
          subtitle: Text('by ${item['vendorName'] ?? 'Unknown'}'),
          contentPadding: EdgeInsets.all(0),
        );
        break;
      default:
        listTile = ListTile(
          title: Text('Unknown Content Type'),
          subtitle: Text('Cannot display this content'),
          contentPadding: EdgeInsets.all(0),
        );
    }

    return GestureDetector(
      onTap: () => _navigateToContentView(context, item),
      child: listTile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 242, 255, 231),
            Color.fromARGB(255, 32, 32, 32),
          ],
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _searchContent(_searchController.text),
            ),
          ),
          onChanged: _searchContent,
        ),
        content: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _searchResults.isEmpty
                ? Center(child: Text('Nothing Found'))
                : SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) =>
                          _buildResultTile(_searchResults[index]),
                    ),
                  ),
      ),
    );
  }
}
