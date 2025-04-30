import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/error_handler.dart';
import './profile_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider() {
    init();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isInitialized => _initialized;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    if (!_initialized) {
      int retry = 0;
      while (!_initialized && retry < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        retry++;
      }
      if (!_initialized) {
        throw Exception('Failed to initialize authentication state');
      }
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _setError(e.toString());
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user profile in Auth collection
      final profileProvider = ProfileProvider();
      await profileProvider.createNewUserProfile(userCredential.user!.uid, email);

    } catch (e) {
      _setError(e.toString());
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      throw e;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(ErrorHandler.getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Silakan coba lagi.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;
      
      final snapshot = await _database
          .child('users/${currentUser!.uid}')
          .get();
      
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      _setError('Gagal mengambil data profil');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) return false;
      
      await _database
          .child('users/${currentUser!.uid}')
          .update(data);
      
      return true;
    } catch (e) {
      _setError('Gagal memperbarui profil');
      return false;
    }
  }

  void init() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      _initialized = true;
      notifyListeners();
    }, onError: (error) {
      _setError('Error initializing auth: $error');
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}