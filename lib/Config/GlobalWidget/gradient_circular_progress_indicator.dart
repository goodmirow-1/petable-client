import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'dart:math' as math;

import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';

class GradientCircularProgressIndicator extends StatefulWidget {
  final double radius;
  final double strokeWidth;
  final List<Color> gradientColors;

  GradientCircularProgressIndicator({
    this.radius = 20,
    this.strokeWidth = 5,
    this.gradientColors = loadingVioletColorList,
  });

  @override
  State<GradientCircularProgressIndicator> createState() => _GradientCircularProgressIndicatorState();
}

class _GradientCircularProgressIndicatorState extends State<GradientCircularProgressIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final radius;
  late final strokeWidth;

  @override
  void initState() {
    radius = widget.radius * sizeUnit;
    strokeWidth = widget.strokeWidth * sizeUnit;

    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
      child: CustomPaint(
        size: Size.fromRadius(radius),
        painter: GradientCircularProgressPainter(
          radius: radius,
          gradientColors: widget.gradientColors,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    required this.radius,
    required this.gradientColors,
    required this.strokeWidth,
  });

  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    size = Size.fromRadius(radius);
    double offset = strokeWidth / 2;
    Rect rect = Offset(offset, offset) & Size(size.width - strokeWidth, size.height - strokeWidth);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    paint.shader = SweepGradient(colors: gradientColors, startAngle: 0.0, endAngle: 2 * math.pi).createShader(rect);
    canvas.drawArc(rect, 0.0, 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
