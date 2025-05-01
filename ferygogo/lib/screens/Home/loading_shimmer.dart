import 'package:flutter/material.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(3, (index) => 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _ShimmerItem(animation: _animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  final double animation;

  const _ShimmerItem({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _ShimmerPainter(animation),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double animation;
  final Paint _paint = Paint();

  _ShimmerPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment(animation - 1, 0),
      end: Alignment(animation, 0),
      colors: const [
        Color(0x44FFFFFF),
        Color(0x66FFFFFF),
        Color(0x44FFFFFF),
      ],
    );

    _paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}