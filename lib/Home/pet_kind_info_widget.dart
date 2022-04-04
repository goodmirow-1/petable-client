import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Home/pet_kind_info_guide_widget.dart';

class PetKindInfoWidget extends StatelessWidget {
  PetKindInfoWidget({Key? key, this.isOverlay = false}) : super(key: key);

  final bool isOverlay;
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
            padding: EdgeInsets.only(left: 24 * sizeUnit, right: 18 * sizeUnit),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('품종정보', style: VfTextStyle.highlight3()),
                    IgnorePointer(
                      ignoring: isOverlay,
                      child: GestureDetector(
                        onTap: () {
                          controller.petKindInfoGuideLevel(1); // 가이드 레벨 초기화
                          Get.dialog(
                            PetKindInfoGuideWidget(),
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
                  '${GlobalData.mainPet.value.name}는 ${GlobalData.mainPet.value.kind} ${petAgeCheck(GlobalData.mainPet.value.birthday)}대비',
                  style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * sizeUnit),
          Container(
            width: double.infinity,
            height: 48 * sizeUnit,
            margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
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
    );
  }
}
