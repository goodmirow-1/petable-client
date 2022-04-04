import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';

import 'package:vector_math/vector_math.dart' hide Colors;

const double BASIC_BALL_DIAMETER = 24; // 볼 기본 지름

class DropCircleAnimationWidget extends StatefulWidget {
  final double width; //match parent
  final double height; //match parent
  final double ratio; //높이 비율 0~1
  final double ballDiameter; // 볼 지름
  final bool showFloorGradient; // 맨 밑 그라데이션 노출 여부
  const DropCircleAnimationWidget({Key? key, required this.width, required this.height, required this.ratio, this.ballDiameter = BASIC_BALL_DIAMETER, this.showFloorGradient = true}) : super(key: key);

  @override
  _DropCircleAnimationWidgetState createState() => _DropCircleAnimationWidgetState();
}

class _DropCircleAnimationWidgetState extends State<DropCircleAnimationWidget> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  late double width;
  late double height;

  late double ratio;

  late int numberOfBall;

  List<Ball> listBaseBall = [];
  List<Ball> listBall = [];

  double time = 0;
  double maxTime = 7;

  @override
  void initState() {
    width = widget.width;
    height = widget.height;

    ratio = widget.ratio;
    if (ratio.isNaN) ratio = 0.5;
    if (ratio > 1) ratio = 1;

    double num = widget.ballDiameter >= BASIC_BALL_DIAMETER ? 0.65 : 0.45; // 볼 지름에 따라 numberOfBall 값이 바뀜
    numberOfBall = (height * ratio * num).round();

    controller = AnimationController(vsync: this, duration: Duration(seconds: maxTime.toInt()));

    Tween<double> timeTween = Tween(begin: 0, end: 1);

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

    makeBallList(numberOfBall);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: CustomPaint(
            painter: BallPainter(time: controller.value, listBall: listBall, listBaseBall: listBaseBall, maxTime: maxTime, ballDiameter: widget.ballDiameter),
            child: Container(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                height: widget.height * ratio * 0.9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0), vfGradationRed1.withOpacity(0.2), vfGradationRed1, vfGradationRed2],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              if(widget.showFloorGradient)...[
                Container(
                  width: double.maxFinite,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [vfGradationRed2, Colors.white.withOpacity(0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void makeBallList(int numberOfBall) {
    int maxFallBall = widget.ballDiameter >= BASIC_BALL_DIAMETER ? 45 : 16; // 볼 지름에 따라 최대 떨어지는 공 갯수 바뀜
    int numberOfBaseBall = numberOfBall > maxFallBall ? numberOfBall - maxFallBall : 0;
    int numberOfFallBall = numberOfBall > maxFallBall ? maxFallBall : numberOfBall;
    int tmp = 2;
    double ballRadius = widget.ballDiameter / 2;
    double x = Random().nextDouble() * tmp;
    double y = height - ballRadius * 2;

    listBaseBall.clear();
    //바닥 볼 세팅
    for (int i = 0; i < numberOfBaseBall; i++) {
      x += ballRadius * 2 + Random().nextDouble() * tmp;
      if (x > width - ballRadius) {
        y -= ballRadius * 2 + tmp;
        x = 2 * ballRadius + Random().nextDouble() * tmp;
      }
      Ball ball = Ball(
        radius: ballRadius,
        position: Vector2(x, y + Random().nextDouble() * tmp),
      );
      ball.velocity = Vector2(0, 0);
      listBaseBall.add(ball);
    }

    final double ballDiameter = widget.ballDiameter;
    final double gravity = 10 * maxTime;

    //바닥볼 배치
    int maxLoopCount = 500;
    for (int i = 0; i < maxLoopCount; i++) {
      double dt = 0.01;
      listBaseBall.forEach((Ball ball) {
        double stopRatio = 2 * (1 - i / maxLoopCount);
        if (ball.position.y / height > stopRatio) {
          //좌표 고정 계산 안함
        } else {
          ball.acceleration = Vector2(0, gravity);

          ball.velocity.x += ball.acceleration.x * dt;
          ball.velocity.y += ball.acceleration.y * dt;

          ball.position.x += ball.velocity.x * dt;
          ball.position.y += ball.velocity.y * dt;
        }
      });

      listBaseBall.forEach((ball) {
        //벽 충돌
        double stopRatio = 2 * (1 - i / maxLoopCount);
        if (ball.position.y / height > stopRatio) {
          //좌표 고정 계산 안함
        } else {
          //left wall
          if (ball.position.x < 0 + ballDiameter) {
            //속도 방향 반전 및 x 좌표 조정
            ball.position.x = ballDiameter;
            ball.velocity.x = ball.velocity.x.abs() * 0.5;
          }
          //right wall
          if (ball.position.x > width - ballDiameter) {
            //속도 방향 반전 및 x 좌표 조정
            ball.position.x = width - ballDiameter;
            ball.velocity.x = -ball.velocity.x.abs() * 0.5;
          }
          //bottom
          if (ball.position.y > height - ballDiameter) {
            //속도 방향 반전 및 y 좌표 조정
            ball.position.y = height - ballDiameter;
            ball.velocity.y = -ball.velocity.y.abs() * 0.2;
          }
        }
      });

      //공 충돌 처리
      for (int i = 0; i < listBaseBall.length - 1; i++) {
        for (int j = i + 1; j < listBaseBall.length; j++) {
          //공 충돌
          if (listBaseBall[i].isBallsOverlap(listBaseBall[i], listBaseBall[j])) {
            Vector2 normal = (listBaseBall[j].position - listBaseBall[i].position).normalized();
            //충돌 해소
            listBaseBall[i].resolveCollision(listBaseBall[i], listBaseBall[j], normal);
            //위치 조정
            listBaseBall[i].positionalCorrection(listBaseBall[i], listBaseBall[j], normal);
          }
        }
      }

      listBaseBall.sort((a, b) => b.position.y.compareTo(a.position.y));
    }

    //공중 볼 세팅
    listBall.clear();

    int dropType = 1;

    switch (dropType) {
      case 0:
        {
          double xLeftLimit = 0;
          double xRightLimit = width;
          x = xLeftLimit;
          y = 0;
          double initialFallSpeed = 200 * maxTime;
          double initialXSpeed = 0;
          for (int i = 0; i < numberOfFallBall; i++) {
            x += ballRadius * 2 + Random().nextDouble() * 10;
            if (x > xRightLimit - ballRadius) {
              y -= ballRadius * 2 + 10;
              x = xLeftLimit + ballRadius + Random().nextDouble() * 10;
            }
            Ball ball = Ball(
              radius: ballRadius,
              position: Vector2(x, y + Random().nextDouble() * 10),
            );
            ball.velocity = Vector2(initialXSpeed + (Random().nextDouble() - 0.5) * 100 * maxTime, initialFallSpeed + Random().nextDouble() * 50 * maxTime);
            listBall.add(ball);
          }
        }
        break;
      case 1: //가운데 모여서 수직 낙하
        {
          double xLeftLimit = width * 0.3;
          double xRightLimit = width * 0.7;
          x = xLeftLimit;
          y = -height * 0.2;
          double initialFallSpeed = 250 * maxTime;
          double initialXSpeed = 0;
          for (int i = 0; i < numberOfFallBall; i++) {
            x += ballRadius * 2 + Random().nextDouble() * 10;
            if (x > xRightLimit - ballRadius) {
              y -= ballRadius * 2 + 10;
              x = xLeftLimit + ballRadius + Random().nextDouble() * 10;
            }
            Ball ball = Ball(
              radius: ballRadius,
              position: Vector2(x, y + Random().nextDouble() * 10),
            );
            double fallSpeed = initialFallSpeed + y * 4;
            ball.velocity = Vector2(initialXSpeed + (Random().nextDouble() - 0.5) * 50 * maxTime, fallSpeed + Random().nextDouble() * 50 * maxTime);
            listBall.add(ball);
          }
        }
        break;
      case 2: //왼쪽으로 부어주는 느낌
        {
          double xLeftLimit = width * 0.5;
          double xRightLimit = width * 0.9;
          x = xLeftLimit;
          y = 0;
          double initialFallSpeed = 200 * maxTime;
          double initialXSpeed = -100 * maxTime;
          for (int i = 0; i < numberOfFallBall; i++) {
            x += ballRadius * 2 + Random().nextDouble() * 10;
            if (x > xRightLimit - ballRadius) {
              y -= ballRadius * 2 + 10;
              xLeftLimit += width * 0.04;
              xRightLimit += width * 0.04;
              x = xLeftLimit + ballRadius + Random().nextDouble() * 10;
            }
            Ball ball = Ball(
              radius: ballRadius,
              position: Vector2(x, y + Random().nextDouble() * 10),
            );
            double fallSpeed = initialFallSpeed + y * 4;
            ball.velocity = Vector2(initialXSpeed + (Random().nextDouble() - 0.5) * 10 * maxTime, fallSpeed + Random().nextDouble() * 50 * maxTime);
            listBall.add(ball);
          }
        }
        break;
      case 3: //오른쪽으로 부어주는 느낌
        {
          double xLeftLimit = width * 0.1;
          double xRightLimit = width * 0.5;
          x = xLeftLimit;
          y = 0;
          double initialFallSpeed = 200 * maxTime;
          double initialXSpeed = 100 * maxTime;
          for (int i = 0; i < numberOfFallBall; i++) {
            x += ballRadius * 2 + Random().nextDouble() * 10;
            if (x > xRightLimit - ballRadius) {
              y -= ballRadius * 2 + 10;
              xLeftLimit -= width * 0.04;
              xRightLimit -= width * 0.04;
              x = xLeftLimit + ballRadius + Random().nextDouble() * 10;
            }
            Ball ball = Ball(
              radius: ballRadius,
              position: Vector2(x, y + Random().nextDouble() * 10),
            );
            double fallSpeed = initialFallSpeed + y * 4;
            ball.velocity = Vector2(initialXSpeed + (Random().nextDouble() - 0.5) * 10 * maxTime, fallSpeed + Random().nextDouble() * 50 * maxTime);
            listBall.add(ball);
          }
        }
        break;
    }
  }
}

class Body {
  double mass = 1;
  double invMass = 1;

  Vector2 acceleration = Vector2.zero();
  Vector2 velocity = Vector2.zero();

  double restitution = 0.5;

  double previousTime = 0;

  setMass(double _mass) {
    this.mass = _mass;
    if (_mass != 0)
      this.invMass = 1 / _mass;
    else
      this.invMass = 0;
  }

  void resolveCollision(Body a, Body b, Vector2 normal) {
    // Calculate relative velocity
    Vector2 relativeVelocity = b.velocity - a.velocity;

    // Calculate relative velocity in terms of the normal direction
    double velAlongNormal = relativeVelocity.dot(normal);

    // Do not resolve if velocities are separating
    if (velAlongNormal > 0) return;

    // Calculate restitution
    double e = min(a.restitution, b.restitution);

    // Calculate impulse scalar
    double j = -(1 + e) * velAlongNormal;
    j /= a.invMass + b.invMass;

    // Apply impulse
    Vector2 impulse = normal * j;

    double massSum = a.mass + b.mass;
    double ratio = a.mass / massSum;
    a.velocity -= impulse * ratio;
    ratio = b.mass / massSum;
    b.velocity += impulse * ratio;
  }
}

class Ball extends Body {
  double radius;
  Vector2 position;

  Ball({required this.radius, required this.position});

  bool isBallsOverlap(Ball a, Ball b) {
    double r = a.radius + b.radius;
    return r * r > pow(a.position.x - b.position.x, 2) + pow(a.position.y - b.position.y, 2);
  }

  void positionalCorrection(Ball a, Ball b, Vector2 n, {isWithBase = false}) {
    const double percent = 0.5; // usually 20% to 80%
    const double slop = 0.00000001; //usually 0.01 to 0.1
    final Vector2 n = (b.position - a.position).normalized();
    final double penetration = measureDistance(a, b);

    if (isWithBase) {
      Vector2 correction = n * max(penetration - slop, 0) / (a.invMass + b.invMass) * percent;
      a.position.x -= correction.x * a.invMass * 2;
      a.position.y -= correction.y * a.invMass * 2;
      return;
    }

    Vector2 correction = n * max(penetration - slop, 0) / (a.invMass + b.invMass) * percent;
    a.position.x -= correction.x * a.invMass;
    b.position.x += correction.x * b.invMass;
    a.position.y -= correction.y * a.invMass * 0;
    b.position.y += correction.y * b.invMass * 2;
  }

  double measureDistance(Ball a, Ball b) {
    double distance = 0;
    double dx = a.position.x - b.position.x;
    double dy = a.position.y - b.position.y;
    double radiusSum = a.radius + b.radius;
    if (dx.abs() < radiusSum && dy.abs() > radiusSum) return -1; //x y 모두 지름보다 멀리 떨어져있으면 거리 계산 안하고 -1 리턴
    distance = radiusSum - sqrt(pow(dx, 2) + pow(dy, 2));
    return distance;
  }
}

class Box extends Body {
  Vector2 min;
  Vector2 max;

  Box({required this.min, required this.max});
}

class BallPainter extends CustomPainter {
  final double time;
  final List<Ball> listBall;
  final List<Ball> listBaseBall;
  final double maxTime;
  final double ballDiameter;

  BallPainter({required this.time, required this.listBall, required this.listBaseBall, required this.maxTime, required this.ballDiameter});

  @override
  void paint(Canvas canvas, Size size) {
    final double gravity = 1500 * maxTime;

    var pointPaint = Paint()
      ..color = Color.fromRGBO(255, 207, 139, 0.6)
      ..strokeWidth = ballDiameter
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    //가속도 속도 위치 계산
    listBall.forEach((Ball ball) {
      ball.acceleration = Vector2(0, gravity);

      double dt = time - ball.previousTime;
      if (dt > 0.1 || dt < 0) dt = 0.01;
      ball.previousTime = time;

      ball.velocity.x += ball.acceleration.x * dt;
      ball.velocity.y += ball.acceleration.y * dt;

      ball.position.x += ball.velocity.x * dt;
      ball.position.y += ball.velocity.y * dt;
    });

    listBall.forEach((ball) {
      //벽 충돌
      //left wall
      if (ball.position.x < 0 + ballDiameter) {
        //속도 방향 반전 및 x 좌표 조정
        ball.position.x = ballDiameter;
        ball.velocity.x = ball.velocity.x.abs() * 0.8;
      }
      //right wall
      if (ball.position.x > size.width - ballDiameter) {
        //속도 방향 반전 및 x 좌표 조정
        ball.position.x = size.width - ballDiameter;
        ball.velocity.x = -ball.velocity.x.abs() * 0.8;
      }
      //bottom
      if (ball.position.y > size.height - ballDiameter) {
        //속도 방향 반전 및 y 좌표 조정
        ball.position.y = size.height - ballDiameter;
        ball.velocity.y = -ball.velocity.y.abs() * 0.4;
      }
    });

    //베이스랑 충돌처리
    listBall.forEach((ball) {
      for (int j = 0; j < listBaseBall.length; j++) {
        double dx = ball.position.x - listBaseBall[j].position.x;
        double dy = ball.position.y - listBaseBall[j].position.y;
        if (pow(dx, 2) + pow(dy, 2) > pow(ball.radius + listBaseBall[j].radius, 2)) {
        } else {
          Vector2 normal = (listBaseBall[j].position - ball.position).normalized();
          //충돌 해소 . 벽 충돌처럼 처리 운동 방향만 바꿔줌
          // Calculate relative velocity in terms of the normal direction
          Vector2 relativeVelocity = -ball.velocity;
          double velAlongNormal = relativeVelocity.dot(normal);
          // Do not resolve if velocities are separating
          if (velAlongNormal < 0) {
            ball.velocity = (ball.velocity + normal * 2 * (normal.dot(-ball.velocity))) * ball.restitution / 2;
          }

          //위치 조정
          ball.positionalCorrection(ball, listBaseBall[j], normal, isWithBase: true);
        }
      }
    });

    //공 충돌 처리
    for (int i = 0; i < listBall.length - 1; i++) {
      for (int j = i + 1; j < listBall.length; j++) {
        //공 충돌
        if (listBall[i].isBallsOverlap(listBall[i], listBall[j])) {
          Vector2 normal = (listBall[j].position - listBall[i].position).normalized();
          //충돌 해소
          listBall[i].resolveCollision(listBall[i], listBall[j], normal);
          //위치 조정
          listBall[i].positionalCorrection(listBall[i], listBall[j], normal);
        }
      }
    }

    listBall.sort((a, b) => b.position.y.compareTo(a.position.y));

    List<Offset> listOffset = [];
    listBaseBall.forEach((ball) {
      listOffset.add(Offset(ball.position.x, ball.position.y));
    });
    listBall.forEach((ball) {
      listOffset.add(Offset(ball.position.x, ball.position.y));
    });

    canvas.drawPoints(ui.PointMode.points, listOffset, pointPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
