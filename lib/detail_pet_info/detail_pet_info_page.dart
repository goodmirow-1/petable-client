import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/Painter/circle_paint_widget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:flutter_svg/svg.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';

import 'detail_pet_info_selecting_page.dart';

class DetailPetInfo extends StatelessWidget {
  const DetailPetInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Violet,
      child: Scaffold(
        appBar: vfAppBar(context, title: '반려동물 상세 정보'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 24 * sizeUnit),
                  child: Column(
                    children: [
                      Text(GlobalData.mainPet.value.name, style: VfTextStyle.headline2()),
                      SizedBox(height: 12 * sizeUnit),
                      Wrap(
                        spacing: 8 * sizeUnit,
                        runSpacing: 8 * sizeUnit,
                        children: [
                          if (GlobalData.mainPet.value.kind.isNotEmpty) petTagItem(GlobalData.mainPet.value.kind),
                          if (GlobalData.mainPet.value.birthday.isNotEmpty) petTagItem(GlobalData.mainPet.value.birthday),
                          petTagItem(abbreviateForLocation(GlobalData.loggedInUser.value.location)),
                        ],
                      ),
                      SizedBox(height: 16 * sizeUnit),
                      Container(
                        width: double.infinity,
                        height: 342 * sizeUnit,
                        decoration: BoxDecoration(
                          boxShadow: GlobalData.mainPet.value.petPhotos.isEmpty ? vfBasicBoxShadow : vfImgBoxShadow,
                        ),
                        child: (GlobalData.mainPet.value.petPhotos.isEmpty)
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20 * sizeUnit),
                                ),
                                child: CirclePaintWidget(
                                  color: vfColorPink,
                                  diameter: 204 * sizeUnit,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [vfPramBodyGoodStateWidget()],
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: new BorderRadius.circular(20 * sizeUnit),
                                child: FittedBox(
                                  child: ExtendedImage.network(GlobalData.mainPet.value.petPhotos[0].imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      SizedBox(height: 24 * sizeUnit),
                      Container(
                        width: double.infinity,
                        height: 118 * sizeUnit,
                        padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28 * sizeUnit),
                          boxShadow: vfBasicBoxShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            petInfoContainer(
                              infoTitle: '몸무게',
                              color: vfColorOrange20,
                              svgIcon: svgWeightIcon,
                              info: '${GlobalData.mainPet.value.weight.toString()}kg',
                            ),
                            SizedBox(width: 24 * sizeUnit),
                            petInfoContainer(
                                infoTitle: '성별',
                                color: vfColorPink20,
                                svgIcon: svgSexIcon,
                                info: (GlobalData.mainPet.value.sex == MALE || GlobalData.mainPet.value.sex == NEUTERING_MALE)
                                    ? '남'
                                    : (GlobalData.mainPet.value.sex == FEMALE || GlobalData.mainPet.value.sex == NEUTERING_FEMALE)
                                        ? '여'
                                        : ''),
                            SizedBox(width: 24 * sizeUnit),
                            petInfoContainer(
                              infoTitle: '나이',
                              color: vfColorSkyBlue20,
                              svgIcon: svgAgeIcon,
                              info: petAgeCheck(GlobalData.mainPet.value.birthday),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            vfGradationButton(
              text: '정보 선택',
              colorType: vfGradationColorType.Violet,
              onTap: () {
                Get.to(() => DetailPetInfoSelectingPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  // 펫 정보 컨테이너
  Container petTagItem(String text) {
    return Container(
      height: 26 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 6 * sizeUnit),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 163, 183, 0.2),
        borderRadius: BorderRadius.circular(12 * sizeUnit),
      ),
      child: Text(text, style: VfTextStyle.subTitle4()),
    );
  }

  Widget petInfoContainer({required String infoTitle, required Color color, required String svgIcon, required String info}) {
    return Column(
      children: [
        SizedBox(height: 12 * sizeUnit),
        Container(
          width: 32 * sizeUnit,
          height: 32 * sizeUnit,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(4 * sizeUnit),
            child: SvgPicture.asset(
              svgIcon,
            ),
          ),
        ),
        SizedBox(height: 24 * sizeUnit),
        Text(infoTitle, style: VfTextStyle.subTitle5().copyWith(color: vfColorDarkGray)),
        SizedBox(height: 5 * sizeUnit),
        Text(GlobalData.mainPet.value.id == nullInt ? '' : info, style: VfTextStyle.highlight3()),
      ],
    );
  }
}
