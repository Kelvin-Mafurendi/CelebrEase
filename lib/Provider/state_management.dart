// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' show min;

enum OperationType { create, update }

class ChangeManager extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final uuid = Uuid();

  // Centralized data store with initial states
  final Map<String, Map<String, dynamic>> _dataStore = {
    'profile': {},
    'highlight': {},
    'package': {},
    'flashAd': {},
    'bookingForm': {},
  };

  // Service management
  List<String> _serviceTypes = [];
  bool _isLoadingServices = false;
  final String _selectedService = '';

  // Getters
  Map<String, dynamic> get profileData => _dataStore['profile']!;
  Map<String, dynamic> get highlightData => _dataStore['highlight']!;
  Map<String, dynamic> get packageData => _dataStore['package']!;
  Map<String, dynamic> get flashAd => _dataStore['flashAd']!;
  Map<String, dynamic> get bookingForm => _dataStore['bookingForm']!;
  List<String> get serviceTypes => _serviceTypes;
  bool get isLoadingServices => _isLoadingServices;
  String get selectedService => _selectedService;

  // Unified file upload handler
  // Modified uploadFile method with better null checking
  Future<String> uploadFile({
    required File file,
    required String storagePath,
    String? customFileName,
  }) async {
    try {
      // Generate a unique filename if not provided
      final fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

      // Create the full storage reference path
      final storageRef =
          _firebaseStorage.ref().child(storagePath).child(fileName);

      // Upload the file
      final uploadTask = await storageRef.putFile(file);

      if (uploadTask.state == TaskState.success) {
        // Get and return the download URL
        final downloadUrl = await storageRef.getDownloadURL();
        print('File uploaded successfully. Download URL: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Upload failed: ${uploadTask.state}');
      }
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Unified data operation handler
  Future<void> handleData({
    required String dataType,
    required Map<String, dynamic> newData,
    required String collection,
    required OperationType operation,
    String? userType,
    String? documentId,
    Map<String, String>? fileFields,
  }) async {
    try {
      EasyLoading.show(status: 'Processing...');

      // Get current user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        EasyLoading.dismiss();
        throw Exception('User not authenticated');
      }

      // Create a copy of the data to modify
      Map<String, dynamic> finalData = Map.from(newData);

      // For updates, get the document ID if not provided
      if (operation == OperationType.update && documentId == null) {
        documentId = userId; // Use userId as documentId for profile updates
      }

      // Generate search variations based on data type
      switch (dataType) {
        case 'profile':
          if (finalData.containsKey('business name')) {
            finalData['searchName'] =
                generateSearchVariations(finalData['business name']);
          }
          if (finalData.containsKey('username')) {
            finalData['searchUsername'] =
                generateSearchVariations(finalData['username']);
          }
          break;
        case 'package':
          if (finalData.containsKey('packageName')) {
            finalData['searchPackageName'] =
                generateSearchVariations(finalData['packageName']);
          }
          break;
        case 'flashAd':
          if (finalData.containsKey('title')) {
            finalData['searchTitle'] =
                generateSearchVariations(finalData['title']);
          }
          if (finalData.containsKey('description')) {
            finalData['searchDescription'] =
                generateSearchVariations(finalData['description']);
          }
          break;
        case 'highlight':
          if (finalData.containsKey('packageName')) {
            finalData['searchPackageName'] =
                generateSearchVariations(finalData['packageName']);
          }
          break;
      }

      // Handle file uploads if present
      if (fileFields != null) {
        for (var entry in fileFields.entries) {
          final fieldName = entry.key;
          final storagePath = entry.value;
          final imageFile = getImage(dataType, fieldName);

          if (imageFile != null) {
            try {
              EasyLoading.show(status: 'Uploading image...');
              final downloadUrl = await uploadFile(
                file: imageFile,
                storagePath: storagePath,
              );
              finalData[fieldName] = downloadUrl;
            } catch (e) {
              print('Error uploading image for $fieldName: $e');
              EasyLoading.dismiss();
              throw Exception('Failed to upload image: $e');
            }
          }
        }
      }

      // Add metadata
      if (operation == OperationType.create) {
        finalData.addAll({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'timeStamp': FieldValue.serverTimestamp(),
        });
      } else {
        finalData['updatedAt'] = FieldValue.serverTimestamp();
      }

      // Remove any null or empty values
      finalData.removeWhere(
          (key, value) => value == null || value.toString().isEmpty);

      if (finalData.isEmpty && operation == OperationType.update) {
        EasyLoading.dismiss();
        return; // Nothing to update
      }

      EasyLoading.show(status: 'Saving data...');

      // Perform Firestore operation
      if (operation == OperationType.create) {
        final docRef = documentId != null
            ? _fireStore.collection(collection).doc(documentId)
            : _fireStore.collection(collection).doc();
        finalData['${dataType}Id'] = docRef.id;
        finalData['hidden'] = 'false';

        await docRef.set(finalData);

        // Update local store with the new document ID
        if (documentId == null) {
          _dataStore[dataType]!['id'] = docRef.id;
        }
      } else {
        if (documentId == null) {
          EasyLoading.dismiss();
          throw Exception('Document ID is required for update operations');
        }

        // Handle profile updates
        if (dataType == 'profile') {
          // First try to get existing profile document
          final querySnapshot = await _fireStore
              .collection(collection)
              .where('userId', isEqualTo: userId)
              .get();

          DocumentReference docRef;
          if (querySnapshot.docs.isNotEmpty) {
            // Update existing document
            docRef = querySnapshot.docs.first.reference;
          } else {
            // Create new document if none exists
            docRef = _fireStore.collection(collection).doc();
            finalData['userId'] = userId;
          }

          await docRef.set(finalData, SetOptions(merge: true));
        } else {
          // Handle non-profile updates
          await _fireStore
              .collection(collection)
              .doc(documentId)
              .update(finalData);
        }
      }

      // Update local data store
      _dataStore[dataType] = {..._dataStore[dataType] ?? {}, ...finalData};

      // Clear the temporary image paths after successful upload
      if (fileFields != null) {
        for (var entry in fileFields.entries) {
          clearImage(dataType, entry.key);
        }
      }

      notifyListeners();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved successfully');
    } catch (e) {
      print('Error in handleData for $dataType: $e');
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      rethrow;
    }
  }

  // Example usage methods
  Future<void> createNewPackage(Map<String, dynamic> packageData) async {
    await handleData(
      dataType: 'package',
      newData: packageData,
      collection: 'Packages',
      operation: OperationType.create,
      fileFields: {
        'mainPicPath': 'PackageImages',
        'videoPath': 'PackageVideos',
      },
    );
  }

  Future<void> updateExistingPackage(
      String packageId, Map<String, dynamic> updates) async {
    await handleData(
      dataType: 'package',
      newData: updates,
      collection: 'Packages',
      operation: OperationType.update,
      documentId: packageId,
      fileFields: {
        'mainPicPath': 'PackageImages',
        'videoPath': 'PackageVideos',
      },
    );
  }

  // Search functionality

  List<String> generateSearchVariations(String input) {
    if (input.isEmpty) return [];

    // Initialize set to avoid duplicates
    Set<String> variations = {};

    // Convert input to lowercase and trim
    input = input.toLowerCase().trim();

    // Split the input into individual words
    List<String> words = input
        .split(RegExp(
            r'[\s\-_,.]')) // Split on spaces, hyphens, underscores, commas, periods
        .where((word) => word.isNotEmpty)
        .toList();

    // Add the complete original input
    variations.add(input);

    // Add individual words
    variations.addAll(words);

    // Generate prefix variations for the complete input
    for (int i = 1; i <= input.length; i++) {
      variations.add(input.substring(0, i));
    }

    // Generate variations for each individual word
    for (String word in words) {
      // Add prefixes of each word
      for (int i = 1; i <= word.length; i++) {
        variations.add(word.substring(0, i));
      }
    }

    // Generate combinations of adjacent words
    for (int windowSize = 2; windowSize <= words.length; windowSize++) {
      for (int i = 0; i <= words.length - windowSize; i++) {
        variations.add(words.sublist(i, i + windowSize).join(' '));
      }
    }

    // Generate variations with word removal
    if (words.length > 1) {
      for (int i = 0; i < words.length; i++) {
        List<String> wordsWithoutOne = List.from(words);
        wordsWithoutOne.removeAt(i);
        variations.add(wordsWithoutOne.join(' '));
      }
    }

    // Handle common word variations, plurals, and misspellings
    Set<String> enhancedVariations = <String>{};
    for (String variation in variations) {
      // Handle plurals
      if (variation.endsWith('s')) {
        enhancedVariations
            .add(variation.substring(0, variation.length - 1)); // singular
      } else {
        enhancedVariations.add('${variation}s'); // plural
      }

      // Handle common endings
      if (variation.endsWith('ing')) {
        String base = variation.substring(0, variation.length - 3);
        enhancedVariations.addAll([
          base,
          '${base}ed',
          '${base}er',
        ]);
      }

      // Handle 'y' to 'ies' conversion
      if (variation.endsWith('y')) {
        enhancedVariations
            .add('${variation.substring(0, variation.length - 1)}ies');
      }
      if (variation.endsWith('ies')) {
        enhancedVariations
            .add('${variation.substring(0, variation.length - 3)}y');
      }

      // Handle common misspellings and alternate spellings
      final commonReplacements = {
        'christmas': ['xmas', 'christmass', 'cristmas'],
        'birthday': ['bday', 'b-day'],
        'gift': ['present', 'presents', 'gifting'],
        'special': ['speciel', 'speciall'],
        'occasion': ['ocasion', 'occassion'],
        'wedding': ['weding', 'wed'],
        'anniversary': ['anniversery', 'aniversary'],
        'celebration': ['celebration', 'celeb'],
        'party': ['partie', 'partey'],
        'holiday': ['holliday', 'hoilday'],
        'valentine': ['valentines', 'valentine\'s'],
        'halloween': ['haloween', 'hallowen'],
        'thanksgiving': ['thanks giving', 'thanks-giving'],
        'graduation': ['grad', 'graduation'],
        'restaurant': ['resto', 'restraunt'],
        'photography': ['foto', 'photografy'],
        'catering': ['katering', 'catering'],
        'decoration': ['decor', 'deco'],
      };

      // Add common variations
      for (var entry in commonReplacements.entries) {
        if (variation.contains(entry.key)) {
          enhancedVariations.addAll(entry.value);
          // Also add combinations with the variations
          for (String alternate in entry.value) {
            enhancedVariations.add(variation.replaceAll(entry.key, alternate));
          }
        }
      }

      // Add fuzzy variations using character substitutions
      final commonSubstitutions = {
        'a': ['@'],
        'e': ['3'],
        'i': ['1'],
        'o': ['0'],
        's': ['5', 'z'],
        'z': ['s'],
      };

      // Generate variations with character substitutions
      for (var char in commonSubstitutions.entries) {
        if (variation.contains(char.key)) {
          for (String substitute in char.value) {
            enhancedVariations.add(variation.replaceAll(char.key, substitute));
          }
        }
      }
    }

    // Add all enhanced variations to the original set
    variations.addAll(enhancedVariations);

    // Calculate Levenshtein distance for similar words
    Set<String> fuzzyMatches = {};
    List<String> variationsList = variations.toList();

    for (int i = 0; i < variationsList.length; i++) {
      for (int j = i + 1; j < variationsList.length; j++) {
        if (_calculateSimilarity(variationsList[i], variationsList[j]) >= 0.8) {
          fuzzyMatches.add(variationsList[i]);
          fuzzyMatches.add(variationsList[j]);
        }
      }
    }

    variations.addAll(fuzzyMatches);

    // Sort by length and return as list
    return variations.toList()..sort((a, b) => a.length.compareTo(b.length));
  }

// Helper function to calculate string similarity
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    int distance = _calculateLevenshteinDistance(s1, s2);

    return 1 - (distance / maxLength);
  }

