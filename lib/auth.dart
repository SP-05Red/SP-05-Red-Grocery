import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Authentication class that interacts with Firebase Authentication
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter for the current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream providing changes in authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Asynchronous method to sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Asynchronous method to create a new user with email and password
  // Store userID and email into collection
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After creating the user, add the UID and email to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'UID': userCredential.user!.uid,
        'email': userCredential.user!.email,
      });
    } catch (e) {
      print("Error creating user: $e");
      throw e; // Rethrow the error for handling in UI
    }
  }

  // Asynchronous method to sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
