import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ensure user document exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': userCredential.user?.displayName ?? '',
          'phoneNumber': '',
          'gender': '',
          'birthDate': '',
          'identityType': '',
          'identityNumber': '',
          'profilePicture': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create initial user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phoneNumber': '',
        'gender': '',
        'birthDate': '',
        'identityType': '',
        'identityNumber': '',
        'profilePicture': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update display name in Firebase Auth
      await userCredential.user?.updateDisplayName(name);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('Email tidak terdaftar');
        case 'wrong-password':
          return Exception('Password salah');
        case 'email-already-in-use':
          return Exception('Email sudah terdaftar');
        case 'invalid-email':
          return Exception('Format email tidak valid');
        case 'weak-password':
          return Exception('Password terlalu lemah');
        default:
          return Exception(error.message ?? 'Terjadi kesalahan autentikasi');
      }
    }
    return Exception('Terjadi kesalahan: $error');
  }
}