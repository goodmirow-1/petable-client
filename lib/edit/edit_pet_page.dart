import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/animated_tap_bar.dart';
import 'package:myvef_app/Config/GlobalWidget/add_picture.dart';
import 'package:myvef_app/Config/global_page/feeds_choice_page.dart';
import 'package:myvef_app/Config/global_page/kind_choice_page.dart';
import 'package:myvef_app/Data/global_data.dart';
import '../initiation/controller/pet_controller.dart';

class EditPetPage extends StatefulWidget {
  final pageIndex;

  const EditPetPage({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final PetController controller = Get.put(PetController());
  late PageController pageController;
  final TextEditingController petNameEditingController = TextEditingController(text: GlobalData.mainPet.value.name);
  final TextEditingController diseaseEditingController = TextEditingController(text: GlobalData.mainPet.value.disease);
  final TextEditingController allergyEditingController = TextEditingController(text: GlobalData.mainPet.value.allergy);

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.pageIndex);
    controller.barIndex(widget.pageIndex);

    controller.petImageList.clear();
    controller.petImageList.addAll(GlobalData.mainPet.value.petPhotos);
  }

  @override
  void dispose() {
    petNameEditingController.dispose();
    diseaseEditingController.dispose();
    allergyEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      onWillPop: () => controller.editBackFunc(context) as Future<bool>,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: vfAppBar(context, title: '반려동물 정보 수정', backFunc: () => controller.editBackFunc(context)),
          body: Column(
            children: [
              Obx(
                () => AnimatedTapBar(
                  barIndex: controller.barIndex.value,
                  listTabItemTitle: ['필수정보', '추가정보', '사진'],
                  pageController: pageController,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: [
                    essentialInfo(context),
                    additionalInfo(),
                    image(),
                  ],
                  onPageChanged: (index) {
                    controller.barIndex(index);
                  },
                ),
              ),
              editOkButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget essentialInfo(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24 * sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => vfTextField(
                        textEditingController: petNameEditingController,
                        label: '이름*',
                        borderColor: vfColorPink,
                        hintText: '이름 입력',
                        errorText: validPetNameErrorText(controller.name.value).isNotEmpty ? validPetNameErrorText(controller.name.value) : null,
                        onChanged: (value) {
                          controller.name(value);
                          controller.editPetCheckValid();
                        },
                      ),
                    ),
                    title('생년월일*'),
                    GestureDetector(
                      child: vfWideContainer(
                        child: Obx(() => Text(controller.birthday.value, style: VfTextStyle.body1())),
                        alignment: Alignment.centerLeft,
                      ),
                      onTap: () {
                        unFocus(context);
                        vfDatePicker(context: context, color: Colors.orange).then((value) {
                          controller.birthday(value);
                        });
                      },
                    ),
                    title('품종*'),
                    GestureDetector(
                      child: vfWideContainer(
                        child: Obx(() => Text('${controller.kind.value}', style: VfTextStyle.body1())),
                        alignment: Alignment.centerLeft,
                      ),
                      onTap: () {
                        unFocus(context);
                        Get.to(() => KindChoicePage(
                                  petType: (controller.type.value == '강아지') ? PET_TYPE_DOG : PET_TYPE_CAT,
                                ))!
                            .then((value) {
                          if (value != null) controller.kind(value);
                        });
                      },
                    ),
                    title('몸무게*'),
                    GestureDetector(
                        child: Obx(
                          () => vfWideContainer(
                            child: (controller.weight.value == 0.0)
                                ? Text(
                                    '몸무게 선택',
                                    style: VfTextStyle.body1().copyWith(color: vfColorDarkGray),
                                  )
                                : Text('${controller.weight} kg', style: VfTextStyle.body1()),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        onTap: () {
                          unFocus(context);
                          vfWeightPicker(
                            context: context,
                            firstWeight: controller.firstWeight,
                            secondWeight: controller.secondWeight,
                            weight: controller.weight,
                            validCheckFunc: controller.editPetCheckValid,
                          );
                        }),
                    title('성별*'),
                    Obx(
                      () => vfFitRadioButtonWrap(
                        stringList: ['남', '여'],
                        value: controller.sex.value,
                        spacing: 24 * sizeUnit,
                        fillColor: vfColorPink,
                        width: 40 * sizeUnit,
                        textAlign: TextAlign.center,
                        onTap: (value) {
                          unFocus(context);
                          controller.sex(value);
                        },
                      ),
                    ),
                    title('중성화*'),
                    Obx(
                      () => vfFitRadioButtonWrap(
                        stringList: ['O', 'X'],
                        value: controller.neutering.value,
                        spacing: 24 * sizeUnit,
                        fillColor: vfColorPink,
                        width: 40 * sizeUnit,
                        textAlign: TextAlign.center,
                        onTap: (value) {
                          unFocus(context);
                          controller.neutering(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget additionalInfo() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24 * sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => vfTextField(
                        textEditingController: diseaseEditingController,
                        label: '질병',
                        hintText: '질병 입력',
                        borderColor: vfColorPink,
                        minLines: 1,
                        maxLines: 5,
                        errorText: validPetAdditionalInfoErrorText(controller.disease.value).isNotEmpty ? validPetAdditionalInfoErrorText(controller.disease.value) : null,
                        suffixIcon: diseaseEditingController.text.isEmpty ? const SizedBox.shrink() : IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              controller.disease('');
                              diseaseEditingController.clear();
                            });
                          },
                          iconSize: 24 * sizeUnit,
                          icon: Icon(
                            Icons.cancel,
                            color: vfColorGrey,
                          ),
                        ),
                        onChanged: (value) {
                          controller.disease(value);
                          controller.editPetCheckValid();
                        },
                      ),
                    ),
                    SizedBox(height: 24 * sizeUnit),
                    Obx(
                      () => vfTextField(
                        textEditingController: allergyEditingController,
                        label: '알러지',
                        hintText: '알러지 입력',
                        borderColor: vfColorPink,
                        minLines: 1,
                        maxLines: 5,
                        errorText: validPetAdditionalInfoErrorText(controller.allergy.value).isNotEmpty ? validPetAdditionalInfoErrorText(controller.allergy.value) : null,
                        suffixIcon: allergyEditingController.text.isEmpty ? const SizedBox.shrink() : IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              controller.allergy('');
                              allergyEditingController.clear();
                            });
                          },
                          iconSize: 24 * sizeUnit,
                          icon: Icon(
                            Icons.cancel,
                            color: vfColorGrey,
                          ),
                        ),
                        onChanged: (value) {
                          controller.allergy(value);
                          controller.editPetCheckValid();
                        },
                      ),
                    ),
                    title('사료'),
                    GestureDetector(
                      child: Obx(
                        () => controller.feedKoreaName.isNotEmpty
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(16 * sizeUnit, 14 * sizeUnit, 16 * sizeUnit, 14 * sizeUnit),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                  borderRadius: BorderRadius.circular(24 * sizeUnit),
                                  boxShadow: vfBasicBoxShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${controller.feedBrandName.value}${controller.feedKoreaName.value}',
                                      style: VfTextStyle.subTitle2(),
                                      textAlign: TextAlign.left,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // 사료 초기화
                                        controller.foodID(0);
                                        controller.feedBrandName('');
                                        controller.feedKoreaName('');
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: vfColorGrey,
                                        size: 24 * sizeUnit,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : vfWideContainer(
                                child: Text(
                                  '사료 선택',
                                  style: VfTextStyle.subTitle2().copyWith(color: vfColorDarkGray),
                                ),
                                alignment: Alignment.centerLeft,
                              ),
                      ),
                      onTap: () {
                        unFocus(context);
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
                    title('급여조절'),
                    Obx(
                      () => vfFitRadioButtonWrap(
                        stringList: ['정상', '활동량 적음', '비만'],
                        value: controller.obesityState.value,
                        spacing: 24 * sizeUnit,
                        fillColor: vfColorPink,
                        textAlign: TextAlign.center,
                        onTap: (value) {
                          unFocus(context);
                          controller.obesityState(value);
                        },
                      ),
                    ),
                    title('임신 • 수유 상태'),
                    Obx(
                      () => vfFitRadioButtonWrap(
                        stringList: ['임신', '수유'],
                        value: controller.pregnantState.value,
                        spacing: 24 * sizeUnit,
                        fillColor: vfColorPink,
                        textAlign: TextAlign.center,
                        onTap: (value) {
                          unFocus(context);
                          if (controller.pregnantState.value == value) {
                            controller.pregnantState('');
                          } else {
                            controller.pregnantState(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget image() {
    return Column(
      children: [
        AddPicture(
          imageList: controller.petImageList,
          isModify: true,
          color: ADD_PICTURE_VIOLET,
        ),
      ],
    );
  }

  Widget editOkButton() {
    return Obx(
      () => vfGradationButton(
        text: '수정 완료',
        colorType: vfGradationColorType.Violet,
        onTap: () {
          controller.petInsertOrModify(isCreate: 0, imageList: controller.petImageList, isAdd: false);
        },
        isOk: controller.isEditPetOk.value,
      ),
    );
  }

  Widget title(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Column(
        children: [
          SizedBox(
            height: 24 * sizeUnit,
          ),
          Text(
            title,
            style: VfTextStyle.subTitle4(),
          ),
          SizedBox(height: 8 * sizeUnit),
        ],
      ),
    );
  }
}
