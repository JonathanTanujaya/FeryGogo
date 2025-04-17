import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  bool validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@#\$%^&+=!]).{8,}');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _signUp(BuildContext context, String email, String password, String fullName) async {
    try {
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

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController fullNameController = TextEditingController();
    final ValueNotifier<bool> emailError = ValueNotifier(false);
    final ValueNotifier<bool> passwordError = ValueNotifier(false);
    final ValueNotifier<bool> fullNameError = ValueNotifier(false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 40), // Memberikan jarak dari atas layar
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0B0086)),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Create Your Account',
                style: TextStyle(
                  color: Color(0xFF0B0086),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: fullNameError,
              builder: (context, hasError, child) {
                return TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: hasError ? Colors.black : Color(0xFFEAEEF9),
                    labelText: 'Full Name',
                    labelStyle: TextStyle(fontSize: 16, color: hasError ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: emailError,
              builder: (context, hasError, child) {
                return TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: hasError ? Colors.black : Color(0xFFEAEEF9),
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 16, color: hasError ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: passwordError,
              builder: (context, hasError, child) {
                return TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: hasError ? Colors.black : Color(0xFFEAEEF9),
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 16, color: hasError ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 41,
              decoration: BoxDecoration(
                color: Color(0xFF0B0086),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final fullName = fullNameController.text.trim();

                  emailError.value = email.isEmpty;
                  passwordError.value = password.isEmpty;
                  fullNameError.value = fullName.isEmpty;

                  if (!emailError.value && !passwordError.value && !fullNameError.value) {
                    _signUp(context, email, password, fullName);
                  }
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: Color(0xFF0B0086),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}