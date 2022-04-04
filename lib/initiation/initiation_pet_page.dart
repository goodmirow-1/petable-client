import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/global_page/feeds_choice_page.dart';
import 'package:myvef_app/Config/global_page/kind_choice_page.dart';
import 'package:myvef_app/Config/GlobalWidget/add_picture.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'package:get/get.dart';

import 'controller/pet_controller.dart';

class InitiationPetPage extends StatelessWidget {
  bool isAdd; // add pet 페이지에서 추가하는 것인지 확인

  InitiationPetPage({this.isAdd = false});

  final PetController controller = Get.put(PetController());

  final TextEditingController petEditingController = TextEditingController();
  final PageController pageController = PageController();

  // 20개 고정 기본 품종 리스트
  final List<String> basicDogKindList = [
    '말티즈',
    '비숑',
    '포메라니안',
    '푸들',
    '치와와',
    '미니핀',
    '요크셔테리어',
    '진돗개',
    '코카스파니엘',
    '프렌치불독',
    '시츄',
    '리트리버',
    '시바',
    '보더콜리',
    '웰시코기',
    '스피츠',
    '이탈리안그레이하운드',
    '닥스훈트',
    '비글',
    '사랑스런 믹스',
    '기타',
  ];
  final List<String> basicCatKindList = [
    '터키쉬앙고라',
    '아비니시안',
    '뱅갈',
    '스핑크스',
    '아메리칸숏헤어',
    '아메리칸컬',
    '러시안블루',
    '먼치킨',
    '노르웨이숲',
    '브리티쉬숏헤어',
    '코리안숏헤어',
    '랙돌',
    '스코티쉬폴드',
    '스코티쉬스트레이트',
    '샴',
    '메인쿤',
    '페르시안',
    '셀커크렉스',
    '하이랜드폴드',
    '사랑스런 믹스',
    '기타',
  ];

  // 첫번째 화면에 표시할 기본 품종 리스트
  List<String> basicKindList = [];

  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;

