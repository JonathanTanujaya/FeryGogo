import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  StreamSubscription<User?>? _authStateSubscription;
  User? _currentUser;

  AuthProvider() {
    init();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _initialized;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _updateUser(User? user) {
    if (_currentUser?.uid != user?.uid) {
      _currentUser = user;
      notifyListeners();
    }
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
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      print('AuthProvider: Starting sign in process');
      
      // Perform sign in
      print('AuthProvider: Calling auth service signIn');
      final credential = await _authService.signIn(email, password);
      
      if (credential.user == null) {
        throw Exception('Gagal mendapatkan data pengguna');
      }
      
      // Update user state
      _updateUser(credential.user);
      _initialized = true;
      print('AuthProvider: User updated successfully - ${credential.user?.uid}');
      
    } on FirebaseAuthException catch (e) {
      print('AuthProvider: FirebaseAuthException caught - ${e.code}: ${e.message}');
      final message = ErrorHandler.getAuthErrorMessage(e);
      _setError(message);
    } catch (e) {
      print('AuthProvider: General error caught - $e');
      _setError('Terjadi kesalahan saat login');
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

      // Wait for auth state to be properly updated
      await Future.delayed(const Duration(milliseconds: 500));
      await checkAuthState();
    } on FirebaseAuthException catch (e) {
      final message = ErrorHandler.getAuthErrorMessage(e);
      _setError(message);
      throw Exception(message);
    } catch (e) {
      _setError('Terjadi kesalahan saat mendaftar');
      throw Exception('Terjadi kesalahan saat mendaftar');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _updateUser(null);
    } catch (e) {
      _setError('Terjadi kesalahan saat logout');
      throw Exception('Terjadi kesalahan saat logout');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      final message = ErrorHandler.getAuthErrorMessage(e);
      _setError(message);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan saat mereset password');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;
      return await _authService.getUserProfile(_currentUser!.uid);
    } catch (e) {
      _setError('Gagal mengambil data profil');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) return false;
      await _authService.updateUserProfile(_currentUser!.uid, data);
      return true;
    } catch (e) {
      _setError('Gagal memperbarui profil');
      return false;
    }
  }

  void init() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        _initialized = true;
        _updateUser(user);
      },
      onError: (error) {
        _setError('Error initializing auth: $error');
        _initialized = true;
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}