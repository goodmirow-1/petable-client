import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/intake/model/feed.dart';
import 'package:myvef_app/Data/global_data.dart';
import '../Constant.dart';
import '../GlobalAsset.dart';
import '../GlobalFunction.dart';
import 'package:flutter_svg/svg.dart';

class FeedChoicePage extends StatelessWidget {
  FeedChoicePage({required this.petType, this.isSnack = false, this.isDrink = false, this.colorType = vfGradationColorType.Red});

  final int petType;
  final bool isSnack;
  final bool isDrink;
  final vfGradationColorType colorType;

  final FeedChoiceController controller = Get.put(FeedChoiceController());
  final TextEditingController feedEditingController = TextEditingController();

  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;

      setShowList(); // 화면 표시 리스트에 사료 리스트 담아줌

      // 검색 버튼, 검색중 관련 변수 초기화
      controller.isSearchButtonPressed(false);
      controller.isSearching(false);
    }

    return baseWidget(
      context,
      type: 2,
      colorType: colorType,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(
            context,
            title: isSnack ? '간식 검색' : '사료 검색',
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(16 * sizeUnit, 0 * sizeUnit, 16 * sizeUnit, 0 * sizeUnit),
            child: Obx(
              () => Column(
                children: [
                  feedSearchText(),
                  SizedBox(
                    height: 8 * sizeUnit,
                  ),
                  if (controller.showFeedList.isNotEmpty) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < controller.showFeedList.length; i++) ...[
                              SizedBox(
                                height: 8 * sizeUnit,
                              ),
                              GestureDetector(
                                child: feedInfoWidget(
                                  brandName: controller.showFeedList[i].brandName,
                                  description: isSnack
                                      ? controller.showFeedList[i].koreaName == '물'
                                          ? ''
                                          : controller.showFeedList[i].koreaName
                                      : controller.showFeedList[i].englishName + '\n' + controller.showFeedList[i].koreaName,
                                ),
                                onTap: () {
                                  if (isSnack) {
                                    Get.back(result: [
                                      controller.showFeedList[i].snackID,
                                      controller.showFeedList[i].koreaName,
                                      controller.showFeedList[i].weightPerSnack,
                                    ]);
                                  } else {
                                    Get.back(result: [controller.showFeedList[i].feedID, controller.showFeedList[i].koreaName]);
                                  }
                                },
                              ),
                            ],
                            if (controller.isSearching.isTrue) ...[
                              SizedBox(height: 24 * sizeUnit),
                              selfInputButton(),
                            ],
                            SizedBox(height: 16 * sizeUnit)
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          vfBetiBodyBadStateWidget(),
                          SizedBox(height: 16 * sizeUnit),
                          Text(
                            '검색 결과가 없어요!',
                            style: VfTextStyle.subTitle2(),
                          ),
                          SizedBox(height: 24 * sizeUnit),
                          selfInputButton(),
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

  // 사료, 간식 정보
  Container feedInfoWidget({required String brandName, required String description}) {
    return Container(
      width: double.infinity,
      height: 74 * sizeUnit,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * sizeUnit),
        color: Color.fromRGBO(255, 255, 255, 0.8),
        boxShadow: vfBasicBoxShadow,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 13 * sizeUnit, left: 16 * sizeUnit, right: 16 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brandName,
              style: VfTextStyle.subTitle4(),
            ),
            SizedBox(height: 8 * sizeUnit),
            Container(
              width: 295 * sizeUnit,
              child: Text(
                description,
                style: VfTextStyle.body3(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget feedSearchText() {
    return vfTextField(
      textEditingController: feedEditingController,
      hintText: '사료명을 입력하세요',
      borderColor: Colors.transparent,
      suffixIcon: IconButton(
        // 아이콘을 눌렀는지 여부에 따라 아이콘 색상 구별
        icon: (controller.isSearchButtonPressed.isFalse) ? SvgPicture.asset(svgMagnifyingGlassGray) : SvgPicture.asset(svgMagnifyingGlassBlack),
        onPressed: () {},
      ),
      onChanged: (value) {
        searchFeed(value);

        // 검색 버튼 눌림 여부가 실시간으로 변경되도록
        if (feedEditingController.text.isNotEmpty) {
          controller.isSearchButtonPressed(true);
        } else {
          controller.isSearchButtonPressed(false);
        }
      },
    );
  }

  Widget selfInputButton() {
    if (isSnack) return SizedBox.shrink();

    return SizedBox(
        width: 216 * sizeUnit,
        child: vfGradationButton(
          text: '직접 입력',
          colorType: vfGradationColorType.Red,
          buttonType: GRADATION_BUTTON_TYPE.round,
          onTap: () {
            controller.inputFeed.value = Feed(feedID: -1, perFat: 0.0, perProtein: 0.0);
            controller.okValid();
            Get.to(() => FeedAdditionalPage());
          },
        ));
  }

  // 사료 검색 처리하는 함수
  void searchFeed(String query) {
    if (feedEditingController.text.isEmpty) {
      // 검색창이 비어있으면 검색중, 검색 결과 없음 변수 초기화
      controller.isSearching(false);

      setShowList(); // 검색창이 비어있다면 사료리스트를 화면 표시리스트에 넣음

    } else {
      // 사료 검색 중
      controller.isSearching(true);

      // 검색어가 있으면, 글자 바뀔 때마다 검색 리스트에 결과가 다르게 들어가야 하므로 초기화 후 검색어와 일치하는 사료 새로 넣기
      controller.searchList.clear();

      if (isSnack) {
        if (petType == PET_TYPE_DOG) {
          if (isDrink) {
            GlobalData.dogDrinkSnackList.forEach((element) {
              if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query)) {
                controller.searchList.add(element);
              }
            });
          } else {
            GlobalData.dogEatSnackList.forEach((element) {
              if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query)) {
                controller.searchList.add(element);
              }
            });
          }
        } else if (petType == PET_TYPE_CAT) {
          if (isDrink) {
            GlobalData.catDrinkSnackList.forEach((element) {
              if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query)) {
                controller.searchList.add(element);
              }
            });
          } else {
            GlobalData.catEatSnackList.forEach((element) {
              if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query)) {
                controller.searchList.add(element);
              }
            });
          }
        }
      } else {
        if (petType == PET_TYPE_DOG) {
          GlobalData.dogFeedList.forEach((element) {
            if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query) || element.englishName.toLowerCase().contains(query.toLowerCase())) {
              controller.searchList.add(element);
            }
          });
        } else if (petType == PET_TYPE_CAT) {
          GlobalData.catFeedList.forEach((element) {
            if (element.brandName.toLowerCase().contains(query.toLowerCase()) || element.koreaName.contains(query) || element.englishName.toLowerCase().contains(query.toLowerCase())) {
              controller.searchList.add(element);
            }
          });
        }
      }

      // 검색어가 있다면 검색 해서 나온 리스트의 값들을 화면에 표시할 리스트에 이동시킴
      controller.showFeedList.clear();
      controller.showFeedList.addAll(controller.searchList);
    }
  }

  // 화면에 보이는 리스트 세팅
  void setShowList() {
    controller.showFeedList.clear();

    if (isSnack) {
      if (petType == PET_TYPE_DOG) {
        if (isDrink) {
          controller.showFeedList.addAll(GlobalData.dogDrinkSnackList);
        } else {
          controller.showFeedList.addAll(GlobalData.dogEatSnackList);
        }
      } else if (petType == PET_TYPE_CAT) {
        if (isDrink) {
          controller.showFeedList.addAll(GlobalData.catDrinkSnackList);
        } else {
          controller.showFeedList.addAll(GlobalData.catEatSnackList);
        }
      }
    } else {
      if (petType == PET_TYPE_DOG) {
        controller.showFeedList.addAll(GlobalData.dogFeedList);
      } else if (petType == PET_TYPE_CAT) {
        controller.showFeedList.addAll(GlobalData.catFeedList);
      }

      controller.showFeedList.removeAt(0); // 기본 사료 지워줌
    }
  }
}

