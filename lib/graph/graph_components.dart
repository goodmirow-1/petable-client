import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:intl/intl.dart';
import 'package:myvef_app/graph/model/graph_data.dart';

class GraphComponent {
  final GraphPageController controller = Get.find<GraphPageController>();

  final String svgSpeechBubble = 'assets/image/graph/speechBubbleIcon.svg';
  final String svgGraduation = 'assets/image/graph/graduationIcon.svg';

  // 그래프 바
  TweenAnimationBuilder<double> graphBar({
    required GraphData intake,
    required int index,
    required bool isFeed,
    required RxInt selectedIndex,
    required RxInt maxIntake,
    required GestureTapCallback onTap,
  }) {
    // bar
    Widget bar({required double height, bool isMain = true}) {
      List<Color> feedColors = [vfColorOrange, Color.fromRGBO(255, 255, 255, 0.78)];
      List<Color> waterColors = [vfColorWaterBlue, Color.fromRGBO(255, 255, 255, 0.78)];

      if (isFeed) {
        if (!isMain) feedColors = [Color.fromRGBO(245, 69, 59, 1), Color.fromRGBO(245, 69, 59, 0)];
      } else {
        if (!isMain) waterColors = [vfColorSkyBlue, vfColorSkyBlue.withOpacity(0.0)];
      }

      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          width: selectedIndex.value == index
              ? intake.total == 0
                  ? 0
                  : 16 * sizeUnit
              : intake.total == 0
                  ? 0
                  : 14 * sizeUnit,
          child: Container(
              constraints: BoxConstraints(maxHeight: controller.barMaxHeight),
              padding: EdgeInsets.all(2 * sizeUnit),
              width: selectedIndex.value == index
                  ? intake.total == 0
                      ? 0
                      : 16 * sizeUnit
                  : intake.total == 0
                      ? 0
                      : 8 * sizeUnit,
              height: height,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * sizeUnit),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isFeed ? feedColors : waterColors,
                ),
              ),
              // 탭 했을 때 활성화 되는 blurCircle
              child: selectedIndex.value == index
                  ? isMain
                      ? circleBlurWidget(isFeed ? vfColorOrange : vfColorWaterBlue)
                      : intake.main == 0
                          ? circleBlurWidget(isFeed ? vfColorOrange : vfColorWaterBlue)
                          : SizedBox.shrink()
                  : SizedBox.shrink()),
        ),
      );
    }

    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: intake.total / maxIntake.value),
        duration: controller.barDuration,
        builder: (context, double value, child) {
          double height = intake.total == 0 ? 0 : value * controller.barMaxHeight;
          double subHeight = height * (intake.sub / intake.total);

          return Obx(
            () => Stack(
              children: [
                bar(height: height),
                Positioned(
                  bottom: 0,
                  child: bar(height: subHeight, isMain: false),
                ),
              ],
            ),
          );
        });
  }

  // 그램수 나오는 말풍선
  Widget gramBubble({required int index, required int intakeAmount, double left = 0, required Color mainColor, required RxInt selectedIndex, required RxInt maxIntake}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: intakeAmount / maxIntake.value),
      duration: controller.barDuration,
      builder: (context, double value, child) => Positioned(
        bottom: value * controller.barMaxHeight > controller.barMaxHeight ? controller.barMaxHeight + 16 * sizeUnit : (value * controller.barMaxHeight) + 16 * sizeUnit,
        left: left,
        child: Obx(
          () => selectedIndex.value == index
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 38 * sizeUnit, minHeight: 24 * sizeUnit),
                      child: SvgPicture.asset(
                        svgSpeechBubble,
                        width: (intakeAmount.toString().length) * 10 * sizeUnit + 8,
                        color: mainColor,
                      ),
                    ),
                    Text(
                      intakeAmount.toString(),
                      style: VfTextStyle.body1().copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 0.8),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }

  // 다음 달
  Align buildNextMont() {
    DateTime now = DateTime.now();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(left: 5 * sizeUnit, right: 10 * sizeUnit),
        child: Text(
          DateFormat('MMMM').format(DateTime(now.year, now.month + 1, now.day)).substring(0, 3),
          style: VfTextStyle.bWriteDate(),
        ),
      ),
    );
  }

  // 내일 요일
  Align buildTomorrow() {
    DateTime now = DateTime.now();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(left: 12 * sizeUnit, right: 10 * sizeUnit),
        child: Text(
          DateFormat('EEEE').format(DateTime(now.year, now.month, now.day + 1)).substring(0, 3),
          style: VfTextStyle.bWriteDate(),
        ),
      ),
    );
  }

