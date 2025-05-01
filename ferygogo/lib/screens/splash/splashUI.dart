import 'dart:math';

import 'package:flutter/material.dart';
import 'logic.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashScreenLogic splashScreenLogic;

  @override
  void initState() {
    super.initState();
    splashScreenLogic = SplashScreenLogic(context, this);
    splashScreenLogic.init();
  }

  @override
  void dispose() {
    splashScreenLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: splashScreenLogic.controller,
      builder: (_, child) {
        return Scaffold(
          body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A73E8),
                  Color(0xFF135CB6),
                  Color(0xFF0B3B73),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background waves (decorative)
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/waves_bg.png', // Background waves image
                      width: screenSize.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Animated content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/boat.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 30),
                    
                    // App name with animation
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Text(
                              'FERRY TICKET',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    color: Colors.black38,
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Animated wave line
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Container(
                          width: 180 * value,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white24, Colors.white, Colors.white24],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Animated boats
                    SizedBox(
                      height: 60,
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Custom loading animation - Wave effect with boats
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 2000),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Stack(
                                children: List.generate(3, (index) {
                                  double delayedValue = (value - (index * 0.2)).clamp(0.0, 1.0);
                                  double position = delayedValue * 200;
                                  return Positioned(
                                    left: position - 20,
                                    top: 10 + (sin(delayedValue * 6.28) * 10), // Bobbing animation
                                    child: Opacity(
                                      opacity: delayedValue,
                                      child: Transform.scale(
                                        scale: 0.5,
                                        child: Image.asset(
                                          'assets/boat.png',
                                          width: 40,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                          
                          // Animated wave under boats
                          Positioned(
                            bottom: 5,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 1400),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Container(
                                  width: 200,
                                  height: 15,
                                  child: CustomPaint(
                                    painter: WavePainter(value),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Tagline
                Positioned(
                  bottom: 50,
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Ride the Waves, Sail in Comfort',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                color: Colors.black26,
                                blurRadius: 2.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // App version
                Positioned(
                  bottom: 20,
                  child: Opacity(
                    opacity: 0.7,
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
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

// Custom wave painter for loading animation
class WavePainter extends CustomPainter {
  final double animation;
  
  WavePainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    final path = Path();
    
    // Draw a wave pattern
    path.moveTo(0, size.height / 2);
    
    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i, 
        size.height / 2 + sin(((i / size.width * 6.0 * 3.14)) + (animation * 6.28)) * 4
      );
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}