class FeedAdditionalPage extends StatelessWidget {
  final FeedChoiceController controller = Get.put(FeedChoiceController());

  final TextEditingController feedBrandController = TextEditingController();
  final TextEditingController feedNameController = TextEditingController();
  final TextEditingController feedCalorieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Red,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(
            context,
            title: '선택정보 등록',
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(40 * sizeUnit, 24 * sizeUnit, 40 * sizeUnit, 0 * sizeUnit),
                      child: Column(
                        children: [
                          Text(
                            '브랜드명*',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: vfTextField(
                              textEditingController: feedBrandController,
                              hintText: '사료 브랜드 입력',
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.inputFeed.value.brandName = value;
                                controller.okValid();
                              },
                            ),
                          ),
                          Text(
                            '사료명*',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: vfTextField(
                              textEditingController: feedNameController,
                              hintText: '사료명 입력',
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.inputFeed.value.koreaName = value;
                                controller.okValid();
                              },
                            ),
                          ),
                          Text(
                            '조지방(%)*',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputFat.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '조지방 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputFat.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputFat,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.perFat = controller.inputFat.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '조단백질(%)*',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputProtein.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '조단백질 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputProtein.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputProtein,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.perProtein = controller.inputProtein.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '조회분(%)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputCrudeAsh.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '조회분 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputCrudeAsh.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputCrudeAsh,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.crudeAsh = controller.inputCrudeAsh.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '조섬유(%)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputCrudeFiber.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '조섬유 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputCrudeFiber.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputCrudeFiber,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.crudeFiber = controller.inputCrudeFiber.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '수분(%)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputWater.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '수분 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputWater.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputWater,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.water = controller.inputWater.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '칼슘(%)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputCalcium.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '칼슘 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputCalcium.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputCalcium,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.calcium = controller.inputCalcium.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '인(%)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: GestureDetector(
                              child: Obx(
                                () => vfWideContainer(
                                  child: (controller.inputPhosphorus.value == 0.0)
                                      ? Center(
                                          child: Text(
                                            '인 비율 입력',
                                            style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            controller.inputPhosphorus.value.toString(),
                                            style: VfTextStyle.body1(),
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () {
                                unFocus(context);
                                vfNumberPicker(
                                  context: context,
                                  value: controller.inputPhosphorus,
                                  max: 100,
                                  decimalPointBelow: 2,
                                ).then((value) {
                                  controller.inputFeed.value.phosphorus = controller.inputPhosphorus.value / 100;
                                  controller.okValid();
                                });
                              },
                            ),
                          ),
                          Text(
                            '칼로리(kcal/kg)',
                            style: VfTextStyle.highlight3(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8 * sizeUnit, bottom: 24 * sizeUnit),
                            child: vfTextField(
                                textEditingController: feedCalorieController,
                                hintText: '1kg당 칼로리 입력',
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
                                onChanged: (value) {
                                  if (value != '.') {
                                    if (value.isNotEmpty) {
                                      controller.inputFeed.value.calorie = double.parse(value).round();
                                    } else {
                                      controller.inputFeed.value.calorie = 0;
                                    }
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => vfGradationButton(
                  text: '다음',
                  colorType: vfGradationColorType.Red,
                  onTap: () {
                    //전체칼로리 계산 및 수분 조회분 채움
                    controller.inputFeed.value.setCalorie();

                    controller.customFeed.value = controller.inputFeed.value;
                    Get.back(); // 사료 선택 페이지로
                    Get.back(result: [-1, controller.customFeed.value.brandName, controller.customFeed.value.koreaName]); // 수정 페이지로
                  },
                  isOk: controller.isOk.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedChoiceController extends GetxController {
  RxList searchList = [].obs; // 검색 사료 리스트

  RxList showFeedList = [].obs; // 화면에 표시할 사료 리스트

  RxBool isSearching = false.obs; // 사료 검색중인지
  RxBool isSearchButtonPressed = false.obs; // 검색 버튼 눌렀는지

  Rx<Feed> customFeed = (GlobalData.mainPet.value.feed != null && GlobalData.mainPet.value.foodID == -1) ? GlobalData.mainPet.value.feed!.obs : Feed(feedID: -1).obs; // 입력해서 커스텀한 사료. 저장하고 불러올 때 씀
  Rx<Feed> inputFeed = Feed(feedID: -1, perFat: 0.0, perProtein: 0.0).obs; // 입력할 때만 쓰는 변수

  RxDouble inputFat = 0.0.obs;
  RxDouble inputProtein = 0.0.obs;
  RxDouble inputCrudeAsh = 0.0.obs;
  RxDouble inputCrudeFiber = 0.0.obs;
  RxDouble inputWater = 0.0.obs;
  RxDouble inputCalcium = 0.0.obs;
  RxDouble inputPhosphorus = 0.0.obs;

  RxBool isOk = false.obs;

  void okValid() {
    if (inputFeed.value.brandName.isNotEmpty && inputFeed.value.koreaName.isNotEmpty && inputFeed.value.perFat != 0.0 && inputFeed.value.perProtein != 0.0) {
      isOk(true);
    } else {
      isOk(false);
    }
  }

  double percentToRatio(String value) {
    double percent = double.parse(value) / 100;
    return percent;
  }
}
