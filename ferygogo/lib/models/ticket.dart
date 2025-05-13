import 'passenger.dart';
import 'vehicle_category.dart';

class Ticket {
  final String id;
  final String routeName;
  final String departurePort;
  final String arrivalPort;
  final DateTime departureTime;
  final double price;
  final String shipName;
  final String ticketClass;
  final String status;  final Map<PassengerType, int> passengerCounts;
  final List<Passenger> passengers;
  final String bookerName;
  final String bookerPhone;
  final String bookerEmail;
  final VehicleCategory? vehicleCategory;
  final String? vehiclePlateNumber;
  Ticket({
    required this.id,
    required this.routeName,
    required this.departurePort,
    required this.arrivalPort,
    required this.departureTime,
    required this.price,
    required this.shipName,
    required this.ticketClass,
    required this.status,
    this.passengerCounts = const {},
    this.passengers = const [],
    this.bookerName = '',
    this.bookerPhone = '',
    this.bookerEmail = '',    this.vehicleCategory,
    this.vehiclePlateNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'routeName': routeName,
    'departurePort': departurePort,
    'arrivalPort': arrivalPort,
    'departureTime': departureTime.toIso8601String(),
    'price': price,
    'shipName': shipName,
    'ticketClass': ticketClass,
    'status': status,
    'passengerCounts': passengerCounts.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'passengers': passengers.map((p) => p.toJson()).toList(),
    'bookerName': bookerName,
    'bookerPhone': bookerPhone,
    'bookerEmail': bookerEmail,
    'vehicleCategory': vehicleCategory?.toString(),
    'vehiclePlateNumber': vehiclePlateNumber,
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
        price: 150000,
        shipName: "KMP Gajah Mada",
        ticketClass: "Ekonomi",
        status: "Aktif",
      ),
      Ticket(
        id: "T002",
        routeName: "Merak - Bakauheni",
        departurePort: "Pelabuhan Merak",
        arrivalPort: "Pelabuhan Bakauheni",
        departureTime: DateTime.now().add(const Duration(days: 2)),
        price: 200000,
        shipName: "KMP Jatra III",
        ticketClass: "Bisnis",
        status: "Aktif",
      ),
      Ticket(
        id: "T003",
        routeName: "Ketapang - Gilimanuk",
        departurePort: "Pelabuhan Ketapang",
        arrivalPort: "Pelabuhan Gilimanuk",
        departureTime: DateTime.now().add(const Duration(days: 3)),
        price: 175000,
        shipName: "KMP Dharma Rucitra",
        ticketClass: "Eksekutif",
        status: "Aktif",
      ),
    ];
  }
}