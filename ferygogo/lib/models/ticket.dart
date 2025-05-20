import 'passenger.dart';
import 'vehicle_category.dart';
import 'ship.dart';
import '../services/ship_service.dart';

class Ticket {
  final String id;
  final String routeName;
  final String departurePort;
  final String arrivalPort;
  final DateTime departureTime;
  final double price;
  String? shipName; // now nullable, will be set after fetching from backend
  final String ticketClass;
  final String status;
  final Map<PassengerType, int> passengerCounts;
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
    this.shipName,
    required this.ticketClass,
    required this.status,
    this.passengerCounts = const {},
    this.passengers = const [],
    this.bookerName = '',
    this.bookerPhone = '',
    this.bookerEmail = '',
    this.vehicleCategory,
    this.vehiclePlateNumber,
  });

  Future<void> assignShipNameByType(String type) async {
    // type: 'reguler' atau 'express'
    // This method should be called after creating the Ticket object
    final shipService = ShipService();
    final ship = await shipService.getRandomActiveShipByType(type);
    if (ship != null) {
      shipName = ship.name;
    } else {
      throw Exception('No active ship found for type: $type');
    }
  }

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
}