import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEAEEF9).withOpacity(0.73),
                labelText: 'Email Address',
                labelStyle: TextStyle(fontSize: 16),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Efek floating untuk email
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25), // Menambahkan jarak lebih besar antara email dan password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEAEEF9).withOpacity(0.73),
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 16),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Efek floating untuk password
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
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
                  Navigator.pushReplacementNamed(context, '/home');
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