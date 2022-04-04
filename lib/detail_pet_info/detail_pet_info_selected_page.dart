import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:extended_image/extended_image.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/graph/graph_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DetailPetInfoSelectedPage extends StatelessWidget {
  DetailPetInfoSelectedPage(this.selectedInfoList);

  final List selectedInfoList;
  final ScreenshotController screenshotController = ScreenshotController();
  final DetailPetInfoController detailPetInfoController = Get.put(DetailPetInfoController());

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      colorType: vfGradationColorType.Pink,
      type: 0,
      child: Scaffold(
        appBar: vfAppBar(context, title: '진료정보 내보내기'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: GetBuilder<DetailPetInfoController>(builder: (_) {
                  return Screenshot(
                    controller: screenshotController,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 24 * sizeUnit),
                            if (GlobalData.mainPet.value.petPhotos.isEmpty) ...[
                              vfGradationIconWidget(iconPath: svgFootIcon, size: 88 * sizeUnit)
                            ] else ...[
                              Container(
                                width: 96 * sizeUnit,
                                height: 96 * sizeUnit,
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(50 * sizeUnit),
                                  child: FittedBox(
                                    child: ExtendedImage.network(GlobalData.mainPet.value.petPhotos[0].imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 8 * sizeUnit),
                            Text(GlobalData.mainPet.value.name, style: VfTextStyle.headline4()),
                            SizedBox(height: 32 * sizeUnit),
                            for (int i = 0; i < selectedInfoList.length; i++) ...[
                              info(selectedInfoList[i]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            vfGradationButton(
              text: '내보내기',
              colorType: vfGradationColorType.Violet,
              onTap: () {
                showVfDialog(
                  title: '파일을 내보내시겠어요?',
                  description: '파일 형식은 JPG로 저장됩니다.',
                  colorType: vfGradationColorType.Violet,
                  isCancelButton: true,
                  okFunc: () async {
                    try {
                      await screenshotController.capture(delay: const Duration(milliseconds: 10)).then(
                        (Uint8List? image) async {
                          if (image != null) {
                            await ImageGallerySaver.saveImage(
                              image,
                              name: DateTime.now().microsecondsSinceEpoch.toString(),
                            );

                            Get.back(); // 다이얼로그 끄기
                            Get.back(); // 상세정보 내보내기 페이지 끄기
                            Get.back(); // 상세정보 선택 페이지 끄기
                            Get.back(); // 상세정보 요약 페이지 끄기

                            Fluttertoast.showToast(
                              msg: '진료정보 파일을 내보냈습니다.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                              textColor: Colors.white,
                            );
                          }
                        },
                      );
                    } on Exception catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String info) {
    String sex = '';
    if (GlobalData.mainPet.value.sex == MALE || GlobalData.mainPet.value.sex == NEUTERING_MALE)
      sex = '남';
    else if (GlobalData.mainPet.value.sex == FEMALE || GlobalData.mainPet.value.sex == NEUTERING_FEMALE) sex = '여';

    String neutering = '';
    if (GlobalData.mainPet.value.sex == MALE || GlobalData.mainPet.value.sex == FEMALE)
      neutering = 'X';
    else if (GlobalData.mainPet.value.sex == NEUTERING_MALE || GlobalData.mainPet.value.sex == NEUTERING_FEMALE) neutering = 'O';

    String feed = '';
    if (GlobalData.mainPet.value.foodID != nullInt) {
      if (GlobalData.mainPet.value.foodID == -1) {
        feed = GlobalData.mainPet.value.feed!.brandName + ' ' + GlobalData.mainPet.value.feed!.koreaName;
      } else {
        feed = GlobalData.mainPet.value.feed!.koreaName;
      }
    }

    switch (info) {
      case '품종':
        return infoContainer('품종', GlobalData.mainPet.value.kind);
      case '성별':
        return infoContainer('성별', sex);
      case '중성화':
        return infoContainer('중성화', neutering);
      case '생년월일':
        return infoContainer('생년월일', GlobalData.mainPet.value.birthday);
      case '음수량':
        return Column(
          children: [
            SizedBox(
              height: Get.height * 0.7,
              child: GraphWidget(detailInfo: '음수량'),
            ),
            SizedBox(height: 24 * sizeUnit),
          ],
        );
      case '섭취량':
        return Column(
          children: [
            SizedBox(
              height: Get.height * 0.7,
              child: GraphWidget(detailInfo: '섭취량'),
            ),
            SizedBox(height: 24 * sizeUnit),
          ],
        );
      case '사료정보':
        return infoContainer('사료정보', feed);
      case '나이':
        return infoContainer('나이', petAgeCheck(GlobalData.mainPet.value.birthday));
      case '몸무게':
        return infoContainer('몸무게', GlobalData.mainPet.value.weight.toString() + 'kg');
      case '알러지':
        return infoContainer('알러지', GlobalData.mainPet.value.allergy);
      case '질병':
        return infoContainer('질병', GlobalData.mainPet.value.disease);
      case '급여조절':
        String weightManage = '';
        switch (GlobalData.mainPet.value.weightManage) {
          case 0:
            weightManage = '정상';
            break;
          case 1:
            weightManage = '활동량 적음';
            break;
          case 2:
            weightManage = '비만';
            break;
        }
        return infoContainer('급여조절', weightManage);
      case '임신 • 수유':
        String pregnantLactation = '';
        switch (GlobalData.mainPet.value.pregnantLactation) {
          case 0:
            pregnantLactation = '해당 없음';
            break;
          case 1:
            pregnantLactation = '임신';
            break;
          case 2:
            pregnantLactation = '수유';
            break;
        }
        return infoContainer('임신 • 수유', pregnantLactation);
      default:
        return Container();
    }
  }

  Widget infoContainer(String title, String info) {
    return Padding(
      padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit, bottom: 24 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8 * sizeUnit),
            child: Text(title, style: VfTextStyle.subTitle4()),
          ),
          SizedBox(height: 8 * sizeUnit),
          vfWideContainer(
            child: Text(info, style: VfTextStyle.subTitle2()),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}

class DetailPetInfoController extends GetxController {
  static get to => Get.find<DetailPetInfoController>();

  void stateUpdate() {
    update();
  }
}
