import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String name;
  final String type;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final double availability;

  Schedule({
    required this.id,
    required this.name,
    required this.type,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availability,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> map) {
    return Schedule(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'regular',
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      arrivalTime: (map['arrivalTime'] as Timestamp).toDate(),
      price: (map['price'] as num).toDouble(),
      availability: (map['availability'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'departureTime': Timestamp.fromDate(departureTime),
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'price': price,
      'availability': availability,
    };
  }
}