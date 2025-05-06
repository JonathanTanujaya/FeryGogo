import 'passenger.dart';

class Ticket {
  final String id;
  final String routeName;
  final String departurePort;
  final String arrivalPort;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String shipName;
  final String ticketClass;
  final int seatNumber;
  final String status;
  final Map<PassengerType, int> passengerCounts;
  final List<Passenger> passengers;

  double get totalPrice => price * passengers.length;

  Ticket({
    required this.id,
    required this.routeName,
    required this.departurePort,
    required this.arrivalPort,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.shipName,
    required this.ticketClass,
    required this.seatNumber,
    required this.status,
    this.passengerCounts = const {},
    this.passengers = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'routeName': routeName,
    'departurePort': departurePort,
    'arrivalPort': arrivalPort,
    'departureTime': departureTime.toIso8601String(),
    'arrivalTime': arrivalTime.toIso8601String(),
    'price': price,
    'shipName': shipName,
    'ticketClass': ticketClass,
    'seatNumber': seatNumber,
    'status': status,
    'passengerCounts': passengerCounts.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'passengers': passengers.map((p) => p.toJson()).toList(),
  };

  // Dummy data generator
  static List<Ticket> getDummyTickets() {
    return [
      Ticket(
        id: "T001",
        routeName: "Ketapang - Gilimanuk",
        departurePort: "Pelabuhan Ketapang",
        arrivalPort: "Pelabuhan Gilimanuk",
        departureTime: DateTime.now().add(const Duration(days: 1)),
        arrivalTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        price: 150000,
        shipName: "KMP Gajah Mada",
        ticketClass: "Ekonomi",
        seatNumber: 45,
        status: "Aktif",
      ),
      Ticket(
        id: "T002",
        routeName: "Merak - Bakauheni",
        departurePort: "Pelabuhan Merak",
        arrivalPort: "Pelabuhan Bakauheni",
        departureTime: DateTime.now().add(const Duration(days: 2)),
        arrivalTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
        price: 200000,
        shipName: "KMP Jatra III",
        ticketClass: "Bisnis",
        seatNumber: 23,
        status: "Aktif",
      ),
      Ticket(
        id: "T003",
        routeName: "Ketapang - Gilimanuk",
        departurePort: "Pelabuhan Ketapang",
        arrivalPort: "Pelabuhan Gilimanuk",
        departureTime: DateTime.now().add(const Duration(days: 3)),
        arrivalTime: DateTime.now().add(const Duration(days: 3, hours: 1)),
        price: 175000,
        shipName: "KMP Dharma Rucitra",
        ticketClass: "Eksekutif",
        seatNumber: 12,
        status: "Aktif",
      ),
    ];
  }
}