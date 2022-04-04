import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/add_picture.dart';
import 'package:myvef_app/Config/GlobalWidget/animated_tap_bar.dart';
import 'package:myvef_app/Config/global_page/location_choice_page.dart';
import 'package:myvef_app/Data/global_data.dart';
import '../initiation/controller/user_controller.dart';

class EditUserPage extends StatelessWidget {
  final UserController controller = Get.put(UserController());
  final PageController pageController = PageController();
  final TextEditingController nickNameEditingController = TextEditingController(text: GlobalData.loggedInUser.value.nickName);

  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      isInit = false;

      if (GlobalData.loggedInUser.value.profileURL.isNotEmpty) {
        controller.imageList.clear();
        controller.imageList.add(GlobalData.loggedInUser.value.profileURL);
      }
    }

    return Obx(
      () => baseWidget(
        context,
        type: 2,
        colorType: vfGradationColorType.Pink,
        child: GestureDetector(
          onTap: () => unFocus(context),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: vfAppBar(context, title: '내 정보 수정', backFunc: () => controller.editBackFunc()),
            body: Column(
              children: [
                AnimatedTapBar(
                  barIndex: controller.barIndex.value,
                  listTabItemTitle: ['내 정보', '사진'],
                  pageController: pageController,
                ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: [
                      essentialInfo(context),
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
      ),
    );
  }

  Widget essentialInfo(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 24 * sizeUnit, right: 24 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24 * sizeUnit,
                  ),
                  vfTextField(
                    textEditingController: nickNameEditingController,
                    label: '닉네임*',
                    borderColor: vfColorPink,
                    hintText: '닉네임 입력',
                    errorText: validNickNameErrorText(controller.nickName.value).isNotEmpty ? validNickNameErrorText(controller.nickName.value) : null,
                    onChanged: (value) {
                      controller.nickName(value);
                      controller.editUserCheckValid();
                    },
                  ),
                  title('주소*'),
                  GestureDetector(
                    child: vfWideContainer(
                      child: Text(controller.location.value, style: VfTextStyle.body1()),
                      alignment: Alignment.centerLeft,
                    ),
                    onTap: () {
                      unFocus(context);
                      Get.to(() => LocationChoicePage())!.then((value) {
                        if (value != null) {
                          controller.location(value);
                        }
                      });
                    },
                  ),
                  title('생년월일'),
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
                  title('성별'),
                  Padding(
                    padding: EdgeInsets.only(left: 16 * sizeUnit),
                    child: vfFitRadioButtonWrap(
                      stringList: ['남', '여'],
                      value: controller.sex.value,
                      spacing: 24 * sizeUnit,
                      fillColor: vfColorPink,
                      onTap: (value) {
                        unFocus(context);
                        controller.sex(value);
                      },
                    ),
                  ),
                ],
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
          imageList: controller.imageList,
          isModify: true,
          isUser: true,
          color: ADD_PICTURE_VIOLET,
        ),
      ],
    );
  }

  Widget title(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            title,
            style: VfTextStyle.subTitle4(),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget editOkButton() {
    return Obx(
      () => vfGradationButton(
        text: '수정 완료',
        colorType: vfGradationColorType.Violet,
        onTap: () {
          controller.editUserOkOnTap();
        },
        isOk: controller.isEditUserOk.value,
      ),
    );
  }
}
