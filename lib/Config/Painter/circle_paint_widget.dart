import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CirclePaintWidget extends StatelessWidget {
  const CirclePaintWidget({Key? key, required this.diameter, required this.color, this.child}) : super(key: key);

  final double diameter;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      child: CustomPaint(
        painter: CircleBlurPainter(color: color),
        child: child,
      ),
    );
  }
}


class CircleBlurPainter extends CustomPainter {

  CircleBlurPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    var circlePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(center, radius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}