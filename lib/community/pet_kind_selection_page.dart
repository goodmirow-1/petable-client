import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/global_page/kind_choice_page.dart';
import 'package:get/get.dart';

class PetKindSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RxString petKindValue = ''.obs; // 선택된 품종
    int petType = PET_TYPE_ECT; // 펫 타입

    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(context, title: '품종 추가'),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '필터에 추가할\n반려동물을 선택해 주세요.',
                    style: VfTextStyle.headline4(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
                      child: Obx(
                        () => vfWideRadioButtonWrap(
                          stringList: ['강아지', '고양이'],
                          value: petKindValue.value,
                          fillColor: vfColorPink,
                          margin: EdgeInsets.only(bottom: 16 * sizeUnit),
                          onTap: (value) {
                            petKindValue(value);
                            switch (petKindValue.value) {
                              case '강아지':
                                petType = PET_TYPE_DOG;
                                break;
                              case '고양이':
                                petType = PET_TYPE_CAT;
                                break;
                              default:
                                petType = PET_TYPE_ECT;
                            }
                          },
                        ),
                      )),
                ],
              ),
            ),
            Obx(() => vfGradationButton(
                  text: '다음',
                  colorType: vfGradationColorType.Violet,
                  isOk: petKindValue.value.isNotEmpty,
                  onTap: () => Get.to(() => KindChoicePage(petType: petType))!.then((value) {
                    if (value != null) {
                      Get.back(result: value);
                    }
                  }),
                )),
          ],
        ),
      ),
    );
  }
}
