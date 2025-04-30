import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String gender;
  final DateTime? birthDate;
  final String identityType;
  final String identityNumber;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.profilePicture = '',
    this.gender = '',
    this.birthDate,
    this.identityType = '',
    this.identityNumber = '',
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: map['birthDate'] != null && map['birthDate'].toString().isNotEmpty
          ? DateTime.tryParse(map['birthDate'])
          : null,
      identityType: map['identityType'] ?? '',
      identityNumber: map['identityNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String() ?? '',
      'identityType': identityType,
      'identityNumber': identityNumber,
    };
  }

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? profilePicture,
    String? gender,
    DateTime? birthDate,
    String? identityType,
    String? identityNumber,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      identityType: identityType ?? this.identityType,
      identityNumber: identityNumber ?? this.identityNumber,
    );
  }
}