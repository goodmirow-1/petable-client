import 'package:flutter/material.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/Constant.dart';

// ignore: must_be_immutable
class AnimatedTapBar extends StatefulWidget {
  int barIndex;
  final PageController pageController;
  final List<String> listTabItemTitle; //탭 이름 리스트

  AnimatedTapBar({required this.barIndex, required this.pageController, required this.listTabItemTitle});

  @override
  _AnimatedTapBarState createState() => _AnimatedTapBarState();
}

class _AnimatedTapBarState extends State<AnimatedTapBar> {
  final Duration duration = Duration(milliseconds: 500);
  final Curve curve = Curves.fastOutSlowIn;

  double horizontalPadding = 16;
  double bottomLineWidth = 24;

  double leftPadding = 0;
  double rightPadding = 0;

  int itemCount = 0;

  double itemWidth = 0;

  TextStyle _textStyle = VfTextStyle.subTitle2();

  @override
  void initState() {
    itemCount = widget.listTabItemTitle.length;
    if (itemCount != 0) {
      itemWidth = (360 - 2 * horizontalPadding) / itemCount;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    leftPadding = itemWidth * widget.barIndex + (itemWidth - bottomLineWidth) / 2;
    rightPadding = (itemWidth - bottomLineWidth) / 2 + itemWidth * (itemCount - 1 - widget.barIndex);

    return Container(
      height: 36 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 1 * sizeUnit),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.listTabItemTitle
                  .asMap()
                  .map((index, title) => MapEntry(
                index,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        unFocus(context);
                        widget.barIndex = index;
                        widget.pageController.animateToPage(index, duration: duration, curve: curve);
                        setState(() {});
                      },
                      child: Container(
                        width: 100 * sizeUnit,
                        height: 20 * sizeUnit,
                        color: Colors.white.withOpacity(0),
                        child: Center(
                          child: Text(
                            title,
                            style: _textStyle.copyWith(color: widget.barIndex == index ? vfColorBlack : vfColorDarkGray),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
                  .values
                  .toList(),
            ),
            Row(
              children: [
                AnimatedContainer(
                  width: leftPadding * sizeUnit,
                  duration: duration,
                  curve: curve,
                ),
                Container(
                  color: vfColorBlack,
                  width: bottomLineWidth * sizeUnit,
                  height: 2 * sizeUnit,
                ),
                AnimatedContainer(
                  width: rightPadding * sizeUnit,
                  duration: duration,
                  curve: curve,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
