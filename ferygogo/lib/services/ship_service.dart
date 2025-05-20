import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/ship.dart';

class ShipService {
  final _shipsRef = FirebaseFirestore.instance.collection('kapal');

  Future<List<Ship>> getShipsByType(String type) async {
    final query = await _shipsRef
        .where('type', isEqualTo: type)
        .where('status', isEqualTo: 'active')
        .get();
    return query.docs
        .map((doc) => Ship.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<Ship?> getFirstActiveShipByType(String type) async {
    final ships = await getShipsByType(type);
    if (ships.isNotEmpty) {
      return ships.first;
    }
    return null;
  }

  Future<Ship?> getRandomActiveShipByType(String type) async {
    final ships = await getShipsByType(type);
    if (ships.isNotEmpty) {
      final random = Random();
      return ships[random.nextInt(ships.length)];
    }
    return null;
  }
}
