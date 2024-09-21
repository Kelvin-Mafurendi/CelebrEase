import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  //get instance of firebase auth
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //get current user
User? getCurrentUser(){
  return _firebaseAuth.currentUser;
}

  //login 
Future<UserCredential> signInwithEmailPassword(String email,password) async{
  try{
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }
  on FirebaseAuthException catch(e){
    throw Exception(e.code);
  }

}
  //sign Up
Future<UserCredential> signUpwithEmailPassword(String email,password) async{
  try{
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }
  on FirebaseAuthException catch(e){
    throw Exception(e.code);
  }

}
  //LogOut
  // ignore: non_constant_identifier_names
  Future<void> SignOut() async {
    return await _firebaseAuth.signOut();}

    // Check if user is logged in
  bool isUserLoggedIn() {
  return _firebaseAuth.currentUser != null;
}
}