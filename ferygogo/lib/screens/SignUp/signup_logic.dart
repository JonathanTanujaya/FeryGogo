import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';

class SignUpLogic {
  bool validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@#\$%^&+=!]).{8,}');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp(BuildContext context, String email, String password, String fullName) async {
    try {
      // Use an isolate to perform Firebase operations
      final userCredential = await compute(_createUser, [email, password, fullName]);

      // Navigate to the login screen on success
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully created a new account.')),
      );
    } catch (e) {
      // Handle errors (e.g., email already in use, weak password, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: ${e.toString()}')),
      );
    }
  }
}

// Function to perform Firebase operations in an isolate
Future<UserCredential> _createUser(List<String> args) async {
  final email = args[0];
  final password = args[1];
  final fullName = args[2];

  // Create a new user with Firebase Authentication
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Save user data to Firebase Realtime Database
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref("users/${userCredential.user?.uid}");
  await databaseRef.set({
    "fullName": fullName,
    "email": email,
  });

  return userCredential;
}