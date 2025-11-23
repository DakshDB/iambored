import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class PerfectCut extends StatefulWidget {
  const PerfectCut({super.key});

  @override
  State<PerfectCut> createState() => _PerfectCutState();
}

class _PerfectCutState extends State<PerfectCut> {
  List<Offset> polygon = [];
  Offset? startPoint;
  Offset? endPoint;
  List<Offset> splitPoly1 = [];
  List<Offset> splitPoly2 = [];
  double score = 0;
  bool showResult = false;
  double area1 = 0;
  double area2 = 0;
  double totalArea = 0;
  int level = 1;
  double totalScore = 0;

  @override
  void initState() {
    super.initState();
    // Polygon generation deferred to build method to access MediaQuery
  }

  void _calculateCut() {
    if (startPoint == null || endPoint == null) return;

    // 1. Find intersections
    List<Offset> intersections = [];
    List<int> intersectionIndices = []; // Index of the edge starting point

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      final intersection = _getLineIntersection(startPoint!, endPoint!, p1, p2);
      if (intersection != null) {
        intersections.add(intersection);
        intersectionIndices.add(i);
      }
    }

    if (intersections.length != 2) {
      // Invalid cut (didn't cross exactly 2 edges)
      // For now, just reset
      setState(() {
        startPoint = null;
        endPoint = null;
      });
      return;
    }

    // 2. Split Polygon
    // Poly 1: Inter1 -> ... -> Inter2
    splitPoly1.clear();
    splitPoly1.add(intersections[0]);

    int currentIndex = intersectionIndices[0];
    int endIndex = intersectionIndices[1];

    // Add vertices between inter1 and inter2
    // We move forward from index[0] to index[1]
    int idx = (currentIndex + 1) % polygon.length;
    while (idx != (endIndex + 1) % polygon.length) {
      splitPoly1.add(polygon[idx]);
      idx = (idx + 1) % polygon.length;
    }
    splitPoly1.add(intersections[1]);

    // Poly 2: Inter2 -> ... -> Inter1
    splitPoly2.clear();
    splitPoly2.add(intersections[1]);

    idx = (endIndex + 1) % polygon.length;
    while (idx != (currentIndex + 1) % polygon.length) {
      splitPoly2.add(polygon[idx]);
      idx = (idx + 1) % polygon.length;
    }
    splitPoly2.add(intersections[0]);

    // 3. Calculate Areas
    area1 = _calculatePolygonArea(splitPoly1);
    area2 = _calculatePolygonArea(splitPoly2);
    totalArea = area1 + area2;

    // 4. Score
    double ratio = (area1 / totalArea) * 100;
    // Perfect is 50.
    // Diff = |50 - ratio|
    // Score = 100 - Diff * 2 (so if ratio is 0 or 100, score is 0. If ratio is 50, score is 100)
    double diff = (50 - ratio).abs();
    double roundScore = max(
        0,
        100 -
            diff *
                4); // Penalize more strictly? *4 means 25% off = 0 score. Let's do *3
    roundScore = max(0, 100 - diff * 3);

    setState(() {
      score = roundScore;
      totalScore += score;
      showResult = true;
    });

