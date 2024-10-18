// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maroro/pages/cart.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class ChangeManager extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, dynamic> _profileData = {};
  final Map<String, dynamic> _bookingForm = {};
  
  var uuid = Uuid();

  Map<String, dynamic> get profileData => _profileData;
  Map<String, dynamic> get highlightData => _highlight;
  Map<String, dynamic> get packageData => _package;
  Map<String, dynamic> get flashAd => _flashAd;
  Map<String, dynamic> get bookingForm => _bookingForm;


  Future<void> loadProfiledata(
      Map<String, dynamic> newData, String userType) async {
    EasyLoading.show();

    try {
      // Handle profile image update
      if (newData['imagePath'] != null && newData['imagePath'] is File) {
        String downloadUrl =
            await uploadProfileImageToStorage(newData['imagePath']);
        newData['imagePath'] = downloadUrl;
      }

      // Update only the fields that have changed
      newData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          _profileData[key] = value;
        }
      });

      _profileData['timeStamp'] = DateTime.now().toString();

      // Upload the modified _profileData to the database
      await updateProfileDataInDatabase(_profileData, userType);

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      // Handle error (e.g., show error message to user)
    } finally {
      EasyLoading.dismiss();
    }
  }

  void changeProfiledata(Map<String, dynamic> newData, String userType) async {
    EasyLoading.show();

    // Check if there's an image to upload
    if (_profileData['imagePath'] != null) {
      // Upload image to storage and update the imagePath
      _profileData['imagePath'] =
          await uploadProfileImageToStorage(File(_profileData['imagePath']));
    }

    // Iterate over newData and update only non-null fields in _profileData
    newData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        _profileData[key] = value; // Update if new data is non-empty
      }
      // Otherwise, keep the existing _profileData[key] unchanged
    });
    _profileData['timeStamp'] = DateTime.now().toString();
    _profileData['userType'] = userType;

    // Upload the modified _profileData to the database
    await uploadProfileDataToDatabase(_profileData, userType).whenComplete(() {
      EasyLoading.dismiss();
    });

    notifyListeners(); // Notify listeners of changes
  }

  String getProfileValue(String key) {
    return _profileData[key] ?? '';
  }

  void setProfileImage(File image) async {
    _profileData['imagePath'] = image.path;
    notifyListeners();
  }

  File? getProfileImage() {
    return _profileData['imagePath'] != null
        ? File(_profileData['imagePath'])
        : null;
  }

  uploadProfileImageToStorage(File image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('ProfilePictures')
        .child(path.basename(image.path));
    UploadTask uploadTask = ref.putData(image.readAsBytesSync());
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadLink = await taskSnapshot.ref.getDownloadURL();
    return downloadLink;
  }

  Future<void> updateProfileDataInDatabase(
      Map<String, dynamic> data, String userType) async {
    await _fireStore
        .collection(userType)
        .doc(_auth.currentUser!.uid)
        .update(data);
  }

  // This method remains unchanged for new user signups
  Future<void> uploadProfileDataToDatabase(
      Map<String, dynamic> data, String userType) async {
    await _fireStore.collection(userType).doc(_auth.currentUser!.uid).set(data);
  }

  ///Working with featured products
  final Map<String, dynamic> _highlight = {
    'packageName': '',
    'rate': '',
    'description': '',
    'mainPicPath': '',
    'views': '',
    'likes': '',
  };

  //updating featured products
  void updateHighlight(Map<String, dynamic> newData) async {
    EasyLoading.show();
    try {
      // Handle file uploads first
      if (newData['videoPath'] != null) {
        newData['videoPath'] =
            await uploadHighlightVideoToStorage(File(newData['videoPath']));
      } else {
        // If no video is provided, remove the videoPath field if it exists
        _highlight.remove('videoPath');
      }

      if (newData['mainPicPath'] != null) {
        newData['mainPicPath'] = await uploadHighlightMainImageToStorage(
            File(newData['mainPicPath']));
      }

      // Update fields in _highlight
      newData.forEach((key, value) {
        if (value != null) {
          _highlight[key] = value; // Update if new data is non-null
        }
      });

      _highlight['userId'] = _auth.currentUser!.uid.toString();
      _highlight['timeStamp'] = DateTime.now().toString();

      // Remove any null or empty string values from _highlight
      _highlight.removeWhere((key, value) => value == null || value == '');

      // Upload the updated _highlight to the database
      await uploadHightlightDataToDatabase(_highlight);
      notifyListeners();
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Error updating highlight: $e');
      // Handle error (e.g., show error message to user)
    } finally {
      EasyLoading.dismiss();
    }
  }

  uploadHighlightMainImageToStorage(File image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('HighlightsmainImages')
        .child(path.basename(image.path));
    UploadTask uploadTask = ref.putData(image.readAsBytesSync());
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadLink = await taskSnapshot.ref.getDownloadURL();
    return downloadLink;
  }

  uploadOtherHighlightImagesToStorage(List<File> images) async {
    List<String> highlights = [];
    for (int i = 0; i < images.length; i++) {
      Reference ref = _firebaseStorage
          .ref()
          .child('HighlightsmainImages')
          .child(path.basename(images[i].path));
      UploadTask uploadTask = ref.putData(images[i].readAsBytesSync());
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadLink = await taskSnapshot.ref.getDownloadURL();
      highlights.add(downloadLink);
    }
    return highlights;
  }

  uploadHighlightVideoToStorage(File video) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('HighlightsmainImages')
        .child(path.basename(video.path));
    UploadTask uploadTask = ref.putData(video.readAsBytesSync());
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadLink = await taskSnapshot.ref.getDownloadURL();
    return downloadLink;
  }

  uploadHightlightDataToDatabase(Map<String, dynamic> data) async {
    await _fireStore
        .collection('Highlights')
        .doc()
        .set(data); //use a userid instead of email adress, more ethical
  }

  void setHighlightImage(File image) async {
    _highlight['mainPicPath'] = image.path;
    notifyListeners();
  }

  void setHighlightVideo(File image) async {
    _highlight['videoPath'] = image.path;
    notifyListeners();
  }

  void setOtherHighlightImages(List<File> images) async {
    List<String> imgs = images.map((file) => file.path).toList();
    _highlight['otherPicspath'] = imgs;
    notifyListeners();
  }

  File? getHighlightImage() {
    return _highlight['mainPicPath'] != null
        ? File(_highlight['mainPicPath'])
        : null;
  }

  File? getHighlightVideo() {
    return _highlight['videoPath'] != null
        ? File(_highlight['videoPath'])
        : null;
  }

  File? getOtherHighlightImages() {
    final paths = _highlight['otherPicspath'] as List<String>?;
    if (paths != null && paths.isNotEmpty) {
      return File(paths[0]);
    } else {
      return null;
    }
  }

  //Package handling
  final Map<String, dynamic> _package = {
    'packageName': '',
    'rate': '',
    'description': '',
    'mainPicPath': '',
    'views': '',
    'likes': '',
  };

  //updating featured products
  void updatePackage(Map<String, dynamic> newData) async {
    EasyLoading.show();
    try {
      print('Starting package update with data: $newData');

      if (newData['mainPicPath'] != null) {
        print('Uploading package image');
        newData['mainPicPath'] =
            await uploadPackageImageToStorage(File(newData['mainPicPath']));
        print('Image uploaded successfully: ${newData['mainPicPath']}');
      }

      newData.forEach((key, value) {
        if (value != null) {
          _package[key] = value;
        }
      });

      _package['userId'] = _auth.currentUser!.uid.toString();
      _package['timeStamp'] = DateTime.now().toString();

      // Fetch user profile data
      DocumentSnapshot userProfileDoc = await _fireStore
          .collection('Vendors')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userProfileDoc.exists) {
        var userProfile = userProfileDoc.data() as Map<String, dynamic>?;
        String? category = userProfile?['category'] as String?;
        if (category != null) {
          _package['category'] = category;
          print('Category set from user profile: $category');
        } else {
          print('Category not found in user profile');
        }
      } else {
        print('User profile document does not exist');
      }
      _package.removeWhere((key, value) => value == null || value == '');

      print('Prepared package data for upload: $_package');

      // Upload to database
      await uploadPackageDataToDatabase(_package);
      print('Package data uploaded successfully');

      notifyListeners();
      print('Notified listeners of changes');
    } catch (e, stackTrace) {
      print('Error updating package: $e');
      print('Stack trace: $stackTrace');
      // Rethrow the error so it can be caught in the UI
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  uploadPackageImageToStorage(File image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('Package Images')
        .child(path.basename(image.path));
    UploadTask uploadTask = ref.putData(image.readAsBytesSync());
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadLink = await taskSnapshot.ref.getDownloadURL();
    return downloadLink;
  }

  Future<void> uploadPackageDataToDatabase(Map<String, dynamic> data) async {
    try {
      print('Attempting to upload package data: $data');
      await _fireStore.collection('Packages').doc().set(data);
      print('Package data uploaded successfully');
    } catch (e, stackTrace) {
      print('Error in uploadPackageDataToDatabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void setPackageImage(File image) async {
    _package['mainPicPath'] = image.path;
    notifyListeners();
  }

  File? getPackageImage() {
    return _package['mainPicPath'] != null
        ? File(_package['mainPicPath'])
        : null;
  }

  //Package handling
  final Map<String, dynamic> _flashAd = {};

  //updating featured products
  void updateFlashAd(Map<String, dynamic> newData) async {
    EasyLoading.show();
    try {
      print('Starting package update with data: $newData');

      if (newData['mainPicPath'] != null) {
        print('Uploading package image');
        newData['mainPicPath'] =
            await uploadFlashImageToStorage(File(newData['mainPicPath']));
        print('Image uploaded successfully: ${newData['mainPicPath']}');
      }

      newData.forEach((key, value) {
        if (value != null) {
          _flashAd[key] = value;
        }
      });

      _flashAd['userId'] = _auth.currentUser!.uid.toString();
      _flashAd['timeStamp'] = DateTime.now().toString();

      // Fetch user profile data
      DocumentSnapshot userProfileDoc = await _fireStore
          .collection('Vendors')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userProfileDoc.exists) {
        var userProfile = userProfileDoc.data() as Map<String, dynamic>?;
        String? category = userProfile?['category'] as String?;

        if (category != null) {
          _flashAd['category'] = category;
          print('Category set from user profile: $category');
        } else {
          print('Category not found in user profile');
        }
      } else {
        print('User profile document does not exist');
      }
      _flashAd.removeWhere((key, value) => value == null || value == '');

      print('Prepared package data for upload: $_flashAd');

      // Upload to database
      await uploadFlashDataToDatabase(_flashAd);
      print('Package data uploaded successfully');

      notifyListeners();
      print('Notified listeners of changes');
    } catch (e, stackTrace) {
      print('Error updating package: $e');
      print('Stack trace: $stackTrace');
      // Rethrow the error so it can be caught in the UI
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  uploadFlashImageToStorage(File image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('FlashAdImages')
        .child(path.basename(image.path));
    UploadTask uploadTask = ref.putData(image.readAsBytesSync());
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadLink = await taskSnapshot.ref.getDownloadURL();
    return downloadLink;
  }

  Future<void> uploadFlashDataToDatabase(Map<String, dynamic> data) async {
    try {
      print('Attempting to upload package data: $data');
      await _fireStore.collection('FlashAds').doc().set(data);
      print('Package data uploaded successfully');
    } catch (e, stackTrace) {
      print('Error in uploadPackageDataToDatabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void setFlashImage(File image) async {
    _flashAd['mainPicPath'] = image.path;
    notifyListeners();
  }

  File? getFlashImage() {
    return _flashAd['mainPicPath'] != null
        ? File(_flashAd['mainPicPath'])
        : null;
  }

   final List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> get bookings => _bookings;

  // Update the addToCart functionality
  Future<bool> updateForm(Map<String, dynamic> newData) async {
    try {
      // Create a new map to store the booking data
      final Map<String, dynamic> bookingData = {};
      
      // Copy all the non-null values from newData
      newData.forEach((key, value) {
        if (value != null) {
          bookingData[key] = value;
        }
      });

      // Add required fields
      bookingData['userId'] = _auth.currentUser!.uid.toString();
      bookingData['timeStamp'] = DateTime.now().toString();
      bookingData['orderId'] = uuid.v4(); // Generate unique ID for the cart item

      // Remove any null or empty values
      bookingData.removeWhere((key, value) => value == null || value == '');

      // Add to bookings list
      _bookings.add(bookingData);

      // Notify listeners that the cart has changed
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error updating Form: $e');
      return false;
    }
  }

  // Improve the removeFromCart functionality
  // In state_management.dart, update the removeFromCart method

void removeFromCart(String orderId) {
  print('Removing item with orderId: $orderId');
  
  final int index = _bookings.indexWhere((item) => item['orderId'] == orderId);
  
  if (index != -1) {
    _bookings.removeAt(index);
    print('Item removed successfully');
    
    notifyListeners();  // This will trigger a rebuild of the Cart widget
  } else {
    print('Item not found in cart');
  }
}
  // Helper method to extract numeric rate value
  double extractNumericRate(String rateStr) {
    // Remove currency symbols and everything after '/'
    String cleanedRate = rateStr.split('/').first; // Get everything before '/'
    
    // Remove all non-numeric characters except decimal point
    cleanedRate = cleanedRate.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Convert to double, default to 0 if parsing fails
    return double.tryParse(cleanedRate) ?? 0.0;
  }

  // Updated method to calculate cart total
  Future<double> calculateCartTotal() async {
  double total = 0.0;

  // Reference to the Firestore collection
  final packagesCollection = FirebaseFirestore.instance.collection('Packages');

  for (var item in _bookings) {
    // Get the package_id from the item
    String packageId = item['package_id'];

    // Fetch the package document from Firestore
    DocumentSnapshot packageDoc = await packagesCollection.doc(packageId).get();
    
    if (packageDoc.exists) {
      // Safely access the data
      var packageData = packageDoc.data() as Map<String, dynamic>?;

      // Check if packageData is not null and has a 'rate' field
      if (packageData != null && packageData.containsKey('rate')) {
        // Get the rate string
        String rateStr = packageData['rate']?.toString() ?? '0';

        // Use your existing method to extract the numeric value
        double rate = extractNumericRate(rateStr);

        // Multiply by quantity if it exists, otherwise use 1
        int quantity = item['quantity'] ?? 1;
        total += rate * quantity;
      } else {
        // Handle the case where the rate field doesn't exist
        print('Rate field does not exist for package with id $packageId.');
      }
    } else {
      // Handle the case where the package doesn't exist
      print('Package with id $packageId does not exist.');
    }
  }
  
  return total;
}

}
