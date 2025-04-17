import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> _login(BuildContext context, String email, String password) async {
    try {
      // Sign in the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final ValueNotifier<bool> emailError = ValueNotifier(false);
    final ValueNotifier<bool> passwordError = ValueNotifier(false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Sign In to Your Account',
                style: TextStyle(
                  color: Color(0xFF0B0086),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: emailError,
              builder: (context, hasError, child) {
                return TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: hasError ? Colors.black : Color(0xFFEAEEF9).withOpacity(0.73),
                    labelText: 'Email Address',
                    labelStyle: TextStyle(fontSize: 16, color: hasError ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            ValueListenableBuilder(
              valueListenable: passwordError,
              builder: (context, hasError, child) {
                return TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: hasError ? Colors.black : Color(0xFFEAEEF9).withOpacity(0.73),
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 16, color: hasError ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
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

                  emailError.value = email.isEmpty;
                  passwordError.value = password.isEmpty;

                  if (!emailError.value && !passwordError.value) {
                    _login(context, email, password);
                  }
                },
                child: Text(
                  'Sign In',
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
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Don’t have an account? ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Create one',
                          style: TextStyle(color: Color(0xFF0B0086), fontSize: 14, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Or continue with:', style: TextStyle(fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Tambahkan logika login dengan Google di sini
                    },
                    child: Container(
                      width: double.infinity,
                      height: 41,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Color(0xFF0B0086).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_logo.png', // Pastikan file logo Google ada di folder assets
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Google Account',
                            style: TextStyle(
                              color: Color(0xFF0B0086),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}