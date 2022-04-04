import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' hide Colors;

import '../GlobalWidget/GlobalWidget.dart';
import '../Constant.dart';

class BackgroundWidget extends StatefulWidget {
  final int type; //type 1 대각선 붙은거, 2 대각선 떨어진거, 3 수평 붙어서 위에, 4 대각선 붙어서 하단
  final vfGradationColorType colorType;
  final double blur;

  const BackgroundWidget({Key? key, required, required this.type, required this.colorType, required this.blur}) : super(key: key);

  @override
  _BackgroundWidgetState createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  double time = 0;
  double maxTime = 4;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(seconds: maxTime.toInt()));

    Tween<double> timeTween = Tween(begin: 0, end: maxTime);

    animation = timeTween.animate(controller)
      ..addListener(() {
        setState(() {
          time = controller.value * maxTime;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.stop();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: BackTwoCirclePainter(time: time, maxTime: maxTime, type: widget.type, colorType: widget.colorType),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ColoredCircle {
  Vector2 position;
  double radius;
  Color color;

  ColoredCircle({required this.position, required this.radius, required this.color});
}

class BackTwoCirclePainter extends CustomPainter {
  final double time;
  final double maxTime;
  final int type; //1 대각선 붙은거, 2 대각선 떨어진거, 3 수평 붙은거
  final vfGradationColorType colorType;

  BackTwoCirclePainter({required this.time, required this.maxTime, required this.type, required this.colorType});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    double myCal(double x) {
      double y = 0;
      y = pow(x - 1, 3).toDouble() + 1;
      if (y > 1) y = 1;
      return y;
    }

    double delayRatio = 0.2;

    double myCurve1 = myCal(time / maxTime);
    double maxTime2 = maxTime * (1 - delayRatio);
    double time2 = (time - maxTime2 * delayRatio) < 0 ? 0 : time - maxTime2 * delayRatio;
    double myCurve2 = myCal(time2 / maxTime2);

    ColoredCircle circle1 = ColoredCircle(position: Vector2(100, 100), radius: 10, color: Colors.red);
    ColoredCircle circle2 = ColoredCircle(position: Vector2(100, 100), radius: 10, color: Colors.red);
    switch (type) {
      case 1:
        circle1.position.x = centerX - 59 * sizeUnit;
        circle1.position.y = centerY - 53 * sizeUnit;
        circle1.radius = 73 * sizeUnit * myCurve2;

        circle2.position.x = centerX + 32 * sizeUnit;
        circle2.position.y = centerY + 6 * sizeUnit;
        circle2.radius = 100 * sizeUnit * myCurve1;
        break;
      case 2:
        circle1.position.x = centerX - 106 * sizeUnit;
        circle1.position.y = centerY - size.height * 0.25;
        circle1.radius = 102 * sizeUnit * myCurve2;

        circle2.position.x = centerX + 92 * sizeUnit;
        circle2.position.y = centerY + size.height * 0.2;
        circle2.radius = 128 * sizeUnit * myCurve1;
        break;
      case 3:
        circle1.position.x = centerX + -72 * sizeUnit;
        circle1.position.y = size.height * 0.1;
        circle1.radius = 102 * sizeUnit * myCurve2;

        circle2.position.x = centerX + 110 * sizeUnit;
        circle2.position.y = size.height * 0.1 + 23*sizeUnit;
        circle2.radius = 140 * sizeUnit * myCurve1;
        break;
      case 4:
        circle1.position.x = centerX + -58 * sizeUnit;
        circle1.position.y = size.height * 0.6;
        circle1.radius = 102 * sizeUnit * myCurve2;

        circle2.position.x = centerX + 69 * sizeUnit;
        circle2.position.y = size.height * 0.6 + 136*sizeUnit;
        circle2.radius = 136 * sizeUnit * myCurve1;
        break;
      case 5:
        circle1.position.x = centerX + 380 * sizeUnit;
        circle1.position.y = size.height + 130 * sizeUnit;
        circle1.radius = 450 * sizeUnit * myCurve2;

        circle2.position.x = centerX + -380 * sizeUnit;
        circle2.position.y = size.height + 130 * sizeUnit;
        circle2.radius = 450 * sizeUnit * myCurve1;
        break;
    }

    switch (colorType) {
      case vfGradationColorType.Red:
        circle1.color = vfGradationRed2;
        circle2.color = vfGradationRed1;
        break;
      case vfGradationColorType.Blue:
        circle1.color = vfGradationBlue1;
        circle2.color = vfGradationBlue2;
        break;
      case vfGradationColorType.Violet:
        circle1.color = vfGradationViolet1;
        circle2.color = vfGradationViolet2;
        break;
      case vfGradationColorType.Pink:
        circle1.color = vfColorPink40;
        circle2.color = vfColorPink60;
        break;
    }

    var circlePaint1 = Paint()
      ..color = circle1.color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var circlePaint2 = Paint()
      ..color = circle2.color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(circle1.position.x, circle1.position.y), circle1.radius, circlePaint1);
    canvas.drawCircle(Offset(circle2.position.x, circle2.position.y), circle2.radius, circlePaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