// Helper function to calculate Levenshtein distance
  int _calculateLevenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce(min);
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  // User management
  Future<void> createOrUpdateUser(
      String name, String username, String userId) async {
    final nameSearchVariations = generateSearchVariations(name);
    final usernameSearchVariations = generateSearchVariations(username);

    await handleData(
      dataType: 'profile',
      newData: {
        'name': name,
        'username': username,
        'searchName': nameSearchVariations,
        'searchUsername': usernameSearchVariations,
      },
      collection: 'Customers',
      operation: OperationType.update,
      documentId: userId,
    );
  }

  // Service management
  Future<void> initializeServiceTypes() async {
    try {
      _isLoadingServices = true;
      notifyListeners();

      final snapshot = await _fireStore.collection('Services').get();
      _serviceTypes = snapshot.docs
          .map((doc) => (doc.data()['name'] as String?) ?? '')
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort();
    } catch (e) {
      print('Error initializing service types: $e');
      _serviceTypes = [
        'Accommodation',
        'Event Planning',
        'Photography',
        'Catering'
      ];
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  // Cart management
  Future<bool> updateCartItem(Map<String, dynamic> data,
      {bool isEditing = false}) async {
    try {
      await handleData(
        dataType: 'cart',
        newData: data,
        collection: 'Cart',
        operation: isEditing ? OperationType.update : OperationType.create,
        documentId: isEditing ? data['orderId'] : uuid.v4(),
      );
      return true;
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }

  Future<void> removeFromCart(String orderId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final collections = ['Cart', 'Confirmations', 'Pending', 'Shared Carts'];

      for (final collection in collections) {
        final querySnapshot = await _fireStore
            .collection(collection)
            .where('orderId', isEqualTo: orderId)
            .where('userId', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
          print('Item removed from $collection');
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  // Helper methods
  double extractNumericRate(String rateStr) {
    final cleanedRate =
        rateStr.split('/').first.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanedRate) ?? 0.0;
  }

  Future<double> calculateCartTotal() async {
    double total = 0.0;
    final packagesCollection = _fireStore.collection('Packages');

    for (var item in _dataStore['bookings'] as List<Map<String, dynamic>>) {
      try {
        final packageDoc =
            await packagesCollection.doc(item['package_id']).get();
        if (!packageDoc.exists) continue;

        final packageData = packageDoc.data();
        if (packageData?.containsKey('rate') != true) continue;

        final rate = extractNumericRate(packageData!['rate'].toString());
        final quantity = item['quantity'] ?? 1;
        total += rate * quantity;
      } catch (e) {
        print('Error calculating total for package ${item['package_id']}: $e');
      }
    }

    return total;
  }

  void setImage(String dataType, String fieldName, File? image) {
    if (!_dataStore.containsKey(dataType)) {
      _dataStore[dataType] = {};
    }

    if (image == null) {
      _dataStore[dataType]?.remove(fieldName);
    } else {
      _dataStore[dataType]![fieldName] = image.path;
    }
    notifyListeners();
  }

  File? getImage(String dataType, String fieldName) {
    try {
      final path = _dataStore[dataType]?[fieldName];
      if (path == null || path.isEmpty) {
        return null;
      }

      final file = File(path);
      return file.existsSync() ? file : null;
    } catch (e) {
      print('Error getting image for $dataType.$fieldName: $e');
      return null;
    }
  }

  // Helper method to check if an image exists
  bool hasImage(String dataType, String fieldName) {
    final path = _dataStore[dataType]?[fieldName];
    if (path == null || path.isEmpty) {
      return false;
    }
    return File(path).existsSync();
  }

  // Helper method to clear an image
  void clearImage(String dataType, String fieldName) {
    _dataStore[dataType]?.remove(fieldName);
    notifyListeners();
  }
}
