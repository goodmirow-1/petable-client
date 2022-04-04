import 'package:flutter/material.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/Home/health_score_guide_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HealthScoreWidget extends StatelessWidget {
  HealthScoreWidget({Key? key, this.isOverlay = false}) : super(key: key);

  final bool isOverlay;

  final DashBoardController controller = Get.find<DashBoardController>();
  final BowlPageController bowlPageController = Get.find<BowlPageController>();

  final Duration graphDuration = Duration(milliseconds: 1000);
  final Duration waveDuration = Duration(milliseconds: 700);
  final int graphDurationInt = 1000;

  final String svgRankBowlIcon = 'assets/image/dash_board/rankBowlIcon.svg'; // 건강점수 밥그릇 아이콘
  final String svgRankWaterIcon = 'assets/image/dash_board/rankWaterIcon.svg'; // 건강점수 물방울 아이콘
  final String svgRankScaleIcon = 'assets/image/dash_board/rankScaleIcon.svg'; // 건강점수 저울 아이콘

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.changeHealthScoreGraph(),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          padding: EdgeInsets.fromLTRB(20 * sizeUnit, 18 * sizeUnit, 18 * sizeUnit, 16 * sizeUnit),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isOverlay ? Color.fromRGBO(255, 255, 255, 1.0) : Color.fromRGBO(255, 255, 255, 0.8),
            boxShadow: vfBasicBoxShadow,
            borderRadius: BorderRadius.circular(20 * sizeUnit),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 4 * sizeUnit),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6 * sizeUnit),
                              Text('건강점수', style: VfTextStyle.highlight3()),
                              SizedBox(height: 4 * sizeUnit),
                              Obx(() => Text(
                                    '${GlobalData.mainPet.value.name}는 ${controller.healthLocation.value}에서 상위',
                                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isOverlay) ...[
                    GestureDetector(
                      onTap: () {
                        controller.healthScoreGuideLevel(1); // 가이드 레벨 초기화
                        Get.dialog(
                          HealthScoreGuideWidget(),
                        );
                      },
                      child: SvgPicture.asset(
                        svgQuestionInCircle,
                        width: 24 * sizeUnit,
                        height: 24 * sizeUnit,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16 * sizeUnit),
              Column(
                children: [
                  Row(
                    children: [
                      circleInIconWidget(
                        vfColorOrange20,
                        SvgPicture.asset(
                          svgRankBowlIcon,
                          width: 18 * sizeUnit,
                          height: 10 * sizeUnit,
                        ),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      Obx(() => bowlPageController.isHaveFoodBowl.value
                          ? customLinearGraph(
                              ratio: controller.healthFeedRatio.value,
                              color: vfColorOrange20,
                              score: controller.healthFeedScore.value,
                              scoreColor: vfColorOrange,
                            )
                          : Container(
                              width: 48 * sizeUnit,
                              height: 32 * sizeUnit,
                              decoration: BoxDecoration(
                                color: vfColorOrange20,
                                borderRadius: BorderRadius.circular(16 * sizeUnit),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 16 * sizeUnit),
                                  Text('- %', style: VfTextStyle.body1()),
                                ],
                              ),
                            )),
                    ],
                  ),
                  SizedBox(height: 8 * sizeUnit),
                  Row(
                    children: [
                      circleInIconWidget(
                        vfColorSkyBlue20,
                        SvgPicture.asset(
                          svgRankWaterIcon,
                          width: 12 * sizeUnit,
                          height: 16 * sizeUnit,
                        ),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      Obx(() => bowlPageController.isHaveWaterBowl.value
                          ? customLinearGraph(
                              ratio: controller.healthWaterRatio.value,
                              color: vfColorSkyBlue20,
                              score: controller.healthWaterScore.value,
                              scoreColor: vfColorSkyBlue,
                            )
                          : Container(
                              width: 48 * sizeUnit,
                              height: 32 * sizeUnit,
                              decoration: BoxDecoration(
                                color: vfColorSkyBlue20,
                                borderRadius: BorderRadius.circular(16 * sizeUnit),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 16 * sizeUnit),
                                  Text('- %', style: VfTextStyle.body1()),
                                ],
                              ),
                            )),
                    ],
                  ),
                  SizedBox(height: 8 * sizeUnit),
                  Row(
                    children: [
                      circleInIconWidget(
                        vfColorPink20,
                        SvgPicture.asset(
                          svgRankScaleIcon,
                          width: 12 * sizeUnit,
                          height: 13 * sizeUnit,
                        ),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      if (GlobalData.mainPet.value.weight != nullDouble) ...[
                        Obx(() => customLinearGraph(
                              ratio: controller.healthWeightRatio.value,
                              color: vfColorPink20,
                            )),
                      ] else ...[
                        Container(
                          width: 48 * sizeUnit,
                          height: 32 * sizeUnit,
                          decoration: BoxDecoration(
                            color: vfColorPink20,
                            borderRadius: BorderRadius.circular(16 * sizeUnit),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 16 * sizeUnit),
                              Text('- %', style: VfTextStyle.body1()),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Container circleInIconWidget(Color color, Widget iconWidget) {
    return Container(
      alignment: Alignment.center,
      width: 32 * sizeUnit,
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: iconWidget,
    );
  }

  Widget customLinearGraph({required double ratio, required Color color, double? score, Color scoreColor = Colors.black}) {
    double _percent = score == null ? ratio : score / 100;
    _percent = 0.17 + _percent * 0.83;

    return LinearPercentIndicator(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      width: 248 * sizeUnit,
      lineHeight: 32 * sizeUnit,
      percent: _percent,
      backgroundColor: Colors.transparent,
      progressColor: color,
      animation: true,
      animationDuration: graphDurationInt,
      center: Stack(
        children: [
          TweenAnimationBuilder(
            duration: graphDuration,
            tween: Tween<double>(begin: 1, end: ratio),
            builder: (context, double value, child){
              int percent = (100 - (value * 100)).toInt();
              if(percent < 1) percent = 1;
              String text = percent.toString() + '%';
              return Text(
                text,
                style: VfTextStyle.subTitle2(),
              );
            },
          ),
          Row(
            children: [
              if (score != null) ...[
                TweenAnimationBuilder(
                  duration: graphDuration,
                  tween: Tween<double>(begin: 0, end: _percent),
                  builder: (context, double value, child) {
                    double _value = value < 0.20 ? 0.20 : value;
                    double _width = 18 + 230 * _value;
                    if(_value > 0.45){
                      double tmp = 20*_value;
                      _width -= 56 + tmp;
                    }
                    return SizedBox(
                      width: _width * sizeUnit,
                    );
                  },
                ),
                TweenAnimationBuilder(
                  duration: graphDuration,
                  tween: Tween<double>(begin: 0, end: score),
                  builder: (context, double value, child) => Text(
                    value.round().toString() + '점',
                    style: VfTextStyle.subTitle2().copyWith(color: scoreColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
