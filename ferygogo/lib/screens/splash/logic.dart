import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/error_handler.dart';

class SplashScreenLogic {
  final BuildContext context;
  final TickerProvider vsync;
  late AnimationController controller;
  late Animation<double> boatSlide;
  late Animation<double> waveFade;
  late Animation<Color?> bgColor;
  late Animation<double> logoScale;
  Timer? timeoutTimer;
  bool _mounted = true;
  
  bool get mounted => _mounted;

  SplashScreenLogic(this.context, this.vsync);

  void init() {
    controller = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 5),
    );

    bgColor = ColorTween(
      begin: Color(0xFF00008B), // deep blue
      end: Colors.white,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    boatSlide = Tween<double>(begin: -100, end: 0)
        .animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 0.5)));

    waveFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: controller, curve: Interval(0.5, 1.0)));

    logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Set timeout timer
    timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    try {
      print('SplashScreen: Starting initialization');
      await controller.forward();
      print('SplashScreen: Animation completed');

      if (!mounted) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuthState();
      print('SplashScreen: Auth state checked');

      timeoutTimer?.cancel(); // Cancel timeout if successful

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

  void dispose() {
    _mounted = false;
    timeoutTimer?.cancel();
    controller.dispose();
  }
}
