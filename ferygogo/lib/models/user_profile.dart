import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String gender;
  final DateTime? birthDate;
  final String identityType;
  final String identityNumber;
  final String profilePicture;
  final String? imageBase64; // Add base64 image support
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    this.birthDate,
    required this.identityType,
    required this.identityNumber,
    required this.profilePicture,
    this.imageBase64, // Add to constructor
    this.createdAt,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: _parseDateTime(map['birthDate']),
      identityType: map['identityType'] ?? '',
      identityNumber: map['identityNumber'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      imageBase64: map['imageBase64'], // Add to factory
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String() ?? '',
      'identityType': identityType,
      'identityNumber': identityNumber,
      'profilePicture': profilePicture,
      'imageBase64': imageBase64, // Add to map
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value == '') {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
    String? identityType,
    String? identityNumber,
    String? profilePicture,
    String? imageBase64, // Add to copyWith
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      identityType: identityType ?? this.identityType,
      identityNumber: identityNumber ?? this.identityNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      imageBase64: imageBase64 ?? this.imageBase64, // Add to constructor call
      createdAt: createdAt,
    );
  }
}