import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/error_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Set timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    try {
      print('SplashScreen: Starting initialization');
      await _controller.forward();
      print('SplashScreen: Animation completed');

      if (!mounted) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuthState();
      print('SplashScreen: Auth state checked');

      _timeoutTimer?.cancel(); // Cancel timeout if successful

      if (!mounted) return;

      if (auth.isAuthenticated) {
        print('SplashScreen: User authenticated, navigating to /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('SplashScreen: User not authenticated, navigating to /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('SplashScreen: Error during initialization - $e');
      if (mounted) {
        ErrorHandler.showError(context, 'Gagal memuat aplikasi. Silakan coba lagi.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FeryGogo',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F52BA),
                    fontFamily: 'Poppins',
                    shadows: isDark ? [
                      const BoxShadow(
                        color: Color(0xFF0F52BA),
                        blurRadius: 20,
                        spreadRadius: -5,
                      )
                    ] : null,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F52BA)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
