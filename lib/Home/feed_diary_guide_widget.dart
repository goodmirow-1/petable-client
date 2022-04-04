import 'package:flutter/material.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Home/feed_diary_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedDiaryGuideWidget extends StatelessWidget {
  FeedDiaryGuideWidget({Key? key}) : super(key: key);

  final DashBoardController controller = Get.find<DashBoardController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.feedDiaryGuideLevel.value >= 2) {
          Get.back();
        } else {
          controller.feedDiaryGuideLevel.value++;
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildCancelButton(),
            Stack(
              children: [
                FeedDiaryWidget(isOverlay: true),
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20 * sizeUnit),
                    ),
                  ),
                ),
                buildGuidLevel1(),
                buildGuidLevel2(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGuidLevel1() {
    return Obx(() => controller.feedDiaryGuideLevel.value == 1
        ? Positioned(
            left: 56 * sizeUnit,
            bottom: 16 * sizeUnit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    diaryItem(
                      color: vfColorOrange20,
                      content: controller.feedDiaryNutritionText(),
                      contentStyle: BowlPageController.to.isHaveFoodBowl.value ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                    ),
                    SizedBox(width: 40 * sizeUnit),
                    diaryItem(
                      color: vfColorSkyBlue20,
                      content: controller.feedDiaryWaterText(),
                      contentStyle: BowlPageController.to.isHaveWaterBowl.value ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                    ),
                  ],
                ),
                Positioned(
                  left: 4 * sizeUnit,
                  bottom: -70 * sizeUnit,
                  child: Text(
                    '수분 보충과 영양상태는\n전날 섭취량을 기반으로\n섭취 상태를 알려줘요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink());
  }

  Widget buildGuidLevel2() {
    return Obx(() => controller.feedDiaryGuideLevel.value == 2
        ? Positioned(
            right: 56 * sizeUnit,
            bottom: 16 * sizeUnit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                diaryItem(
                  color: vfColorPink20,
                  content: controller.todayFeedFillTime,
                  contentStyle: controller.todayFeedFillTime != '-' ? VfTextStyle.subTitle3() : VfTextStyle.body1(),
                ),
                Positioned(
                  right: 26 * sizeUnit,
                  bottom: 58 * sizeUnit,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(56 / 360),
                    child: SvgPicture.asset(svgTailIcon),
                  ),
                ),
                Positioned(
                  right: 52 * sizeUnit,
                  bottom: 58 * sizeUnit,
                  child: Text(
                    '배급시간은 가장 최근\n배급한 시간을 나타내요!',
                    style: VfTextStyle.body1().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink());
  }

  Widget diaryItem({required Color color, required String content, required TextStyle contentStyle}) {
    return Stack(
      children: [
        Container(
          width: 56 * sizeUnit,
          height: 56 * sizeUnit,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
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
}
