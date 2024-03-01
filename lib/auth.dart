import 'package:firebase_auth/firebase_auth.dart';

// Authentication class that interacts with Firebase Authentication
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Asynchronous method to sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
