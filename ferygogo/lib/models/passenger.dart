class Passenger {
  final String name;
  final String idNumber;
  final String? phoneNumber;
  final String? email;
  final PassengerType type;
  final DateTime? birthDate;

  Passenger({
    required this.name,
    required this.idNumber,
    this.phoneNumber,
    this.email,
    required this.type,
    this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'idNumber': idNumber,
    'phoneNumber': phoneNumber,
    'email': email,
    'type': type.toString().split('.').last,
    'birthDate': birthDate?.toIso8601String(),
  };
}

enum PassengerType {
  child,  // < 17 years
  adult,  // 17-60 years
  elderly // > 60 years
}