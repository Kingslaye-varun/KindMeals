import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Starting Firebase sign in with email: $email');

      // Check if user is already signed in
      if (_auth.currentUser != null) {
        developer.log('User already signed in, signing out first');
        await _auth.signOut();
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log('Firebase sign in successful: ${userCredential.user?.uid}');

      // Force a token refresh to ensure the user is properly authenticated
      await userCredential.user?.getIdToken(true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred during sign in: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('Error during sign in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      developer.log('Starting Firebase sign up with email: $email');

      // Check if user is already signed in
      if (_auth.currentUser != null) {
        developer.log('User already signed in, signing out first');
        await _auth.signOut();
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log('Firebase sign up successful: ${userCredential.user?.uid}');

      // Verify the user is properly authenticated
      if (userCredential.user == null) {
        throw Exception(
            'Failed to create user: No user returned from Firebase');
      }

      // Force a token refresh to ensure the user is properly authenticated
      await userCredential.user?.getIdToken(true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already in use. Please use a different email or login.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An error occurred during sign up: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('Error during sign up: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      developer.log('Starting Google sign in');

      // Check if user is already signed in
      if (_auth.currentUser != null) {
        developer.log('User already signed in, signing out first');
        await _auth.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in was aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      developer.log('Google sign in successful: ${userCredential.user?.uid}');

      // Force a token refresh to ensure the user is properly authenticated
      await userCredential.user?.getIdToken(true);

      return userCredential;
    } catch (e) {
      developer.log('Error during Google sign in: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      developer.log('Starting Firebase sign out');
      await _auth.signOut();
      developer.log('Firebase sign out successful');
    } catch (e) {
      developer.log('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-not-found':
          throw Exception('No user found with this email.');
        default:
          throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while sending password reset email.');
    }
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password (alias for signUpWithEmailAndPassword for clarity)
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return signUpWithEmailAndPassword(email, password);
  }

  // Register user role with backend
  Future<void> registerUserRole(String email, String role) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      developer.log('Registering user role: $role for email: $email');

      // This is handled by the API service when registering specific user types
      // Just a placeholder method for compatibility
      developer.log(
          'User role registration handled by individual registration endpoints');

      return;
    } catch (e) {
      developer.log('Error registering user role: $e');
      throw Exception('Failed to register user role: $e');
    }
  }

  // Get the current user's ID token
  Future<String?> getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Force refresh to ensure token is up-to-date
        return await user.getIdToken(true);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting ID token: $e');
      }
      return null;
    }
  }
}