// 하이라이트 텍스트
  Widget graphHighlightText(int intake, Color mainColor, String graphUnit, bool isFeed) {
    double highlightSize = 80 * sizeUnit;

    if (isFeed) {
      if (intake.toString().length < 3)
        highlightSize = 80 * sizeUnit;
      else if (intake.toString().length < 4)
        highlightSize = 100 * sizeUnit;
      else if (intake.toString().length < 5)
        highlightSize = 114 * sizeUnit;
      else
        highlightSize = (26 * sizeUnit) * intake.toString().length;
    } else {
      if (intake.toString().length < 3)
        highlightSize = 66 * sizeUnit;
      else if (intake.toString().length < 4)
        highlightSize = 84 * sizeUnit;
      else if (intake.toString().length < 5)
        highlightSize = 96 * sizeUnit;
      else
        highlightSize = (22 * sizeUnit) * intake.toString().length;
    }

    return highlightText(
      text: intake == 0 ? '00$graphUnit' : intake.toString() + graphUnit,
      style: VfTextStyle.headline3(),
      highlightColor: mainColor,
      highlightSize: highlightSize,
      highlightHeight: 6,
    );
  }

  Text xAxisText({required String text, required int index, required RxInt selectedIndex, required bool isFeed}) {
    return Text(
      text,
      style: VfTextStyle.bWriteDate().copyWith(
          color: selectedIndex.value == index
              ? isFeed
                  ? vfColorOrange
                  : vfColorSkyBlue
              : vfColorDarkGray),
    );
  }

// 백그라운드 눈금, y축 기준수
  Positioned backgroundWidget({required bool isGraduation, required RxInt maxIntake}) {
    double bottom = 10 * sizeUnit;

    return Positioned(
      bottom: bottom,
      child: SizedBox(
        height: controller.barMaxHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            9,
            (index) {
              return Obx(() {
                int result = maxIntake.value;
                int interval = controller.yInterval(maxIntake.value); // 보조선 간격

                if (index != 0) {
                  result = maxIntake.value - (interval * index);
                }

                if (result <= 0) {
                  return SizedBox.shrink();
                }

                return Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Opacity(
                          opacity: isGraduation ? 0.2 : 0.0,
                          child: Container(
                            width: Get.width - 38 * sizeUnit,
                            height: 1 * sizeUnit,
                            color: vfColorDarkGray,
                          ),
                        ),
                        SizedBox(width: 10 * sizeUnit),
                        Text(
                          result == 0 ? '00' : result.toString(),
                          style: VfTextStyle.body3().copyWith(color: isGraduation ? Colors.transparent : vfColorDarkGray),
                        ),
                        SizedBox(width: 16 * sizeUnit),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

// 탭 했을 때 활성화 되는 circleBlur
  Container circleBlurWidget(Color mainColor) {
    return Container(
      width: 12 * sizeUnit,
      height: 12 * sizeUnit,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * sizeUnit),
        child: Container(
          width: 8 * sizeUnit,
          height: 8 * sizeUnit,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6 * sizeUnit,
                height: 6 * sizeUnit,
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2 * sizeUnit, sigmaY: 2 * sizeUnit),
                child: Container(
                  width: 8 * sizeUnit,
                  height: 8 * sizeUnit,
                  color: Colors.black.withOpacity(0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // index 0 일 때 보여지는 눈금
  Widget buildFallGraduation() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(svgGraduation, height: 12 * sizeUnit, width: 12 * sizeUnit),
    );
  }
}
