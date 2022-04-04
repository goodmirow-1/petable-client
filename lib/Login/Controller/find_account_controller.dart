import 'dart:convert';

import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:myvef_app/Login/find_complete_page.dart';
import 'package:myvef_app/Network/ApiProvider.dart';

class FindAccountController extends GetxController {
  static get to => Get.find<FindAccountController>();

  // 아이디, 비밀번호 찾기 변수
  RxString name = ''.obs; // 이름
  RxString phone = ''.obs; // 전화번호
  RxString email = ''.obs; // 아이디
  RxBool activeNext = false.obs; // 다음 버튼 활성화 여부

  // 찾기 완료 페이지 변수
  RxBool showPw = false.obs; // 비밀번호 보이기 여부
  RxBool activeLoginButton = false.obs; // 로그인 하기 버튼 활성화 여부
  RxBool alwaysTrue = true.obs; // 로그인 하기 버튼 활성화 여부
  RxString password = ''.obs; // 비밀번호
  RxString passwordCheck = ''.obs; // 비밀번호 확인
  String resultEmail = '';

  // 비번 찾기 위한 유저 확인
  Future<void> findPw() async{
    var res = await ApiProvider().post(
        '/User/Find/Password',
        jsonEncode({
          "email": email.value,
          "name": name.value,
          "phoneNumber": phone.value,
        }));

    if(res != null) {
      resultEmail = res['Email'];
      Get.to(() => FindCompletePage());
    } else {
      showVfDialog(
        title: '인증에 실패했어요.',
        colorType: vfGradationColorType.Blue,
        description: '입력 정보를 확인하고,\n다시 시도해 주세요.',
      );
    }
  }

  // 아이디 찾기
  Future<void> findEmail() async {
    var res = await ApiProvider().post(
        '/User/Find/ID',
        jsonEncode({
          "name": name.value,
          "phoneNumber": phone.value,
        }));

    if(res != null) {
      resultEmail = res['Email'];
      Get.to(() => FindCompletePage());
    } else {
      showVfDialog(
          title: '인증에 실패했어요.',
          colorType: vfGradationColorType.Blue,
          description: '이름과 전화번호를 확인하고,\n다시 시도해 주세요.',
        );
    }

  }

  // 비밀번호 변경
  Future<void> changePassword() async {
    var res = await ApiProvider().post(
        '/User/Modify/PasswordDontKnowID',
        jsonEncode({
          "email": resultEmail,
          "password": password.value,
        }));

    if(res != null) {
      showVfDialog(
        title: '비밀번호가 변경 되었어요.',
        colorType: vfGradationColorType.Blue,
        description: '새로운 비밀번호로 로그인해 주세요.',
        okFunc: () => Get.offAll(() => LoginPage())
      );
    }
    // Get.offAll(() => LoginPage());
  }

  // 로그인 버튼 체크 함수
  void checkCanGoToLogin() {
    if (password.isNotEmpty && passwordCheck.isNotEmpty && validPasswordErrorText(password.value).isEmpty && validPasswordConfirmErrorText(password.value, passwordCheck.value).isEmpty)
      activeLoginButton(true);
    else
      activeLoginButton(false);
  }

  // 아이디 찾기 다음 버튼 체크 함수
  void checkNextForFindEmail() {
    if (name.isNotEmpty && phone.isNotEmpty && validRealNameErrorText(name.value).isEmpty && validPhoneNumErrorText(phone.value).isEmpty)
      activeNext(true);
    else
      activeNext(false);
  }

  // 비밀번호 찾기 다음 버튼 체크 함수
  void checkNextForFindPw() {
    if (email.isNotEmpty && validEmailErrorText(email.value).isEmpty){
      activeNext(true);
    }
    else{
      activeNext(false);
    }
  }
}
