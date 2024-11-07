import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserSearchDialog extends StatefulWidget {
  final String currentUserId;

  const UserSearchDialog({super.key, required this.currentUserId});

  @override
  _UserSearchDialogState createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
  if (query.isEmpty) return;

  setState(() {
    _isLoading = true;
    _searchResults = [];
  });

  try {
    // Convert query to lowercase for case-insensitive search
    String lowercaseQuery = query.toLowerCase().trim();
    print('Searching for: $lowercaseQuery');

    // Search by name
    final nameQuery = await FirebaseFirestore.instance
        .collection('Customers')
        .where('searchName', arrayContainsAny: [
          lowercaseQuery,
          ...List.generate(lowercaseQuery.length,
              (i) => lowercaseQuery.substring(0, i + 1))
        ])
        .where('userId', isNotEqualTo: widget.currentUserId)
        .limit(10)
        .get();
    print('Name query results: ${nameQuery.docs.length}');

    final usernameQuery = await FirebaseFirestore.instance
        .collection('Customers')
        .where('searchUsername', arrayContainsAny: [
          lowercaseQuery,
          ...List.generate(lowercaseQuery.length,
              (i) => lowercaseQuery.substring(0, i + 1))
        ])
        .where('userId', isNotEqualTo: widget.currentUserId)
        .limit(10)
        .get();
    print('Username query results: ${usernameQuery.docs.length}');

    // Combine and deduplicate results
    Set<String> uniqueUserIds = {};
    List<Map<String, dynamic>> results = [];

    for (var doc in [...nameQuery.docs, ...usernameQuery.docs]) {
      if (!uniqueUserIds.contains(doc['userId'])) {
        var userData = doc.data();
        results.add(userData);
        uniqueUserIds.add(doc['userId']);
      }
    }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or username',
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _searchUsers(_searchController.text),
          ),
        ),
        onChanged: _searchUsers,
      ),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(child: Text('No users found'))
              : SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text('@${user['username'] ?? 'unnamed'}'),
                        onTap: () {
                          Navigator.of(context).pop(user);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
