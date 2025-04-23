import 'dart:async';
import 'dart:isolate';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginLogic {
  Future<void> login(BuildContext context, String email, String password) async {
    try {
      // Use an isolate to perform Firebase authentication
      final userCredential = await compute(_authenticateUser, [email, password]);

      // Retrieve user data from Firebase Realtime Database
      DatabaseReference databaseRef = FirebaseDatabase.instance.ref("users/${userCredential.user?.uid}");
      DataSnapshot snapshot = await databaseRef.get();

      if (snapshot.exists) {
        Map userData = snapshot.value as Map;
        print("User Data: ${userData.toString()}"); // Debugging purpose

        // Navigate to the home screen on success
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found in the database.')),
        );
      }
    } catch (e) {
      // Handle errors (e.g., wrong password, user not found, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }
}

// Function to perform Firebase authentication in an isolate
Future<UserCredential> _authenticateUser(List<String> args) async {
  final email = args[0];
  final password = args[1];
  return await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}