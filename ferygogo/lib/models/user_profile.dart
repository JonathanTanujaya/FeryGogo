class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final int totalTrips;
  final List<String> favoriteRoutes;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.profilePicture = '',
    this.totalTrips = 0,
    List<String>? favoriteRoutes,
    DateTime? createdAt,
  }) : 
    this.favoriteRoutes = favoriteRoutes ?? [],
    this.createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromMap(String id, Map<dynamic, dynamic> map) {
    return UserProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      profilePicture: map['profile_picture'] ?? '',
      totalTrips: map['total_trips'] ?? 0,
      favoriteRoutes: (map['favorite_routes'] as List?)?.cast<String>() ?? [],
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'total_trips': totalTrips,
      'favorite_routes': favoriteRoutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    int? totalTrips,
    List<String>? favoriteRoutes,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      totalTrips: totalTrips ?? this.totalTrips,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      createdAt: this.createdAt,
    );
  }
}