import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/Controller/CreateAccountController.dart';

import 'LoginPage.dart';

class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({required this.loginType});

  final int loginType;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final CreateAccountController controller = Get.put(CreateAccountController());

  final PageController pageController = PageController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController passwordCheckController = TextEditingController();

  bool bCheckPhoneNumber = false;

  @override
  void initState() {
    if(!kReleaseMode){
      //디버그모드일때 이름, 폰번호 세팅
      controller.name.value = '디버그생성계정';
      controller.phone.value = '01023456789';
      bCheckPhoneNumber = false;
    } else {
      controller.name.value = Get.arguments['name'];
      controller.phone.value = Get.arguments['phone'];
      bCheckPhoneNumber = Get.arguments['bCheckPhoneNumber'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 4,
      colorType: vfGradationColorType.Pink,
      onWillPop: () {
        controller.backFunc(pageController);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: vfAppBar(
          context,
          backFunc: () {
            unFocus(context);
            controller.backFunc(pageController);
          },
        ),
        body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            if(bCheckPhoneNumber == false) ... [
              identityVerificationPage(context), // 본인 인증 페이지
            ] else ... [
              alreadyHavePhoneNumberPage(context)
            ],
            createAccountPage(context), // 계정 생성 페이지
          ],
        ),
      ),
    );
  }

  Widget createAccountPage(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  flexibleHeightBox(),
                  vfAccountHeader(title: '마이베프를 시작해 봐요!', subTitle: '기본 사항을 입력해 주세요.'), // 헤더
                  SizedBox(height: 56 * sizeUnit),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                    child: Column(
                      children: [
                        Obx(() => vfTextField(
                              textEditingController: emailController,
                              label: '아이디',
                              hintText: '이메일 입력',
                              borderColor: vfColorViolet,
                              errorText: validEmailErrorText(controller.email.value).isNotEmpty ? validEmailErrorText(controller.email.value) : null,
                              onChanged: (value) {
                                controller.email(value);
                                controller.canCreateAccount();
                              },
                            )),
                        SizedBox(height: 24 * sizeUnit),
                        Obx(() => vfTextField(
                              textEditingController: passwordController,
                              label: '비밀번호',
                              hintText: '비밀번호 입력',
                              borderColor: vfColorViolet,
                              obscureText: !controller.showPw.value,
                              suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14 * sizeUnit, vertical: 15 * sizeUnit),
                                child: GestureDetector(
                                  onTap: () => controller.showPw(!controller.showPw.value),
                                  child: SvgPicture.asset(
                                    controller.showPw.value ? 'assets/image/Login/openedEyeIcon.svg' : 'assets/image/Login/closedEyeIcon.svg',
                                  ),
                                ),
                              ),
                              errorText: validPasswordErrorText(controller.password.value).isNotEmpty ? validPasswordErrorText(controller.password.value) : null,
                              onChanged: (value) {
                                controller.password(value);
                                controller.canCreateAccount();
                              },
                            )),
                        SizedBox(height: 8 * sizeUnit),
                        Obx(() => vfTextField(
                              textEditingController: passwordCheckController,
                              hintText: '비밀번호 확인',
                              borderColor: vfColorViolet,
                              obscureText: !controller.showPw.value,
                              errorText: controller.passwordCheck.value.isNotEmpty && validPasswordConfirmErrorText(controller.password.value, controller.passwordCheck.value).isNotEmpty
                                  ? validPasswordConfirmErrorText(controller.password.value, controller.passwordCheck.value)
                                  : null,
                              onChanged: (value) {
                                controller.passwordCheck(value);
                                controller.canCreateAccount();
                              },
                            )),
                        SizedBox(height: 20 * sizeUnit), // 버튼이랑 조금 떨어트리기 위해
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => vfGradationButton(
                text: '계정 생성',
                colorType: vfGradationColorType.Violet,
                isOk: controller.activeCreateButton.value,
                onTap: () {
                  unFocus(context);
                  controller.createAccount();
                },
              )),
        ],
      ),
    );
  }

  Widget identityVerificationPage(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  flexibleHeightBox(),
                  vfAccountHeader(title: '마이베프와 함께해요!', subTitle: '본인인증이 완료되었어요.'), // 헤더
                  SizedBox(height: 60 * sizeUnit),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                    child: Column(
                      children: [
                        Obx(() => authResultBox(title: '이름', body: controller.name.value)),
                        Row(children: [SizedBox(height: 40 * sizeUnit)]),
                        Obx(() => authResultBox(title: '전화번호', body: controller.phone.value)),
                        SizedBox(height: 20 * sizeUnit), // 버튼이랑 조금 떨어트리기 위해
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          vfGradationButton(
            text: '다음',
            colorType: vfGradationColorType.Violet,
            onTap: () async {
              unFocus(context);
              pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
            },
          ),
        ],
      ),
    );
  }

  Widget alreadyHavePhoneNumberPage(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  flexibleHeightBox(),
                  vfAccountHeader(title: '마이베프와 함께해요!', subTitle: '이미 계정이 있어요'), // 헤더
                  SizedBox(height: 60 * sizeUnit),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                    child: Column(
                      children: [
                        vfBetiBodyBadStateWidget(),
                        SizedBox(height: 16 * sizeUnit,),
                        Text("로그인 페이지에서", style: VfTextStyle.subTitle2()),
                        Text("아이디 찾기 혹은 비밀번호 찾기를 해주세요.", style: VfTextStyle.subTitle2()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          vfGradationButton(
            text: '다음',
            colorType: vfGradationColorType.Violet,
            onTap: () async {
              unFocus(context);
              Get.offAll(() => LoginPage());
            },
          ),
        ],
      ),
    );
  }

  Widget flexibleHeightBox() {
    double height = 0;
    double deviceRatio = Get.height / Get.width;

    if (deviceRatio > 1.7) height += Get.height * 0.06;
    return SizedBox(height: height);
  }

  Widget authResultBox({required String title, required String body}) {
    return Column(
      children: [
        Text(title, style: VfTextStyle.subTitle2()),
        SizedBox(height: 16 * sizeUnit),
        Text(body, style: VfTextStyle.highlight2()),
      ],
    );
  }
}
