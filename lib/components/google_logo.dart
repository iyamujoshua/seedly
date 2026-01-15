import 'package:flutter/material.dart';

/// A widget that displays the official Google "G" logo
/// with the correct brand colors.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  // Official Google brand colors
  static const Color blue = Color(0xFF4285F4);
  static const Color red = Color(0xFFEA4335);
  static const Color yellow = Color(0xFFFBBC05);
  static const Color green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Calculate the inner radius for the arc
    final arcRadius = radius - strokeWidth / 2;

    // Draw blue arc (right side, from -45 to 90 degrees)
    paint.color = blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      -0.785, // -45 degrees in radians
      1.57, // 90 degrees in radians
      false,
      paint,
    );

    // Draw green arc (bottom, from 45 to 90 degrees)
    paint.color = green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      0.785, // 45 degrees in radians
      1.57, // 90 degrees in radians
      false,
      paint,
    );

    // Draw yellow arc (left-bottom, from 135 to 90 degrees)
    paint.color = yellow;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      2.356, // 135 degrees in radians
      1.57, // 90 degrees in radians
      false,
      paint,
    );

    // Draw red arc (top, from 225 to 90 degrees)
    paint.color = red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      3.927, // 225 degrees in radians
      1.178, // ~67.5 degrees in radians
      false,
      paint,
    );

    // Draw the horizontal bar for the "G"
    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - strokeWidth * 0.1,
        center.dy - strokeWidth / 2,
        radius * 0.55,
        strokeWidth,
      ),
      Radius.circular(strokeWidth * 0.1),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
