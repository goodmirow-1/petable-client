import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Home/feed_diary_guide_widget.dart';

class FeedDiaryWidget extends StatelessWidget {
  FeedDiaryWidget({Key? key, this.isOverlay = false}) : super(key: key);

  final bool isOverlay;

  final BowlPageController bowlPageController = Get.find<BowlPageController>();
  final DashBoardController controller = Get.find<DashBoardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      padding: EdgeInsets.only(top: 24 * sizeUnit, bottom: 16 * sizeUnit),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isOverlay ? Color.fromRGBO(255, 255, 255, 1.0) : Color.fromRGBO(255, 255, 255, 0.8),
        boxShadow: vfBasicBoxShadow,
        borderRadius: BorderRadius.circular(20 * sizeUnit),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 24 * sizeUnit, right: 18 * sizeUnit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('냠냠일지', style: VfTextStyle.highlight3()),
                    IgnorePointer(
                      ignoring: isOverlay,
                      child: GestureDetector(
                        onTap: () {
                          controller.feedDiaryGuideLevel(1); // 가이드 레벨 초기화
                          Get.dialog(
                            FeedDiaryGuideWidget(),
                          );
                        },
                        child: SvgPicture.asset(
                          svgQuestionInCircle,
                          width: 24 * sizeUnit,
                          height: 24 * sizeUnit,
                          color: isOverlay ? Colors.transparent : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * sizeUnit),
                Text(
                  '${GlobalData.mainPet.value.name}의 섭취정보',
                  style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                ),
              ],
            ),
          ),
          SizedBox(height: 22 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
            child: Row(
              children: [
                Obx(() {
                  return buildFeedDiaryItem(
                    title: '영양상태',
                    color: vfColorOrange20,
                    content: controller.feedDiaryNutritionText(),
                    contentStyle: bowlPageController.isHaveFoodBowl.value ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                  );
                }),
                SizedBox(width: 40 * sizeUnit),
                Obx(() {
                  return buildFeedDiaryItem(
                    title: '수분보충',
                    color: vfColorSkyBlue20,
                    content: controller.feedDiaryWaterText(),
                    contentStyle: bowlPageController.isHaveWaterBowl.value ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                  );
                }),
                SizedBox(width: 40 * sizeUnit),
                buildFeedDiaryItem(
                  title: '배급시간',
                  color: vfColorPink20,
                  content: controller.todayFeedFillTime,
                  contentStyle: controller.todayFeedFillTime != '-' ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column buildFeedDiaryItem({required String title, required Color color, required String content, required TextStyle contentStyle}) {
    return Column(
      children: [
        Text(
          title,
          style: VfTextStyle.subTitle5().copyWith(color: vfColorDarkGray),
        ),
        SizedBox(height: 10 * sizeUnit),
        Container(
          width: 56 * sizeUnit,
          height: 56 * sizeUnit,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            content,
            style: contentStyle,
          ),
        ),
      ],
    );
  }
}
