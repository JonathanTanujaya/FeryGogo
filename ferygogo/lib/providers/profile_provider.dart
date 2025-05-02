import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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

  Map<String, dynamic> _sanitizeData(Map<dynamic, dynamic> data) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map((e) => MapEntry(e.key.toString(), e.value)),
    );
  }

  Future<void> createNewUserProfile(String uid, String email) async {
    try {
      final newProfile = {
        'email': email,
        'name': '',
        'phoneNumber': '',
        'gender': '',
        'birthDate': '',
        'identityType': '',
        'identityNumber': '',
        'profilePicture': '',
        'imageBase64': '', // Add imageBase64 field
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(newProfile);
    } catch (e) {
      _setError('Failed to create user profile: $e');
      throw e;
    }
  }

  Future<void> loadUserProfile() async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        // Ensure data is Map<String, dynamic>
        final sanitizedData = _sanitizeData(data);
        _userProfile = UserProfile.fromMap(
          _auth.currentUser!.uid,
          sanitizedData,
        );
        notifyListeners();
      } else {
        _setError('Profil tidak ditemukan');
      }
    } catch (e) {
      print('Error loading profile: $e');
      _setError('Gagal memuat profil: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
    String? identityType,
    String? identityNumber,
    String? profilePicture,
    String? imageBase64, // Add imageBase64 parameter
  }) async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (gender != null) updates['gender'] = gender;
      if (birthDate != null) updates['birthDate'] = birthDate.toIso8601String();
      if (identityType != null) updates['identityType'] = identityType;
      if (identityNumber != null) updates['identityNumber'] = identityNumber;
      if (profilePicture != null) updates['profilePicture'] = profilePicture;
      if (imageBase64 != null) updates['imageBase64'] = imageBase64; // Add imageBase64 update

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);

      // Update local state
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          name: name,
          phoneNumber: phoneNumber,
          gender: gender,
          birthDate: birthDate,
          identityType: identityType,
          identityNumber: identityNumber,
          profilePicture: profilePicture,
          imageBase64: imageBase64, // Add imageBase64 to copyWith
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore.collection('users').doc(user.uid).update({
        'profilePicture': imageUrl,
      });

      _userProfile = _userProfile?.copyWith(profilePicture: imageUrl);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
      throw e;
    }
  }
}