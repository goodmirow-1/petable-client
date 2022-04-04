import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' hide Colors;

import '../GlobalWidget/GlobalWidget.dart';
import '../Constant.dart';

class WaveAnimationWidget extends StatefulWidget {
  final double width; //match parent
  final double height; //match parent
  final int numberOfPoint1; //파동 포인트 갯수
  final int numberOfPoint2; //파동 포인트 갯수
  final double ratio; //높이 비율 0~1

  const WaveAnimationWidget({Key? key, required this.width, required this.height, required this.numberOfPoint1, required this.numberOfPoint2, required this.ratio}) : super(key: key);

  @override
  _WaveAnimationWidgetState createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<WaveAnimationWidget> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  List<WaveSpot> listWaveSpot = [];
  List<WaveSpot> listWaveSpot2 = [];

  late double width;
  late double height;

  late double initialHeight;

  double elasticity = 6;
  double frictionElasticity = 0.01;

  late double maxInitialSpeed;

  @override
  void initState() {
    super.initState();

    width = widget.width;
    height = widget.height;

    initialHeight = (1 - widget.ratio) * height;

    maxInitialSpeed = 100 * height / (720 * sizeUnit) * (1 + widget.ratio) * 0.5 ;

    controller = AnimationController(vsync: this, duration: Duration(seconds: 100));

    Tween<double> timeTween = Tween(begin: 0, end: 100);

    animation = timeTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();

    makeWave(widget.numberOfPoint1, listWaveSpot);
    makeWave(widget.numberOfPoint2, listWaveSpot2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void makeWave(int numberOfSpot, List<WaveSpot> listWaveSpot) {
    if (numberOfSpot < 3) numberOfSpot = 3; //numberOfSpot 최소 3개
    double interval = (width) / (numberOfSpot - 1);
    for (int i = 0; i < numberOfSpot; i++) {
      WaveSpot waveSpot = WaveSpot(
        velocity: Vector2(0, (Random().nextDouble() - 0.5) * maxInitialSpeed),
        position: Vector2(i * interval, initialHeight),
        centerPosition: Vector2(i * interval, initialHeight),
      );
      listWaveSpot.add(waveSpot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: WavePainter(
          time: animation.value,
          listWaveSpot: listWaveSpot,
          elasticity: elasticity,
          frictionElasticity: frictionElasticity,
          color: vfGradationBlue1,
          maxInitialSpeed: maxInitialSpeed,
        ),
        child: CustomPaint(
          painter: WavePainter(
            time: animation.value,
            listWaveSpot: listWaveSpot2,
            elasticity: elasticity,
            frictionElasticity: frictionElasticity,
            color: vfGradationBlue2,
            maxInitialSpeed: maxInitialSpeed,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class WaveSpot {
  Vector2 acceleration = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  Vector2 position = Vector2.zero();
  Vector2 centerPosition = Vector2.zero();
  double previousTime = 0;

  WaveSpot({required this.velocity, required this.position, required this.centerPosition});
}

class WavePainter extends CustomPainter {
  final double time;
  final List<WaveSpot> listWaveSpot;
  final double elasticity;
  final double frictionElasticity;
  final Color color;
  final double maxInitialSpeed;

  WavePainter({required this.time, required this.elasticity, required this.listWaveSpot, required this.frictionElasticity, required this.color, required this.maxInitialSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < listWaveSpot.length; i++) {
      double dt = time - listWaveSpot[i].previousTime;
      if (dt > 0.01||dt < 0) dt = 0.01;
      listWaveSpot[i].previousTime = time;

      double positionDiffFromCenter = listWaveSpot[i].position.y - listWaveSpot[i].centerPosition.y;
      double signDiffFromCenter = positionDiffFromCenter == 0 ? 0 : positionDiffFromCenter / positionDiffFromCenter.abs();

      if (i == 0) {
        double positionDiffFromNext = listWaveSpot[i].position.y - listWaveSpot[i + 1].position.y;

        listWaveSpot[i].acceleration.y = elasticity * (3 * positionDiffFromCenter + positionDiffFromNext);
      } else if (i == listWaveSpot.length - 1) {
        double positionDiffFromPrev = listWaveSpot[i].position.y - listWaveSpot[i - 1].position.y;

        listWaveSpot[i].acceleration.y = elasticity * (3 * positionDiffFromCenter + positionDiffFromPrev);
      } else {
        double positionDiffFromPrev = listWaveSpot[i].position.y - listWaveSpot[i - 1].position.y;
        double positionDiffFromNext = listWaveSpot[i].position.y - listWaveSpot[i + 1].position.y;

        listWaveSpot[i].acceleration.y = elasticity * (3 * positionDiffFromCenter + positionDiffFromNext + positionDiffFromPrev);
      }

      double friction = frictionElasticity * listWaveSpot[i].velocity.y * listWaveSpot[i].velocity.y;
      if (listWaveSpot[i].velocity.y != 0) listWaveSpot[i].acceleration.y += -1 * (listWaveSpot[i].velocity.y / listWaveSpot[i].velocity.y.abs()) * friction;

      listWaveSpot[i].velocity.y = listWaveSpot[i].velocity.y - (listWaveSpot[i].acceleration.y) * dt;

      listWaveSpot[i].position.y = listWaveSpot[i].position.y + listWaveSpot[i].velocity.y * dt;

      double positionNewDiffFromCenter = listWaveSpot[i].position.y - listWaveSpot[i].centerPosition.y;
      double signNewDiffFromCenter = positionNewDiffFromCenter == 0 ? 0 : positionNewDiffFromCenter / positionNewDiffFromCenter.abs();
      //최소 속도 이하일때 처리
      if (signNewDiffFromCenter != signDiffFromCenter) {
        if (listWaveSpot[i].velocity.y.abs() < maxInitialSpeed * 0.1) {
          listWaveSpot[i].velocity.y = listWaveSpot[i].velocity.y * 1.5;
        }
      }
      //최고 속도 제한
      if (listWaveSpot[i].velocity.y.abs() > maxInitialSpeed) {
        listWaveSpot[i].velocity.y = listWaveSpot[i].velocity.y * 0.9;
      }
    }

    double positionTotal = 0;
    listWaveSpot.forEach((element) {
      if(element.acceleration.x.isNaN) element.acceleration.x = 0;
      if(element.acceleration.y.isNaN) element.acceleration.y = 0;
      if(element.velocity.x.isNaN) element.velocity.x = 0;
      if(element.velocity.y.isNaN) element.velocity.y = 0;
      if(element.position.x.isNaN) element.position.x = 0;
      if(element.position.y.isNaN) element.position.y = 0;
      if(element.centerPosition.x.isNaN) element.centerPosition.x = 0;
      if(element.centerPosition.y.isNaN) element.centerPosition.y = 0;
      positionTotal += element.position.y;
    });

    double heightAvg = 0;

    heightAvg = positionTotal / listWaveSpot.length;

    var paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, heightAvg),
        Offset(0, size.height),
        [
          color.withOpacity(0.6),
          color.withOpacity(0),
        ],
      )
      ..strokeWidth = 15;

    var path = Path();

    List<Vector2> listSupportPoint = [];
    for (int i = 0; i < listWaveSpot.length - 1; i++) {
      Vector2 supportPoint = Vector2((listWaveSpot[i].position.x + listWaveSpot[i + 1].position.x) / 2, (listWaveSpot[i].position.y + listWaveSpot[i + 1].position.y) / 2);
      listSupportPoint.add(supportPoint);
    }

    path.moveTo(listWaveSpot[0].position.x, listWaveSpot[0].position.y);
    path.lineTo(listSupportPoint[0].x, listSupportPoint[0].y);
    for (int i = 1; i < listWaveSpot.length - 1; i++) {
      path.quadraticBezierTo(listWaveSpot[i].position.x, listWaveSpot[i].position.y, listSupportPoint[i].x, listSupportPoint[i].y);
    }
    path.lineTo(listWaveSpot[listWaveSpot.length - 1].position.x, listWaveSpot[listWaveSpot.length - 1].position.y);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
