
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/modules/service.dart';

class FirestoreService {
  //get collection of members/service providers
  final CollectionReference serviceProdviders = FirebaseFirestore.instance.collection('serviceProviders');
  //Create service providers
  Future<void> addserviceProviderToDatabase(ServiceProvider serviceProvider, UserCredential userCredential) async{
    await serviceProdviders.add(
      {'member since': DateTime.now(),
      'name': serviceProvider.brand,
      'email': userCredential ,
      


      
      }

    );
  }
  //Read servicesw formm db

  //Update service databse

  //delete service providers
  
}