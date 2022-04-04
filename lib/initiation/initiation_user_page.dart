import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/global_page/location_choice_page.dart';
import 'controller/user_controller.dart';

class InitiationUserPage extends StatelessWidget {
  final UserController controller = Get.put(UserController());
  final TextEditingController userEditingController = TextEditingController();
  final PageController pageController = PageController();
  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    if(isInit) {
      isInit = false;
      controller.sex('');
      controller.birthday('');
    }

    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          nickname(context),
          location(context),
          sex(context),
          birthday(context),
        ],
      ),
      onWillPop: () => controller.initiationBackFunc(pageController) as Future<bool>,
    );
  }

  Widget nickname(BuildContext context) {
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
                    '베프님의\n닉네임은 뭐예요?',
                    style: VfTextStyle.headline3(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                    child: Obx(
                      () => vfTextField(
                        textEditingController: userEditingController,
                        hintText: '닉네임 입력',
                        borderColor: vfColorViolet,
                        textAlign: TextAlign.center,
                        errorText: validNickNameErrorText(controller.nickName.value).isNotEmpty ? validNickNameErrorText(controller.nickName.value) : null,
                        onChanged: (value) {
                          controller.nickName.value = value;
                          controller.nickNameCheckValid(); // 다음 버튼 유효성 체크
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
                colorType: vfGradationColorType.Violet,
                onTap: () {
                  unFocus(context);
                  controller.nextFunc(pageController);
                },
                isOk: controller.isNickNameOk.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget location(BuildContext context) {
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
                  '사는 곳은 어디예요?',
                  style: VfTextStyle.headline3(),
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
                  child: GestureDetector(
                    child: vfWideContainer(
                      child: Obx(
                        () => controller.location.isNotEmpty
                            ? Text(
                                controller.location.value,
                                style: VfTextStyle.body1(),
                              )
                            : Text(
                                '지역 선택',
                                style: VfTextStyle.subTitle2().copyWith(color: vfColorDarkGray),
                              ),
                      ),
                    ),
                    onTap: () {
                      Get.to(() => LocationChoicePage())!.then((value) {
                        if (value != null) {
                          controller.location(value);
                          controller.locationCheckValid();
                        }
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
              colorType: vfGradationColorType.Violet,
              onTap: () {
                unFocus(context);
                controller.nextFunc(pageController);
              },
              isOk: controller.isLocationOk.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget sex(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '선택정보 등록',
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
                        fillColor: vfColorPink,
                        onTap: (value) {
                          controller.sex(value);
                          controller.userSexCheckValid();
                        },
                        spacing: 24 * sizeUnit),
                  ),
                ],
              ),
            ),
            vfGradationButton(
              text: '다음',
              colorType: vfGradationColorType.Violet,
              onTap: () {
                unFocus(context);
                controller.nextFunc(pageController);
              },
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
          title: '선택정보 등록',
          backFunc: () => controller.initiationBackFunc(pageController),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '생년월일은요?',
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
                        vfDatePicker(context: context, color: Colors.purple).then((value) {
                          controller.birthday(value);
                          controller.userBirthCheckValid();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            vfGradationButton(
              text: '다음',
              colorType: vfGradationColorType.Violet,
              onTap: () {
                controller.userInitiation();
              },
            ),
          ],
        ),
      ),
    );
  }
}
