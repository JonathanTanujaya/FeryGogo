import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> favorites = [];

  Future<void> addToFavorites(String userId, Map<String, dynamic> scheduleData) async {
    try {
      await _database.child('favorites/$userId').push().set(scheduleData);
      favorites.add(scheduleData);
      notifyListeners();
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String favoriteId) async {
    try {
      await _database.child('favorites/$userId/$favoriteId').remove();
      favorites.removeWhere((favorite) => favorite['id'] == favoriteId);
      notifyListeners();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  Future<void> loadFavorites(String userId) async {
    try {
      final snapshot = await _database.child('favorites/$userId').get();
      if (snapshot.exists) {
        favorites = [];
        Map<dynamic, dynamic> values = snapshot.value as Map;
        values.forEach((key, value) {
          Map<String, dynamic> favorite = Map<String, dynamic>.from(value);
          favorite['id'] = key;
          favorites.add(favorite);
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }
}