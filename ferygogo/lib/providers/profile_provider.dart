import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final int totalTrips;
  final List<String> favoriteRoutes;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.totalTrips,
    required this.favoriteRoutes,
  });
}

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final snapshot = await ref.get();
      
      if (snapshot.value != null) {
        final Map<dynamic, dynamic> value = 
            snapshot.value as Map<dynamic, dynamic>;
        
        List<String> favorites = [];
        if (value['favorite_routes'] != null) {
          favorites = (value['favorite_routes'] as List)
              .map((e) => e.toString())
              .toList();
        }

        _userProfile = UserProfile(
          id: user.uid,
          name: value['name'] ?? '',
          email: value['email'] ?? '',
          phoneNumber: value['phone_number'] ?? '',
          profilePicture: value['profile_picture'] ?? '',
          totalTrips: value['total_trips'] ?? 0,
          favoriteRoutes: favorites,
        );
      }
    } catch (error) {
      debugPrint('Error loading user profile: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    if (_isLoading || _userProfile == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final updates = <String, dynamic>{};
      
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (profilePicture != null) updates['profile_picture'] = profilePicture;

      await ref.update(updates);
      await loadUserProfile(); // Refresh profile data
    } catch (error) {
      debugPrint('Error updating profile: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteRoute(String route) async {
    if (_isLoading || _userProfile == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final List<String> updatedFavorites = 
          List.from(_userProfile!.favoriteRoutes);
      
      if (updatedFavorites.contains(route)) {
        updatedFavorites.remove(route);
      } else {
        updatedFavorites.add(route);
      }

      final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      await ref.update({
        'favorite_routes': updatedFavorites,
      });

      _userProfile = UserProfile(
        id: _userProfile!.id,
        name: _userProfile!.name,
        email: _userProfile!.email,
        phoneNumber: _userProfile!.phoneNumber,
        profilePicture: _userProfile!.profilePicture,
        totalTrips: _userProfile!.totalTrips,
        favoriteRoutes: updatedFavorites,
      );
    } catch (error) {
      debugPrint('Error toggling favorite route: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userProfile = null;
      notifyListeners();
    } catch (error) {
      debugPrint('Error signing out: $error');
    }
  }
}