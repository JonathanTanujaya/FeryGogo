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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _boatSlide;
  late Animation<double> _waveFade;
  late Animation<Color?> _bgColor;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _bgColor = ColorTween(
      begin: Color(0xFF00008B), // deep blue
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _boatSlide = Tween<double>(
      begin: -100, // start above screen center
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)));

    _waveFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0)));

    _controller.forward();
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Boat animation
                Transform.translate(
                  offset: Offset(0, _boatSlide.value),
                  child: Image.asset(
                    'assets/boat.png', // Gambar perahu
                    width: 100,
                  ),
                ),
                // Waves animation
                Positioned(
                  bottom: 200,
                  child: Opacity(
                    opacity: _waveFade.value,
                    child: Image.asset(
                      'assets/waves.png', // Gambar ombak
                      width: 150,
                    ),
                  ),
                ),
                // Optional: Loading indicator (untuk saat aplikasi sedang melakukan cek)
                Positioned(
                  bottom: 80,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F52BA)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Halaman Selanjutnya')),
    );
  }
}
