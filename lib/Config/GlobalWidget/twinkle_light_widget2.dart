import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';

class TwinkleLight2 extends StatefulWidget {
  final List<int> onOffTime;//[on,off,on,off] 이후 루프
  final double left;
  final double top;
  final bool isFront;

  const TwinkleLight2({Key? key, required this.onOffTime, required this.left, required this.top, this.isFront = false}) : super(key: key);

  @override
  _TwinkleLight2State createState() => _TwinkleLight2State();
}

class _TwinkleLight2State extends State<TwinkleLight2> {
  List<int> onOffTime = [1000,1000];

  bool isOn = false;

  double size = 30;

  Color color = Color(0xFF00FF47);

  bool isOnPage = true;

  int index = 0;
  int length = 0;

  void lightOn() {
    if (isOnPage) {
      setState(() {
        isOn = true;
      });
      if(index < length){
        Future.delayed(Duration(milliseconds: onOffTime[index]), (){
          index++;
          if(index == length) index = 0;
          lightOff();
        });
      }

    }
  }

  void lightOff() {
    if (isOnPage) {
      setState(() {
        isOn = false;
      });
      if(index < length){
        Future.delayed(Duration(milliseconds: onOffTime[index]), (){
          index++;
          if(index == length) index = 0;
          lightOn();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isOnPage = true;

    if(widget.isFront){
      size = 70 * sizeUnit;
    } else {
      size = 30 * sizeUnit;
    }

    if(onOffTime.length == 0){
      onOffTime = [10000];
    } else{
      onOffTime = widget.onOffTime;
    }

    index = 0;
    length = onOffTime.length;

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
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              gradient: RadialGradient(
                radius: 0.6,
                colors: [
                  color.withOpacity(isOn ? 1 : 0),
                  Colors.white.withOpacity(isOn ? 0.01 : 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
