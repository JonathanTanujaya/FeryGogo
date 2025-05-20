import 'package:flutter/material.dart';
import 'logic.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashScreenLogic splashScreenLogic;
  
  // Controllers for animations
  late AnimationController _bgController;
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  
  // Animations
  late Animation<Color?> _bgAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _taglineSlideAnimation;

  // Color constants
  final Color sapphireBlue = const Color(0xFF0052BA);
  final Color lightBlue = const Color(0xFF4B9DFF);

  @override
  void initState() {
    super.initState();
    splashScreenLogic = SplashScreenLogic(context, this);
    splashScreenLogic.init();

    // Background animation
    _bgController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _bgAnimation = ColorTween(
      begin: sapphireBlue,
      end: sapphireBlue.withOpacity(0.9),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * 3.14159, // 2π for a full wave cycle
    ).animate(_waveController);

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..forward();

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController, 
      curve: Curves.elasticOut,
    ));

    _logoRotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Tagline animation
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _taglineSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    splashScreenLogic.dispose();
    _bgController.dispose();
    _waveController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgAnimation,
        _waveAnimation,
        _logoScaleAnimation,
        _logoRotateAnimation,
        _textOpacityAnimation,
        _taglineSlideAnimation,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgAnimation.value,
          body: Stack(
            children: [
              // Background with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      sapphireBlue,
                      sapphireBlue.withBlue(180),
                    ],
                  ),
                ),
              ),
              
              // Animated waves
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildWaves(),
              ),
              
              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Space at top
                      const SizedBox(height: 30),
                      
                      // Animated logo
                      _buildAnimatedLogo(),
                      
                      const SizedBox(height: 30),
                      
                      // Animated app name
                      Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: const Text(
                          'FeryGogo',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Animated tagline
                      Transform.translate(
                        offset: Offset(0, _taglineSlideAnimation.value),
                        child: Opacity(
                          opacity: _taglineController.value,
                          child: const Text(
                            'Ride the Waves, Sail in Comfort',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return Transform.rotate(
      angle: _logoRotateAnimation.value * (1 - _logoController.value * 0.8) * 
             // Add slight wave effect to the boat
             (1 + 0.1 * sin(_waveController.value * 3)),
      child: Transform.scale(
        scale: _logoScaleAnimation.value,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom styled directions_boat_outlined icon
                Icon(
                  Icons.directions_boat_filled_rounded,
                  size: 80,
                  color: sapphireBlue,
                ),
                // Subtle water line beneath the boat
                Positioned(
                  bottom: 28,
                  child: Container(
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaves() {
    return SizedBox(
      height: 120,
      width: MediaQuery.of(context).size.width,
      child: CustomPaint(
        painter: WavePainter(
          animationValue: _waveAnimation.value,
          waveColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

// Custom painter for wave animation
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;

  WavePainter({required this.animationValue, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Starting point
    path.moveTo(0, height * 0.5);

    // First wave layer
    for (double i = 0; i < width; i++) {
      path.lineTo(
        i,
        height * 0.5 + sin((i / width * 4 * 3.14159) + animationValue) * height * 0.1,
      );
    }

    // Connect to bottom-right corner and back to start
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave layer (smaller)
    final path2 = Path();
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    path2.moveTo(0, height * 0.6);

    for (double i = 0; i < width; i++) {
      path2.lineTo(
        i,
        height * 0.6 + sin((i / width * 3 * 3.14159) - animationValue) * height * 0.05,
      );
    }

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}