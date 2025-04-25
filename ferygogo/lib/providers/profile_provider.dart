import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final snapshot = await _database
          .child('users/${_auth.currentUser!.uid}')
          .get();

      if (snapshot.exists) {
        _userProfile = UserProfile.fromMap(
          _auth.currentUser!.uid,
          snapshot.value as Map<String, dynamic>,
        );
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    if (_auth.currentUser == null || _userProfile == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profilePicture != null) updates['profilePicture'] = profilePicture;

      await _database
          .child('users/${_auth.currentUser!.uid}')
          .update(updates);

      _userProfile = _userProfile!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
      );
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userProfile = null;
    } catch (e) {
      _setError('Failed to sign out: $e');
    }
  }
}