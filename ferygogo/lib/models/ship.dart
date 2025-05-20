class Ship {
  final String id;
  final String name;
  final String type; // 'reguler' atau 'express'
  final String status; // 'active' atau 'inactive'

  Ship({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
  });

  factory Ship.fromJson(Map<String, dynamic> json, String id) {
    return Ship(
      id: id,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }
}