      // controller 값 초기화
      controller.type('');
      controller.name('');
      controller.sex('');
      controller.neutering('');
      controller.birthday('');
      controller.kind('');
      controller.weight(0.0);
      controller.feedKoreaName('');
    }

    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Red,
      child: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          start(context),
          type(context),
          petName(context),
          weight(context),
          sex(context),
          neutering(context),
          birthday(context),
          kind(context),
          feed(context),
          picture(context),
        ],
      ),
      onWillPop: () => controller.initiationBackFunc(pageController) as Future<bool>,
    );
  }

  Widget start(BuildContext context) {
    return Scaffold(
      appBar: vfAppBar(context, title: '필수정보 등록', backFunc: () {
        controller.initiationBackFunc(pageController);
      }),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '반려동물\n등록 페이지로 넘어 가시겠어요?',
                  style: VfTextStyle.headline3(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          vfGradationButton(
            text: '다음',
            colorType: vfGradationColorType.Red,
            onTap: () {
              unFocus(context);
              controller.nextFunc(pageController);
            },
          ),
        ],
      ),
    );
  }

  Widget type(BuildContext context) {
    return Scaffold(
      appBar: vfAppBar(context, title: '필수정보 등록', backFunc: () {
        controller.initiationBackFunc(pageController);
      }),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '나의 반려동물은?',
                  style: VfTextStyle.headline3(),
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                  child: Obx(
                    () => vfWideRadioButtonWrap(
                      stringList: (this.isAdd == false) ? ['강아지', '고양이', '예비 마이베프'] : ['강아지', '고양이'],
                      value: controller.type.value,
                      onTap: (value) {
                        controller.type(value);
                        controller.typeCheckValid();

                        // showKind에 품종 20개와 기타 넣어주기
                        if (controller.type.value == '강아지') {
                          basicKindList = basicDogKindList;
                        } else if (controller.type.value == '고양이') {
                          basicKindList = basicCatKindList;
                        }
                      },
                      margin: EdgeInsets.only(bottom: 16 * sizeUnit),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => vfGradationButton(
              text: '다음',
              colorType: vfGradationColorType.Red,
              onTap: () {
                unFocus(context);
                if (controller.type.value == '예비 마이베프') {
                  Get.offAll(() => MainPage());
                } else {
                  controller.nextFunc(pageController);
                }
              },
              isOk: controller.isTypeOk.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget petName(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '반려동물의 이름은 뭐예요?',
                    style: VfTextStyle.headline3(),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                    child: Obx(
                      () => vfTextField(
                        textEditingController: petEditingController,
                        hintText: '이름 입력',
                        borderColor: vfColorOrange,
                        textAlign: TextAlign.center,
                        errorText: validPetNameErrorText(controller.name.value).isNotEmpty ? validPetNameErrorText(controller.name.value) : null,
                        onChanged: (value) {
                          controller.name.value = value;
                          controller.petNameCheckValid(); // 다음 버튼 유효성 체크
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  unFocus(context);
                  controller.nextFunc(pageController);
                },
                isOk: controller.isNameOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget weight(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '몸무게는 몇 kg이에요?',
                    style: VfTextStyle.headline3(),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                    child: GestureDetector(
                      child: Obx(
                        () => vfWideContainer(
                          child: (controller.firstWeight.value == 0 && controller.secondWeight.value == 0)
                              ? Text(
                                  '몸무게 선택',
                                  style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                )
                              : Text(
                                  '${controller.firstWeight.value}.${controller.secondWeight.value}Kg',
                                  style: VfTextStyle.body1(),
                                ),
                        ),
                      ),
                      onTap: () {
                        vfWeightPicker(
                          context: context,
                          firstWeight: controller.firstWeight,
                          secondWeight: controller.secondWeight,
                          weight: controller.weight,
                          validCheckFunc: controller.petWeightCheckValid,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  controller.nextFunc(pageController);
                },
                isOk: controller.isWeightOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sex(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '성별은 뭐예요?',
                    style: VfTextStyle.headline3(),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Obx(
                    () => vfFitRadioButtonWrap(
                      stringList: ['남', '여'],
                      value: controller.sex.value,
                      onTap: (value) {
                        controller.sex(value);
                        controller.petSexCheckValid();
                      },
                      spacing: 24 * sizeUnit,
                      width: 40 * sizeUnit,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  unFocus(context);
                  controller.nextFunc(pageController);
                },
                isOk: controller.isSexOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget neutering(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '중성화 했나요?',
                    style: VfTextStyle.headline3(),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Obx(
                    () => vfFitRadioButtonWrap(
                      stringList: ['O', 'X'],
                      value: controller.neutering.value,
                      onTap: (value) {
                        controller.neutering(value);
                        controller.petNeuteringCheckValid();
                      },
                      spacing: 24 * sizeUnit,
                      width: 40 * sizeUnit,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  unFocus(context);
                  controller.nextFunc(pageController);
                },
                isOk: controller.isNeuteringOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget birthday(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '언제 태어났어요?',
                    style: VfTextStyle.headline3(),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                    child: GestureDetector(
                      child: Obx(
                        () => vfWideContainer(
                          child: (controller.birthday.isEmpty)
                              ? Text(
                                  'YYYY.MM.DD',
                                  style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                )
                              : Text(
                                  controller.birthday.value,
                                  style: VfTextStyle.body1(),
                                ),
                        ),
                      ),
                      onTap: () {
                        unFocus(context);
                        vfDatePicker(context: context, color: Colors.orange).then((value) {
                          controller.birthday(value);
                          controller.petBirthCheckValid();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  controller.nextFunc(pageController);
                },
                isOk: controller.isBirthdayOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget kind(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '필수정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '품종은요?',
                        style: VfTextStyle.headline3(),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Center(
                        child: Obx(
                          () => vfFitRadioButtonWrap(
                            alignment: WrapAlignment.center,
                            stringList: basicKindList,
                            value: controller.kind.value,
                            onTap: (value) {
                              // 리스트의 마지막 버튼을 눌렀을 때
                              if (basicKindList.indexOf(value) == basicKindList.length - 1) {
                                // 기타 품종 선택하는 페이지로 이동
                                Get.to(() => KindChoicePage(
                                          petType: (controller.type.value == '강아지') ? PET_TYPE_DOG : PET_TYPE_CAT,
                                        ))!
                                    .then((value) {
                                  if (value != null) {
                                    // 첫번째 기본 품종 표시 리스트의 마지막에 기타 대신 선택된 기타 품종으로 대체
                                    if (!basicKindList.contains(value))
                                      basicKindList[basicKindList.length - 1] = value;
                                    else
                                      basicKindList[basicKindList.length - 1] = '기타';
                                    controller.kind(value); // 선택된 품종 값 변경
                                    controller.kindCheckValid(); // 버튼 유효성 검사
                                  }
                                });
                              } else {
                                controller.kind(value); // 선택한 품종 값을 value로 바꿔주고
                                basicKindList[basicKindList.length - 1] = '기타';
                                controller.kindCheckValid(); // 버튼 유효성 검사
                              }
                            },
                            spacing: 8 * sizeUnit,
                            runSpacing: 16 * sizeUnit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '다음',
                colorType: vfGradationColorType.Red,
                onTap: () {
                  controller.nextFunc(pageController);
                },
                isOk: controller.isKindOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget feed(BuildContext context) {
    return Scaffold(
      appBar: vfAppBar(
        context,
        title: '필수정보 등록',
        backFunc: () => controller.initiationBackFunc(pageController),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '사료는 뭐예요?',
                  style: VfTextStyle.headline3(),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '사료 정보는 권장 섭취량에 영향을 줘요!',
                  style: VfTextStyle.body2().copyWith(color: vfColorDarkGray),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                  child: GestureDetector(
                    child: Obx(
                      () => controller.feedKoreaName.isNotEmpty
                          ? SizedBox(
                              width: 280 * sizeUnit,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(16 * sizeUnit, 14 * sizeUnit, 16 * sizeUnit, 14 * sizeUnit),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                  borderRadius: BorderRadius.circular(24 * sizeUnit),
                                  boxShadow: vfBasicBoxShadow,
                                ),
                                child: Text('${controller.feedBrandName.value}${controller.feedKoreaName.value}', style: VfTextStyle.body1(), textAlign: TextAlign.center),
                              ),
                            )
                          : vfWideContainer(
                              child: Text(
                                '사료 검색',
                                style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                              ),
                            ),
                    ),
                    onTap: () {
                      Get.to(() => FeedChoicePage(
                                petType: (controller.type.value == '강아지') ? PET_TYPE_DOG : PET_TYPE_CAT,
                              ))!
                          .then((value) {
                        if (value != null) {
                          controller.foodID(value[0]);

                          if (value.length == 2) {
                            // 사료 선택한 경우는 한글 이름만 필요
                            controller.feedBrandName('');
                            controller.feedKoreaName(value[1]);
                          } else {
                            // 사료 직접 입력한 경우는 브랜드 이름과 한글 이름 필요
                            controller.feedBrandName(value[1] + ' ');
                            controller.feedKoreaName(value[2]);
                          }
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          vfGradationButton(
            text: '다음',
            colorType: vfGradationColorType.Red,
            onTap: () {
              if (controller.feedKoreaName.isEmpty) {
                controller.foodID(nullInt);

                showVfDialog(
                  title: '그냥 넘어가시겠어요?',
                  colorType: vfGradationColorType.Red,
                  description: '사료 정보를 입력하지 않을 경우\n정확한 정보를 얻을 수 없어요.',
                  isCancelButton: true,
                  okFunc: () {
                    controller.foodID(0);
                    Get.back();
                    controller.nextFunc(pageController);
                  },
                );
              } else {
                controller.nextFunc(pageController);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget picture(BuildContext context) {
    return Scaffold(
      appBar: vfAppBar(
        context,
        title: '사진 등록',
        backFunc: () => controller.initiationBackFunc(pageController),
      ),
      body: Column(
        children: [
          AddPicture(
            imageList: controller.petImageList,
            isModify: false,
            color: ADD_PICTURE_RED,
          ),
          vfGradationButton(
            text: '완료',
            colorType: vfGradationColorType.Red,
            onTap: () {
              controller.petInsertOrModify(isCreate: 1, imageList: controller.petImageList, isAdd: this.isAdd);
            },
          ),
        ],
      ),
    );
  }
}
