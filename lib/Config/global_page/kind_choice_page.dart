import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Data/global_data.dart';

class KindChoicePage extends StatelessWidget {
  KindChoicePage({Key? key, required this.petType}) : super(key: key);

  final int petType;

  final KindChoiceController controller = Get.put(KindChoiceController());
  final TextEditingController kindEditingController = TextEditingController();

  List<String> petKindList = []; // 받은 타입에 따른 품종 리스트
  String additionalKind = '';
  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;

      // 받은 펫 타입에 따라 리스트를 넣어줌
      controller.secondShowKind.clear();
      switch (petType) {
        case PET_TYPE_DOG:
          petKindList.addAll(GlobalData.dogKindList);
          break;
        case PET_TYPE_CAT:
          petKindList.addAll(GlobalData.catKindList);
          break;
        default:
          petKindList.addAll(GlobalData.dogKindList);
      }

      // 두번째 화면 표시 표시 리스트에 전체 품종 리스트 담아줌
      controller.secondShowKind.addAll(petKindList);

      // 검색 버튼과 not found, 검색중 관련 변수 초기화
      controller.isKindSearchButtonPressed(false);
      controller.isKindSearching(false);
    }

    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Red,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(
            context,
            title: '품종 선택',
          ),
          body: Padding(
            padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit, bottom: 16 * sizeUnit),
            child: Obx(
              () => Column(
                children: [
                  kindSearchText(),
                  if (controller.secondShowKind.isNotEmpty) ...[
                    SizedBox(
                      height: 8 * sizeUnit,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 * sizeUnit),
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          boxShadow: vfBasicBoxShadow,
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Center(child: ListTile(title: Text(controller.secondShowKind[index]))),
                              onTap: () {
                                clickAdditionalKindList(index);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit),
                              child: Container(
                                height: 1 * sizeUnit,
                                color: vfColorGrey,
                              ),
                            );
                          },
                          itemCount: controller.secondShowKind.length,
                          shrinkWrap: true,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          vfBetiBodyBadStateWidget(),
                          SizedBox(
                            height: 16 * sizeUnit,
                          ),
                          Text(
                            '검색 결과가 없어요!',
                            style: VfTextStyle.subTitle2(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget kindSearchText() {
    return vfTextField(
      textEditingController: kindEditingController,
      hintText: '품종을 입력하세요',
      borderColor: Colors.transparent,
      suffixIcon: IconButton(
        icon: (controller.isKindSearchButtonPressed.isFalse) ? SvgPicture.asset(svgMagnifyingGlassGray) : SvgPicture.asset(svgMagnifyingGlassBlack),
        onPressed: () {},
      ),
      onChanged: (value) {
        searchAdditionalKind(value);

        // 검색 버튼 눌림 여부가 실시간으로 변경되도록
        if (kindEditingController.text.isNotEmpty) {
          controller.isKindSearchButtonPressed(true);
        } else {
          controller.isKindSearchButtonPressed(false);
        }
      },
    );
  }

  // 기타 품종 리스트 눌렀을 때 실행되는 함수
  void clickAdditionalKindList(int index) {
    // 추가 품종리스트에서 추가 품종을 선택했을 때
    additionalKind = controller.secondShowKind[index];
    Get.back(result: additionalKind); // 이전 페이지로 이동
  }

  // 기타 품종 검색 처리하는 함수
  void searchAdditionalKind(String query) {
    if (kindEditingController.text.isEmpty) {
      // 검색창이 비어있으면 검색중, 검색 결과 없음 변수 초기화
      controller.isKindSearching(false);

      // 검색창이 비어있다면 기타 품종 리스트를 표시리스트에 넣음
      controller.secondShowKind.clear();
      controller.secondShowKind.addAll(petKindList);
    } else {
      // 품종 검색 중
      controller.isKindSearching(true);

      // 검색어가 있으면, 글자 바뀔 때마다 검색 리스트에 결과가 다르게 들어가야 하므로 초기화 후 검색어와 일치하는 품종 새로 넣기
      controller.listSearchKind.clear();
      controller.listSearchKind.addAll(petKindList.where((location) => location.contains(query)));

      // 검색어가 있다면 검색 해서 나온 리스트의 값들을 화면에 표시할 리스트에 이동시킴
      controller.secondShowKind.clear();
      controller.secondShowKind.addAll(controller.listSearchKind);
    }
  }
}

class KindChoiceController extends GetxController {
  RxList secondShowKind = [].obs; // 두번째 화면에 표시할 품종 리스트 (기타 선택한 뒤의 화면에 표시할 품종 리스트)
  RxList listSearchKind = [].obs; // 기타 품종 검색 리스트

  RxBool isKindSearching = false.obs;
  RxBool isKindSearchButtonPressed = false.obs;
}
