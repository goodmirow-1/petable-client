import 'dart:ui';

import 'package:flutter/material.dart';

class TwinkleLightBreath extends StatefulWidget {
  final int duration;
  final double left;
  final double top;

  const TwinkleLightBreath({Key? key, required this.duration, required this.left, required this.top}) : super(key: key);

  @override
  _TwinkleLightBreathState createState() => _TwinkleLightBreathState();
}

class _TwinkleLightBreathState extends State<TwinkleLightBreath> {
  int duration = 1000; //ms

  bool isOn = false;

  double size = 30;

  Color color = Color(0xFF00FF47);
  bool isOnPage = true;

  void lightOn() {
    if (isOnPage) {
      setState(() {
        isOn = true;
      });
      Future.delayed(Duration(milliseconds: duration), () => lightOff());
    }
  }

  void lightOff() {
    if (isOnPage) {
      setState(() {
        isOn = false;
      });
      Future.delayed(Duration(milliseconds: duration), () => lightOn());
    }
  }

  @override
  void initState() {
    super.initState();
    isOnPage = true;

    duration = widget.duration;

    lightOn();
  }

  @override
  void dispose() {
    isOnPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.left,
          top: widget.top,
          child: AnimatedContainer(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              gradient: RadialGradient(
                radius: 0.5,
                colors: [
                  color.withOpacity(isOn ? 1 : 0),
                  Colors.white.withOpacity(isOn ? 0.01 : 0),
                ],
              ),
            ), duration: Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }
}
