class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final DateTime? birthDate;
  final String identityType;
  final String identityNumber;
  final String profilePicture;
  final int totalTrips;
  final List<String> favoriteRoutes;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.gender = '',
    this.birthDate,
    this.identityType = '',
    this.identityNumber = '',
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
      gender: map['gender'] ?? '',
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      identityType: map['identity_type'] ?? '',
      identityNumber: map['identity_number'] ?? '',
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
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'identity_type': identityType,
      'identity_number': identityNumber,
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
    String? gender,
    DateTime? birthDate,
    String? identityType,
    String? identityNumber,
    String? profilePicture,
    int? totalTrips,
    List<String>? favoriteRoutes,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      identityType: identityType ?? this.identityType,
      identityNumber: identityNumber ?? this.identityNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      totalTrips: totalTrips ?? this.totalTrips,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      createdAt: this.createdAt,
    );
  }
}