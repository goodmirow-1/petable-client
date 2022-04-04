import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Login/Controller/find_account_controller.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Network/ApiProvider.dart';

class FindCompletePage extends StatefulWidget {
  @override
  State<FindCompletePage> createState() => _FindCompletePageState();
}

class _FindCompletePageState extends State<FindCompletePage> {
  final FindAccountController controller = Get.put(FindAccountController());

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController passwordCheckController = TextEditingController();

  bool bCheckInfo = false;
  bool emailPage = false;
  String email = '';
  String emailRemain = '';

  @override
  void initState() {
    Future.microtask(() async {
      controller.name.value = Get.arguments['name'];
      controller.phone.value = Get.arguments['phone'];
      emailPage = Get.arguments['emailPage'];

      if(emailPage){
        var res = await ApiProvider().post('/User/Find/ID', jsonEncode({
          "name" : controller.name.value,
          "phoneNumber" : controller.phone.value
        }));

        if(res != null){
          controller.resultEmail = res['Email'];
          bCheckInfo = true;

          List<String> emailList = controller.resultEmail.split('@');
          email = emailList[0];
          emailRemain = emailList[1];
        }
      }else{
        var res = await ApiProvider().post('/User/Find/Password', jsonEncode({
          "email" : controller.email.value,
          "name" : controller.name.value,
          "phoneNumber" : controller.phone.value
        }));

        if(res != null){
          controller.resultEmail = res['Email'];
          if(controller.email.value != controller.resultEmail){ //입력한 아이디와 조회한 아이디가 다름
            bCheckInfo = false;
          }else{
            bCheckInfo = true;
          }
        }
      }
    }).then((value) {
      setState(() {

      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 3,
      colorType: vfGradationColorType.Blue,
      onWillPop: () {
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          body: Column(
            children: [
              emailPage ? buildEmailWidget() : buildPwWidget(),
              Obx(
                    () => vfGradationButton(
                  text: !bCheckInfo ? '다음' : '로그인 하기',
                  colorType: vfGradationColorType.Blue,
                  isOk: !bCheckInfo || emailPage ? controller.alwaysTrue.value : controller.activeLoginButton.value,
                  onTap: () {
                    if (!bCheckInfo || emailPage)
                      Get.offAll(() => LoginPage());
                    else
                      controller.changePassword();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPwWidget() {
    return
      !bCheckInfo ? buildFalseCheckInfo('입력하신 정보가 일치하지 않아요!', '정보를 정확히 입력 후, 다시 진행해 주세요.'): Expanded(
       child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('베프님!', style: VfTextStyle.subTitle2()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              highlightText(
                text: '새로운 비밀 번호',
                style: VfTextStyle.headline3().copyWith(fontWeight: FontWeight.w500),
                highlightColor: vfColorWaterBlue,
                highlightSize: emailPage ? ('새로운 비밀 번호'.length * 13.8) * sizeUnit : 174 * sizeUnit,
              ),
              Text('를 입력해 주세요!', style: VfTextStyle.subTitle2()),
            ],
          ),
          SizedBox(height: 56 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Column(
              children: [
                Obx(() => vfTextField(
                      textEditingController: passwordController,
                      label: '비밀번호',
                      hintText: '비밀번호 입력',
                      borderColor: vfColorSkyBlue,
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
                        controller.checkCanGoToLogin();
                      },
                    )),
                SizedBox(height: 8 * sizeUnit),
                Obx(() => vfTextField(
                      textEditingController: passwordCheckController,
                      hintText: '비밀번호 확인',
                      borderColor: vfColorSkyBlue,
                      obscureText: !controller.showPw.value,
                      errorText: controller.passwordCheck.value.isNotEmpty && validPasswordConfirmErrorText(controller.password.value, controller.passwordCheck.value).isNotEmpty
                          ? validPasswordConfirmErrorText(controller.password.value, controller.passwordCheck.value)
                          : null,
                      onChanged: (value) {
                        controller.passwordCheck(value);
                        controller.checkCanGoToLogin();
                      },
                    )),
              ],
            ),
          ),
          SizedBox(height: 20 * sizeUnit), // 버튼이랑 조금 떨어트리기 위해
        ],
      ),
    );
  }

  Expanded buildEmailWidget() {
    return !bCheckInfo ? buildFalseCheckInfo('아이디를 찾지 못했어요.','새로운 계정을 만들어 주세요!') : Expanded(
      child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('베프님의 아이디는', style: VfTextStyle.subTitle2()),
            SizedBox(height: 8 * sizeUnit,),
            highlightText(
              text: email,
              style: VfTextStyle.headline3().copyWith(fontWeight: FontWeight.w500),
              highlightColor: vfColorWaterBlue,
              highlightSize: emailPage ? (email.length * 14.8) * sizeUnit : 174 * sizeUnit,
            ),
            SizedBox(height: 8 * sizeUnit,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                highlightText(
                  text: '@' + emailRemain,
                  style: VfTextStyle.headline3().copyWith(fontWeight: FontWeight.w500),
                  highlightColor: vfColorWaterBlue,
                  highlightSize: emailPage ? (emailRemain.length * 15.8) * sizeUnit : 174 * sizeUnit,
                ),
                Text(' 이에요', style: VfTextStyle.subTitle2())
              ],
            ),
          ],
        )
    );
  }

  Expanded buildFalseCheckInfo(String text1, String text2){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          vfBetiBodyBadStateWidget(),
          SizedBox(height: 16 * sizeUnit,),
          Text(text1, style: VfTextStyle.subTitle2()),
          Text(text2, style: VfTextStyle.subTitle2())
        ],
      ),
    );
  }

  Column buildTextWidget({required String text1, required String text2, required String text3}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text1, style: VfTextStyle.subTitle2()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            highlightText(
              text: text2,
              style: VfTextStyle.headline3().copyWith(fontWeight: FontWeight.w500),
              highlightColor: vfColorWaterBlue,
              highlightSize: emailPage ? (text2.length * 13.8) * sizeUnit : 174 * sizeUnit,
            ),
          ],
        ),
        Text(text3, style: VfTextStyle.subTitle2())
      ],
    );
  }
}
