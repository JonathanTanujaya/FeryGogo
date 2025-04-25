class Booking {
  final String id;
  final String userId;
  final String routeName;
  final String date;
  final String status;
  final int quantity;
  final double totalPrice;
  final String departureTime;
  final String arrivalTime;
  final String routeType;

  Booking({
    required this.id,
    required this.userId,
    required this.routeName,
    required this.date,
    required this.status,
    required this.quantity,
    required this.totalPrice,
    required this.departureTime,
    required this.arrivalTime,
    required this.routeType,
  });

  factory Booking.fromMap(String id, Map<dynamic, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      routeName: map['routeName'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Pending',
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      routeType: map['routeType'] ?? 'regular',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'routeName': routeName,
      'date': date,
      'status': status,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'routeType': routeType,
    };
  }

  Booking copyWith({
    String? routeName,
    String? date,
    String? status,
    int? quantity,
    double? totalPrice,
    String? departureTime,
    String? arrivalTime,
    String? routeType,
  }) {
    return Booking(
      id: this.id,
      userId: this.userId,
      routeName: routeName ?? this.routeName,
      date: date ?? this.date,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      routeType: routeType ?? this.routeType,
    );
  }
}