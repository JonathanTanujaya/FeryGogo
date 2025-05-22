import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformationModel {
  final String id;
  final String title;
  final List<String> description; // array of String
  final String imageUrl; // base64 string
  final DateTime publishDate;

  InformationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishDate,
  });

  factory InformationModel.fromMap(Map<String, dynamic> map, String id) {
    return InformationModel(
      id: id,
      title: map['title'] ?? '',
      description: (map['description'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      imageUrl: map['imageUrl'] ?? '',
      publishDate: map['publishDate'] is Timestamp
          ? (map['publishDate'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['publishDate'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'publishDate': publishDate.millisecondsSinceEpoch,
    };
  }

  // Helper to decode base64 image
  ImageProvider get imageProvider {
    if (imageUrl.isEmpty) return const AssetImage('assets/ferygogo.png');
    try {
      // Remove data URI prefix if present
      final base64Str = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return const AssetImage('assets/ferygogo.png');
    }
  }
}
