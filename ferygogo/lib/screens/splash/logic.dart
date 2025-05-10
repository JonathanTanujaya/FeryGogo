import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
    try {
      print('SplashScreen: Starting initialization');
      await controller.forward();
      print('SplashScreen: Animation completed');

      if (!mounted) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuthState();
      
      if (mounted) {
        if (auth.isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('SplashScreen: Error during initialization: $e');
      if (mounted) {
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