    recordScore('perfect_cut', totalScore);
  }

  Offset? _getLineIntersection(Offset p1, Offset p2, Offset p3, Offset p4) {
    // Line 1: p1-p2 (The cut line - treat as infinite line for intersection calculation?)
    // Actually, user draws a line segment. If it doesn't cross, it's not a cut.
    // But to make it easier, let's treat p1-p2 as infinite line, BUT check if intersection lies on p3-p4 segment.

    final x1 = p1.dx, y1 = p1.dy;
    final x2 = p2.dx, y2 = p2.dy;
    final x3 = p3.dx, y3 = p3.dy;
    final x4 = p4.dx, y4 = p4.dy;

    final denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    if (denom == 0) return null; // Parallel

    final ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom;
    final ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom;

    // ub is for the segment p3-p4. It must be between 0 and 1.
    // ua is for the segment p1-p2. If we want to treat p1-p2 as infinite, we don't check ua.
    // But user drew a line, maybe we should enforce it crosses?
    // Let's enforce it crosses the cut line too to avoid accidental cuts from short swipes.
    if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
      return Offset(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1));
    }
    return null;
  }

  double _calculatePolygonArea(List<Offset> points) {
    double area = 0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].dx * points[j].dy;
      area -= points[j].dx * points[i].dy;
    }
    return (area / 2).abs();
  }

  void _nextLevel() {
    setState(() {
      level++;
      polygon.clear(); // Trigger regeneration in build
      showResult = false;
      startPoint = null;
      endPoint = null;
      splitPoly1.clear();
      splitPoly2.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header / Score
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Text(
                    'Perfect Cut',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Game Area (Expanded to fill available space)
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Define a square area for the game
                    double size =
                        min(constraints.maxWidth, constraints.maxHeight) * 0.85;

                    // Regenerate if empty
                    if (polygon.isEmpty) {
                      final random = Random();
                      final centerX = size / 2;
                      final centerY = size / 2;
                      final radius = size * 0.35;
                      final numPoints = 3 + random.nextInt(3);

                      List<double> angles = [];
                      for (int i = 0; i < numPoints; i++) {
                        angles.add(random.nextDouble() * 2 * pi);
                      }
                      angles.sort();

                      polygon.clear();
                      for (var angle in angles) {
                        final r = radius * (0.7 + random.nextDouble() * 0.3);
                        polygon.add(Offset(
                          centerX + r * cos(angle),
                          centerY + r * sin(angle),
                        ));
                      }
                    }

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onPanStart: (details) {
                          if (showResult) return;
                          setState(() {
                            startPoint = details.localPosition;
                            endPoint = details.localPosition;
                          });
                        },
                        onPanUpdate: (details) {
                          if (showResult) return;
                          setState(() {
                            endPoint = details.localPosition;
                          });
                        },
                        onPanEnd: (details) {
                          if (showResult) return;
                          _calculateCut();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomPaint(
                            size: Size(size, size),
                            painter: PolygonPainter(
                              polygon: polygon,
                              startPoint: startPoint,
                              endPoint: endPoint,
                              splitPoly1: splitPoly1,
                              splitPoly2: splitPoly2,
                              showResult: showResult,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Result Section (Below Shape, Above Back Button)
            SizedBox(
              height: 150, // Fixed height to prevent layout jump
              child: showResult
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${score.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Split: ${(area1 / totalArea * 100).toStringAsFixed(1)}% / ${(area2 / totalArea * 100).toStringAsFixed(1)}%',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _nextLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Next Shape',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),

            // Sized Box
            const SizedBox(height: 20),

            // Back Button (Bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.black))),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<Offset> polygon;
  final Offset? startPoint;
  final Offset? endPoint;
  final List<Offset> splitPoly1;
  final List<Offset> splitPoly2;
  final bool showResult;

  PolygonPainter({
    required this.polygon,
    this.startPoint,
    this.endPoint,
    required this.splitPoly1,
    required this.splitPoly2,
    required this.showResult,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    if (showResult) {
      // Draw split polygons
      paint.color = Colors.blue.withOpacity(0.8);
      final path1 = Path()..addPolygon(splitPoly1, true);
      canvas.drawPath(path1, paint);

      paint.color = Colors.red.withOpacity(0.8);
      final path2 = Path()..addPolygon(splitPoly2, true);
      canvas.drawPath(path2, paint);

      // Draw outline
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.black;
      paint.strokeWidth = 3.0;
      canvas.drawPath(path1, paint);
      canvas.drawPath(path2, paint);
    } else {
      // Draw original polygon
      paint.color = Colors.black87;
      final path = Path()..addPolygon(polygon, true);
      canvas.drawPath(path, paint);

      // No outline needed for solid black shape, or maybe a subtle one?
      // Let's keep it clean black shape.
    }

    // Draw Cut Line
    if (startPoint != null && endPoint != null) {
      final linePaint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      // Draw dashed line? No, solid cut line is better.
      canvas.drawLine(startPoint!, endPoint!, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
