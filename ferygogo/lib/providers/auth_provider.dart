import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider() {
    init();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
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
      await _authService.signIn(email, password);
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
      await _authService.signUp(
        name: name,
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

  Future<void> signOut() async {
    try {
      await _authService.signOut();
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
      await _authService.resetPassword(email);
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
      return await _authService.getUserProfile(currentUser!.uid);
    } catch (e) {
      _setError('Gagal mengambil data profil');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) return false;
      await _authService.updateUserProfile(currentUser!.uid, data);
      return true;
    } catch (e) {
      _setError('Gagal memperbarui profil');
      return false;
    }
  }

  void init() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
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