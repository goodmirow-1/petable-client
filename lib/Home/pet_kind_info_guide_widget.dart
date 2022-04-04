import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Home/pet_kind_info_widget.dart';

class PetKindInfoGuideWidget extends StatelessWidget {
  PetKindInfoGuideWidget({Key? key}) : super(key: key);

  final DashBoardController controller = Get.find<DashBoardController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.petKindInfoGuideLevel.value >= 1) {
          Get.back();
        } else {
          controller.petKindInfoGuideLevel.value++;
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
                PetKindInfoWidget(isOverlay: true),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGuidLevel1() {
    return Obx(() => controller.petKindInfoGuideLevel.value == 1
        ? Positioned(
            bottom: 16 * sizeUnit,
      left: 0,
      right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                      height: 48 * sizeUnit,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                      height: 48 * sizeUnit,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: vfColorOrange20,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        GlobalData.mainPet.value.weight == nullDouble ? '아직 데이터가 없어요...' : '832g 더 무거워요!',
                        style: VfTextStyle.subTitle3(),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 100 * sizeUnit,
                  bottom: 50 * sizeUnit,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(-26 / 360),
                    child: SvgPicture.asset(svgTailIcon),
                  ),
                ),
                Positioned(
                  left: 130 * sizeUnit,
                  bottom: 56 * sizeUnit,
                  child: Text(
                    '마이베프에 등록된 동일품종의\n평균 몸무게와 비교해줘요',
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
