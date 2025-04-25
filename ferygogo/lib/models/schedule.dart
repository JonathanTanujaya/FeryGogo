class Schedule {
  final String id;
  final String name;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String type;
  final double availability;
  final double price;

  Schedule({
    required this.id,
    required this.name,
    required this.departureTime,
    required this.arrivalTime,
    required this.type,
    required this.availability,
    required this.price,
  });

  factory Schedule.fromMap(String id, Map<dynamic, dynamic> map) {
    return Schedule(
      id: id,
      name: map['name'] ?? '',
      departureTime: DateTime.parse(map['departureTime'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(map['arrivalTime'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? 'regular',
      availability: (map['availability'] ?? 1.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'type': type,
      'availability': availability,
      'price': price,
    };
  }
}