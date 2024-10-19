import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/pages/dynamic_package_form.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';

class AddPackage extends StatefulWidget {
  final Map<String, dynamic> initialData;
  
  const AddPackage({
    Key? key,
    this.initialData = const {},
  }) : super(key: key);

  @override
  State<AddPackage> createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  String? serviceType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceType();
  }

  Future<void> _loadServiceType() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Vendors')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          setState(() {
            serviceType = doc.data()?['category'] as String?;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading service type: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (serviceType == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Please set your service category in your profile first.'),
        ),
      );
    }

    // Merge initialData with service type
    final Map<String, dynamic> formData = {
      ...widget.initialData,
      'serviceType': serviceType,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Package'),
        elevation: 0,
      ),
      body: SafeArea(
        child: DynamicPackageForm(
          serviceType: serviceType!,
          initialData: formData,
        ),
      ),
    );
  }
}