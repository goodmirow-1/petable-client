import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvef_app/Network/ApiProvider.dart';

import '../Config/GlobalAsset.dart';
import '../Config/GlobalFunction.dart';

class AccountManagement extends StatelessWidget {
  final AccountManagementController controller = Get.put(AccountManagementController());

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordCheckController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '계정관리',
        ),
        body: GestureDetector(
          onTap: () => unFocus(context),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 24 * sizeUnit, 0 * sizeUnit),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '로그인 유형',
                              style: VfTextStyle.highlight3(),
                            ),
                            InkWell(
                              child: Text(
                                '회원탈퇴',
                                style: VfTextStyle.body2().copyWith(color: vfColorDarkGray),
                              ),
                              onTap: () {
                                showVfDialog(
                                  title: '탈퇴하시겠어요?',
                                  colorType: vfGradationColorType.Violet,
                                  description: '탈퇴 시, 모든 정보가 삭제됩니다.\n정말 탈퇴하시겠어요?',
                                  isCancelButton: true,
                                  okFunc: () async {
                                    LoginController.to.loading = false; // 로그인 페이지 애니메이션 안돌게

                                    var res = await ApiProvider().post('/User/Exit/Member', jsonEncode({
                                      "userID" : GlobalData.loggedInUser.value.userID
                                    }));

                                    //회원탈퇴 성공
                                    if(res == true){
                                      await GlobalData().callClear();

                                      Fluttertoast.showToast(
                                        msg: '탈퇴가 성공적으로 되었습니다.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                                        textColor: Colors.white,
                                      );

                                      Get.offAll(() => LoginPage());
                                    }
                                  }
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * sizeUnit),
                        if (GlobalData.loggedInUser.value.loginType == LOGIN_TYPE_EMAIL) ...[
                          Text('이메일', style: VfTextStyle.body1()),
                        ] else if (GlobalData.loggedInUser.value.loginType == LOGIN_TYPE_GOOGLE) ...[
                          Text('구글', style: VfTextStyle.body1()),
                        ] else if (GlobalData.loggedInUser.value.loginType == LOGIN_TYPE_KAKAOTALK) ...[
                          Text('카카오톡', style: VfTextStyle.body1()),
                        ] else if (GlobalData.loggedInUser.value.loginType == LOGIN_TYPE_APPLE) ...[
                          Text('애플', style: VfTextStyle.body1()),
                        ],
                        if (GlobalData.loggedInUser.value.loginType == 0) ...[
                          SizedBox(height: 16 * sizeUnit),
                          Text(
                            '로그인 이메일',
                            style: VfTextStyle.highlight3(),
                          ),
                          SizedBox(height: 8 * sizeUnit),
                          Text(GlobalData.loggedInUser.value.email, style: VfTextStyle.body1()),
                        ],
                        SizedBox(height: 40 * sizeUnit),
                        Text(
                          '비밀번호 변경',
                          style: VfTextStyle.highlight3(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8 * sizeUnit, top: 16 * sizeUnit),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('기존 비밀번호', style: VfTextStyle.body3()),
                              TextField(
                                controller: currentPasswordController,
                                style: VfTextStyle.subTitle2(),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: vfColorGrey, width: 2 * sizeUnit),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: vfColorViolet, width: 2 * sizeUnit),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: vfColorRed, width: 2 * sizeUnit),
                                  ),
                                  hintText: '비밀번호 입력',
                                  hintStyle: VfTextStyle.subTitle2().copyWith(color: vfColorGrey),
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(bottom: 6 * sizeUnit, top: 4 * sizeUnit),
                                ),
                                obscureText: true,
                                onChanged: (value) {
                                  controller.currentPassword(value);
                                  controller.okValid();
                                },
                              ),
                              SizedBox(height: 32 * sizeUnit),
                              Text('새로운 비밀번호', style: VfTextStyle.body3()),
                              Obx(
                                () => TextField(
                                  controller: newPasswordController,
                                  style: VfTextStyle.subTitle2(),
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorGrey, width: 2 * sizeUnit),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorViolet, width: 2 * sizeUnit),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorRed, width: 2 * sizeUnit),
                                    ),
                                    hintText: '비밀번호 입력',
                                    hintStyle: VfTextStyle.subTitle2().copyWith(color: vfColorGrey),
                                    suffixIcon: GestureDetector(
                                      onTap: () => controller.showPw(!controller.showPw.value),
                                      child: controller.showPw.value ? SvgPicture.asset(svgOpenedEyeIcon) : SvgPicture.asset(svgClosedEyeIcon),
                                    ),
                                    suffixIconConstraints: BoxConstraints(minHeight: 24, minWidth: 24),
                                    errorText: validPasswordErrorText(controller.newPassword.value).isNotEmpty ? validPasswordErrorText(controller.newPassword.value) : null,
                                    errorMaxLines: 2,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(bottom: 6 * sizeUnit, top: 4 * sizeUnit),
                                  ),
                                  obscureText: !controller.showPw.value,
                                  onChanged: (value) {
                                    controller.newPassword(value);
                                    controller.okValid();
                                  },
                                ),
                              ),
                              SizedBox(height: 16 * sizeUnit),
                              Text('새로운 비밀번호 확인', style: VfTextStyle.body3()),
                              Obx(
                                () => TextField(
                                  controller: newPasswordCheckController,
                                  style: VfTextStyle.subTitle2(),
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorGrey, width: 2 * sizeUnit),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorViolet, width: 2 * sizeUnit),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: vfColorRed, width: 2 * sizeUnit),
                                    ),
                                    hintText: '비밀번호 입력',
                                    hintStyle: VfTextStyle.subTitle2().copyWith(color: vfColorGrey),
                                    errorText: controller.newPasswordCheck.value.isNotEmpty && validPasswordConfirmErrorText(controller.newPassword.value, controller.newPasswordCheck.value).isNotEmpty
                                        ? validPasswordConfirmErrorText(controller.newPassword.value, controller.newPasswordCheck.value)
                                        : null,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(bottom: 6 * sizeUnit, top: 4 * sizeUnit),
                                  ),
                                  obscureText: !controller.showPw.value,
                                  onChanged: (value) {
                                    controller.newPasswordCheck(value);
                                    controller.okValid();
                                  },
                                ),
                              ),
                              SizedBox(height: 40 * sizeUnit),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(
                () => vfGradationButton(
                  text: '수정 완료',
                  colorType: vfGradationColorType.Violet,
                  onTap: () async{
                    vfLoadingDialog(); // 로딩 시작

                    var res = await ApiProvider().post(
                        '/User/Edit/Password',
                        jsonEncode({
                          'userID': GlobalData.loggedInUser.value.userID,
                          'password': controller.currentPassword.value,
                          'newpassword': controller.newPassword.value,
                        }));

                    Get.back(); // 로딩 끝

                    if(res != null) {
                      if(res['res'] == 'NOT_RIGHT') {
                        showVfDialog(
                            title: '비밀번호 변경에\n실패했어요.',
                            colorType: vfGradationColorType.Violet,
                            description: '기존 비밀번호를 확인하고,\n다시 시도해 주세요.'
                        );
                      } else {
                        showVfDialog(
                            title: '비밀번호가 변경되었어요.',
                            colorType: vfGradationColorType.Violet,
                            okFunc: () {
                              currentPasswordController.clear();
                              newPasswordController.clear();
                              newPasswordCheckController.clear();
                              controller.currentPassword('');
                              controller.newPassword('');
                              controller.newPasswordCheck('');
                              controller.okValid();
                              unFocus(context);
                              Get.back();
                            }
                        );
                      }
                    }

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

class AccountManagementController extends GetxController {
  RxBool showPw = false.obs;

  RxString currentPassword = ''.obs;

  RxString newPassword = ''.obs;

  RxString newPasswordCheck = ''.obs;

  RxBool isOk = false.obs;

  void okValid() {
    if (currentPassword.isNotEmpty && newPassword.isNotEmpty && newPasswordCheck.isNotEmpty && validPasswordErrorText(newPassword.value).isEmpty && validPasswordConfirmErrorText(newPassword.value, newPasswordCheck.value).isEmpty) {
      isOk(true);
    } else {
      isOk(false);
    }
  }
}
