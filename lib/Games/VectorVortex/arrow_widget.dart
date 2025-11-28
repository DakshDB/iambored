import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models.dart';

class ArrowWidget extends StatelessWidget {
  final Arrow arrow;
  final VoidCallback onTap;
  final double cellSize;
  final Color color;

  const ArrowWidget({
    super.key,
    required this.arrow,
    required this.onTap,
    required this.cellSize,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: CustomPaint(
          painter: _ArrowPainter(
            color: color,
            direction: arrow.direction,
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;

  _ArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.width * 0.8; // Length of the arrow shaft

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_getRotationAngle(direction));
    canvas.translate(-center.dx, -center.dy);

    // Draw Line (Shaft)
    // Start from left side, go to right side
    final start = Offset(size.width * 0.1, size.height / 2);
    final end = Offset(size.width * 0.9, size.height / 2);

    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // Draw Arrowhead
    final headSize = size.width * 0.25;
    path.moveTo(end.dx - headSize, end.dy - headSize * 0.8);
    path.lineTo(end.dx, end.dy);
    path.lineTo(end.dx - headSize, end.dy + headSize * 0.8);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.direction != direction;
  }

  double _getRotationAngle(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.left:
        return math.pi; // Point Left
      case ArrowDirection.up:
        return -math.pi / 2; // Point Up
      case ArrowDirection.right:
        return 0; // Point Right
      case ArrowDirection.down:
        return math.pi / 2; // Point Down
    }
  }
}
