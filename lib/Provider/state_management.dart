// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangeManager extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, dynamic> _profileData = {
    'brandName': '',
    'userType': 'Service Provider',
    'location': '',
    'category': '',
    'about': '',
    'startTime': '',
    'endTime': '',
    'imagePath': null,
    'imageName': ''
  };

  Map<String, dynamic> get profileData => _profileData;
  Map<String, dynamic> get highlightData => _highlight;
  Map<String, dynamic> get packageData => _package;
  loadProfileData(Map<String, dynamic> newData) async {
    newData.forEach((key, value) {
      if (value != null) {
        _profileData[key] = value;
      }
      notifyListeners();
    });
  }

  void changeProfiledata(Map<String, dynamic> newData) async {
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

    // Upload the modified _profileData to the database
    await uploadProfileDataToDatabase(_profileData).whenComplete(() {
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

  uploadProfileDataToDatabase(Map<String, dynamic> data) async {
    await _fireStore
        .collection('User Profiles')
        .doc(_auth.currentUser!.uid)
        .set(data); //use a userid instead of email adress, more ethical
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
}
