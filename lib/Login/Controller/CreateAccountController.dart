import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/initiation/controller/user_controller.dart';

class CreateAccountController extends GetxController {
  static get to => Get.find<CreateAccountController>();

  final Duration duration = Duration(milliseconds: 300);
  final Curve curve = Curves.easeIn;

  // 약관 동의 페이지 변수
  RxBool allAgree = false.obs; // 전체 동의
  RxBool termsOfUseAgree = false.obs; // 이용약관 동의
  RxBool privacyAgree = false.obs; // 개인정보 수집 및 이용 동의
  RxBool marketingAgree = false.obs; // 광고성 정보 수신동의
  RxBool activeNextForTerms = false.obs; // 다음 버튼 활성화 여부

  // 본인 인증 페이지 변수
  RxString name = ''.obs; // 이름
  RxString phone = ''.obs; // 전화번호
  RxBool activeNextForVerification = false.obs; // 다음 버튼 활성화 여부

  // 계정 생성 페이지 변수
  RxString email = ''.obs; // 아이디
  RxString password = ''.obs; // 비밀번호
  RxString passwordCheck = ''.obs; // 비밀번호 확인
  RxBool showPw = false.obs; // 비밀번호 보이기 여부
  RxBool activeCreateButton = false.obs; // 계정 생성 버튼 활성화 여부

  // 핸드폰 번호 중복 체크
  Future<void> checkPhoneFunc(PageController pageController, {loginType = LOGIN_TYPE_EMAIL}) async {
    var res = await ApiProvider().post(
        '/User/PhoneCheck',
        jsonEncode({
          "name": name.value,
          "phoneNumber": phone.value,
        }));

    if (res == null) {
      if(loginType == LOGIN_TYPE_EMAIL){
        Get.to(() => pageController.nextPage(duration: duration, curve: curve));
      }else{
        createSocialAccount(LOGIN_TYPE_GOOGLE);
      }
    } else {
        showVfDialog(
          title: '이미 가입된 번호에요.',
          colorType: vfGradationColorType.Violet,
          description: '아이디 찾기를 이용해\n계정을 확인하세요.',
        );
    }
  }

  // 계정 생성 함수
  Future<void> createAccount() async {
    // 이메일 중복 체크
    var emailCheck = await ApiProvider().post(
        '/User/IDCheck',
        jsonEncode({
          "email": email.value,
        }));

    // 이미 이메일이 있다면 리턴
    if(emailCheck != null) {
      return showVfDialog(
        title: '메일이 중복되었어요.',
        colorType: vfGradationColorType.Violet,
        description: '다른 메일을 입력해 주세요.',
      );
    }

    // 계정 생성
    var createAccount = await ApiProvider().post(
        '/User/Insert',
        jsonEncode({
          "email": email.value,
          "password": password.value,
          "phoneNumber": phone.value,
          "name": name.value,
          "marketingAgree": marketingAgree.value,
        }));

    if (createAccount != null) {
      showVfDialog(
        title: '계정 생성 완료!',
        colorType: vfGradationColorType.Violet,
        description: '자동으로 로그인됩니다.',
        okFunc: (){
          LoginController loginController = Get.find();
          loginController.loginType.value = LOGIN_TYPE_EMAIL;
          loginController.radioValue(true);//자동로그인 여부 true
          loginController.email(email.value);
          loginController.password(password.value);

          UserController userController = Get.put(UserController());
          userController.isRegistration(true);

          loginController.loginFunc();
        },
        isBarrierDismissible: false,
      );
    }
  }

  Future<void> createSocialAccount(int loginType) async {
    // 계정 생성
    var createAccount = await ApiProvider().post(
        '/User/Insert/Social',
        jsonEncode({
          "email": email.value,
          "password": password.value,
          "name": name.value,
          "phoneNumber": phone.value,
          "marketingAgree": marketingAgree.value,
          "loginType" : loginType
        }));

    if (createAccount != null) {
      showVfDialog(
        title: '계정 생성 완료!',
        colorType: vfGradationColorType.Violet,
        description: '자동으로 로그인됩니다.',
        okFunc: (){
          LoginController loginController = Get.find();
          loginController.loginType.value = loginType;
          loginController.radioValue(true);//자동로그인 여부 true
          loginController.email(email.value);
          loginController.password(password.value);

          UserController userController = Get.put(UserController());
          userController.isRegistration(true);

          loginController.loginFunc();
        },
        isBarrierDismissible: false,
      );

    }
  }

  // 페이지뷰 뒤로가기 함수
  void backFunc(PageController pageController){
    if (pageController.page == 0){
      Get.back();
    } else{
      pageController.previousPage(duration: duration, curve: curve);
    }
  }

  // terms of service page 뒤로가기 함수
  void backFunc2(){
    Get.back();
    reset();
  }

  //initialize
  void reset(){
    allAgree.value = false;
    termsOfUseAgree.value = false;
    privacyAgree.value = false;
    marketingAgree.value = false;
    activeNextForTerms.value = false;
  }

  // 계정 생성 버튼 활성화 여부
  void canCreateAccount() {
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        passwordCheck.isNotEmpty &&
        validEmailErrorText(email.value).isEmpty &&
        validPasswordErrorText(password.value).isEmpty &&
        validPasswordConfirmErrorText(password.value, passwordCheck.value).isEmpty)
      activeCreateButton(true);
    else
      activeCreateButton(false);
  }

  // 본인 인증 페이지 다음 버튼 활성화 여부
  void checkNextForVerification() {
    if (name.isNotEmpty && phone.isNotEmpty && validRealNameErrorText(name.value).isEmpty && validPhoneNumErrorText(phone.value).isEmpty)
      activeNextForVerification(true);
    else
      activeNextForVerification(false);
  }

  // 전체 동의 눌렀을 때
  void allAgreeFunc() {
    allAgree(!allAgree.value);
    termsOfUseAgree(allAgree.value);
    privacyAgree(allAgree.value);
    marketingAgree(allAgree.value);
  }

  void checkNextForTerms() {
    // 전체 버튼 활성화 여부
    if (termsOfUseAgree.value && privacyAgree.value && marketingAgree.value)
      allAgree(true);
    else
      allAgree(false);

    // 다음 버튼 활성화 여부
    if (termsOfUseAgree.value && privacyAgree.value)
      activeNextForTerms(true);
    else
      activeNextForTerms(false);
  }
}
