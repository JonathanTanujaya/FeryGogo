class Passenger {
  final String name;
  final String idNumber;
  final PassengerType type;
  final DateTime? birthDate;

  Passenger({
    required this.name,
    required this.idNumber,
    required this.type,
    this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'idNumber': idNumber,
    'type': type.toString().split('.').last,
    'birthDate': birthDate?.toIso8601String(),
  };
}

enum PassengerType {
  child,  // < 17 years
  adult,  // 17-60 years
  elderly // > 60 years
}