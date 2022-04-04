import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Home/health_score_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HealthScoreGuideWidget extends StatelessWidget {
  HealthScoreGuideWidget({Key? key}) : super(key: key);


  final DashBoardController controller = Get.find<DashBoardController>();
  final String svgRankBowlIcon = 'assets/image/dash_board/rankBowlIcon.svg'; // 건강점수 밥그릇 아이콘
  final String svgRankWaterIcon = 'assets/image/dash_board/rankWaterIcon.svg'; // 건강점수 물방울 아이콘
  final String svgRankScaleIcon = 'assets/image/dash_board/rankScaleIcon.svg'; // 건강점수 저울 아이콘

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.healthScoreGuideLevel.value >= 6) {
          Get.back();
        } else {
          controller.healthScoreGuideLevel.value++;
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildCancelButton(), // X 버튼
            Stack(
              children: [
                HealthScoreWidget(isOverlay: true),
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20 * sizeUnit),
                    ),
                  ),
                ),
                buildIconGuide(), // 아이콘 가이드 (lv 1 ~ 3)
                buildGraphGuideLv4(), // 그래프 가이드 (lv 4)
                buildGraphGuideLv5(), // 그래프 가이드 (lv 5)
                buildGraphGuideLv6(), // 그래프 가이드 (lv 6)
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 그래프 설명
  Obx buildGraphGuideLv6() {
    return Obx(() => controller.healthScoreGuideLevel.value == 6
        ? Positioned(
            top: 78 * sizeUnit,
            left: 76 * sizeUnit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 34 * sizeUnit,
                  left: 26 * sizeUnit,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(-26 / 360),
                    child: SvgPicture.asset(svgTailIcon),
                  ),
                ),
                Positioned(
                  bottom: 34 * sizeUnit,
                  left: 22 * sizeUnit + 34 * sizeUnit,
                  child: Text(
                    '몸무게는 지역 상위\n퍼센트만 나타내줘요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80 * sizeUnit),
                    buildFixedPercentGraph(color: vfColorPink20, percent: calPercent(controller.healthWeightRatio.value)),
                  ],
                ),
              ],
            ),
          )
        : SizedBox.shrink());
  }

  // 그래프 설명
  Obx buildGraphGuideLv5() {
    return Obx(() => controller.healthScoreGuideLevel.value == 5
        ? Positioned(
            top: 78 * sizeUnit,
            left: 76 * sizeUnit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -15 * sizeUnit,
                  left: 22 * sizeUnit,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(-26 / 360),
                    child: SvgPicture.asset(svgTailIcon),
                  ),
                ),
                Positioned(
                  top: -44 * sizeUnit,
                  left: 22 * sizeUnit + 32 * sizeUnit,
                  child: Text(
                    '점수가 상위 몇 퍼센트에\n해당하는지 알려줘요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4 * sizeUnit,
                  left: 76 * sizeUnit,
                  child: Text(
                    '반려동물의 점수가 높을수록\n상위 1%에 속 할 수 있어요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFixedPercentGraph(color: vfColorOrange20, percent: calPercent(controller.healthFeedRatio.value)),
                    SizedBox(height: 8 * sizeUnit),
                    buildFixedPercentGraph(color: vfColorSkyBlue20, percent: calPercent(controller.healthWaterRatio.value)),
                  ],
                ),
              ],
            ),
          )
        : SizedBox.shrink());
  }

  Material buildFixedPercentGraph({required Color color, required int percent}) {
    return Material(
      borderRadius: BorderRadius.circular(16 * sizeUnit),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 66 * sizeUnit,
            height: 32 * sizeUnit,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16 * sizeUnit),
            ),
          ),
          Positioned(
            left: 16 * sizeUnit,
            child: Text(percent.toString() + '%', style: VfTextStyle.subTitle2()),
          ),
        ],
      ),
    );
  }

  // 그래프 설명
  Obx buildGraphGuideLv4() {
    // 그래프는 점수를 나타내요! x 포지션
    double firstTextX = (248 * sizeUnit) * (controller.healthFeedRatio.value + calConstant(controller.healthFeedRatio.value)) * 0.3 > Get.width * 0.1
        ? Get.width * 0.1
        : (248 * sizeUnit) * (controller.healthFeedRatio.value + calConstant(controller.healthFeedRatio.value)) * 0.3;

    return Obx(() => controller.healthScoreGuideLevel.value == 4
        ? Positioned(
            top: 78 * sizeUnit,
            left: 76 * sizeUnit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -15 * sizeUnit,
                  left: firstTextX,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(-26 / 360),
                    child: SvgPicture.asset(svgTailIcon),
                  ),
                ),
                Positioned(
                  top: -28 * sizeUnit,
                  left: firstTextX + 28 * sizeUnit,
                  child: Text(
                    '그래프는 점수를 나타내요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50 * sizeUnit,
                  left: 20 * sizeUnit,
                  child: Text(
                    '점수는 권장량에 가까울 수록\n높은 점수를 받을 수 있어요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPercentGraph(
                      ratio: 0.5,
                      progressColor: vfColorOrange20,
                      scoreColor: vfColorOrange,
                      scoreRightPosition: 248 * sizeUnit * 0.5 - 8 * sizeUnit,
                    ),
                    SizedBox(height: 8 * sizeUnit),
                    buildPercentGraph(
                      ratio: 1.0,
                      progressColor: vfColorSkyBlue20,
                      scoreColor: vfColorSkyBlue,
                      scoreRightPosition: 8 * sizeUnit,
                    ),
                  ],
                ),
              ],
            ),
          )
        : SizedBox.shrink());
  }

  Stack buildPercentGraph({required double ratio, required Color progressColor, required Color scoreColor, required scoreRightPosition}) {
    return Stack(
      children: [
        LinearPercentIndicator(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          width: 248 * sizeUnit,
          lineHeight: 32 * sizeUnit,
          percent: ratio,
          backgroundColor: Colors.transparent,
          progressColor: Colors.white,
          animation: false,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            LinearPercentIndicator(
              padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
              width: 248 * sizeUnit,
              lineHeight: 32 * sizeUnit,
              percent: ratio,
              backgroundColor: Colors.transparent,
              progressColor: progressColor,
              animation: false,
            ),
            Positioned(
              right: scoreRightPosition,
              child: Text(
                (ratio * 100).toInt().toString() + '점',
                style: VfTextStyle.subTitle2().copyWith(color: scoreColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Positioned buildIconGuide() {
    return Positioned(
      top: 78 * sizeUnit,
      left: 36 * sizeUnit,
      child: Column(
        children: [
          Obx(() => controller.healthScoreGuideLevel.value == 1
              ? circleInIconWidget(
                  color: vfColorOrange20,
                  iconWidget: SvgPicture.asset(
                    svgRankBowlIcon,
                    width: 18 * sizeUnit,
                    height: 10 * sizeUnit,
                  ),
                  description: '섭취량',
                )
              : SizedBox(height: 32 * sizeUnit)),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => controller.healthScoreGuideLevel.value == 2
              ? circleInIconWidget(
                  color: vfColorSkyBlue20,
                  iconWidget: SvgPicture.asset(
                    svgRankWaterIcon,
                    width: 12 * sizeUnit,
                    height: 16 * sizeUnit,
                  ),
                  description: '음수량',
                )
              : SizedBox(height: 32 * sizeUnit)),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => controller.healthScoreGuideLevel.value == 3
              ? circleInIconWidget(
                  color: vfColorPink20,
                  iconWidget: SvgPicture.asset(
                    svgRankScaleIcon,
                    width: 12 * sizeUnit,
                    height: 13 * sizeUnit,
                  ),
                  description: '몸무게',
                )
              : SizedBox(height: 32 * sizeUnit)),
        ],
      ),
    );
  }

  Positioned buildCancelButton() {
    return Positioned(
      top: 32 * sizeUnit,
      right: 16 * sizeUnit,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: SvgPicture.asset(
          svgWhiteCancelIcon,
          width: 20 * sizeUnit,
          height: 20 * sizeUnit,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget circleInIconWidget({required Color color, required Widget iconWidget, required String description}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          borderRadius: BorderRadius.circular(16 * sizeUnit),
          child: Container(
            alignment: Alignment.center,
            width: 32 * sizeUnit,
            height: 32 * sizeUnit,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: iconWidget,
          ),
        ),
        Positioned(
          left: 26 * sizeUnit,
          top: -6 * sizeUnit,
          child: SvgPicture.asset(svgTailIcon),
        ),
        Positioned(
          left: 58 * sizeUnit,
          top: -14 * sizeUnit,
          child: Text(
            description,
            style: VfTextStyle.body1().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  double calConstant(double ratio) {
    double result = 0.0;

    if (ratio == 0.0 && ratio == 1.0)
      result = 0.0;
    else if (ratio <= 0.1)
      result = 0.12;
    else if (ratio <= 0.2)
      result = 0.1;
    else if (ratio <= 0.3)
      result = 0.09;
    else if (ratio <= 0.4)
      result = 0.075;
    else if (ratio <= 0.5)
      result = 0.065;
    else if (ratio <= 0.6)
      result = 0.05;
    else if (ratio <= 0.7)
      result = 0.04;
    else if (ratio <= 0.8)
      result = 0.025;
    else if (ratio <= 0.9) result = 0.01;

    return result;
  }

  int calPercent(double ratio) {
    int percent = (100 - (ratio * 100)).toInt();

    if (percent <= 0) percent = 1;

    return percent;
  }
}
