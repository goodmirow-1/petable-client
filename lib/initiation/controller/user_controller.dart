import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:myvef_app/community/model/community.dart';
import '../../Config/Constant.dart';
import '../../Config/GlobalFunction.dart';
import '../../Config/GlobalWidget/GlobalWidget.dart';
import '../../Data/global_data.dart';
import '../../Network/ApiProvider.dart';
import '../initiation_pet_page.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class UserController extends GetxController {
  RxString nickName = GlobalData.loggedInUser.value.nickName.obs; // 유저 닉네임
  RxString firstLocation = ''.obs; // 첫번째 지역
  RxString secondLocation = ''.obs; // 두번째 지역
  RxString location = GlobalData.loggedInUser.value.location.obs; // 전체 지역
  RxString sex = GlobalData.loggedInUser.value.sex == MALE
      ? '남'.obs
      : GlobalData.loggedInUser.value.sex == FEMALE
          ? '여'.obs
          : ''.obs; // 유저 성별
  RxString birthday = GlobalData.loggedInUser.value.birthday.obs; // 유저 생일

  RxBool isNickNameOk = false.obs; // 닉네임 입력 다음 버튼
  RxBool isLocationOk = false.obs; // 지역 설정 다음 버튼
  RxBool isSexOk = false.obs; // 유저 성별 다음 버튼
  RxBool isBirthdayOk = false.obs; // 유저 생일 다음 버튼

  RxBool isEditUserOk = true.obs; // 유저  버튼
  RxBool isRegistration = false.obs;

  RxInt barIndex = 0.obs; // 수정페이지 바 인덱스

  RxList imageList = [].obs; // 사진

  void nickNameCheckValid() {
    if (nickName.value.isNotEmpty && validNickNameErrorText(nickName.value).isEmpty)
      isNickNameOk(true);
    else
      isNickNameOk(false);
  }

  void locationCheckValid() {
    if (location.value.isNotEmpty)
      isLocationOk(true);
    else
      isLocationOk(false);
  }

  void userSexCheckValid() {
    if (sex.value.isNotEmpty)
      isSexOk(true);
    else
      isSexOk(false);
  }

  void userBirthCheckValid() {
    if (birthday.value.isNotEmpty)
      isBirthdayOk(true);
    else
      isBirthdayOk(false);
  }

  void initiationBackFunc(PageController pageController) {
    if (pageController.page == 0){
      if(isRegistration.value == false){
        Get.back();
      }else{
        Future.microtask(() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('autoLoginKey', false); // 자동 로그인 설정

          prefs.setString('autoLoginEmail', ''); // 자동 로그인 이메일
          prefs.setString('autoLoginPw', ''); // 자동 로그인 패스워드
          prefs.setInt('loginType', 0);

          Get.offAll(() => LoginPage());
        });
      }
    }else{
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void nextFunc(PageController pageController) {
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void editBackFunc() {
    showVfDialog(
        title: '수정을\n취소하시겠어요?',
        colorType: vfGradationColorType.Violet,
        isCancelButton: true,
        okFunc: () {
          Get.back();
          Get.back();
        });
  }

  void editUserCheckValid() {
    if (nickName.value.isNotEmpty && validNickNameErrorText(nickName.value).isEmpty)
      isEditUserOk(true);
    else
      isEditUserOk(false);
  }

  void editUserOkOnTap() {
    int sexNum;

    if(sex.value == '남')
      sexNum = MALE;
    else
      sexNum = FEMALE;

    GlobalData.loggedInUser.value.nickName = nickName.value;
    GlobalData.loggedInUser.value.location = location.value;
    GlobalData.loggedInUser.value.sex = sexNum;
    GlobalData.loggedInUser.value.birthday = birthday.value;

    userEdit(imageList: imageList);
  }

  // user initiation 정보 보내기
  Future<void> userInitiation() async {
    int sexNum = nullInt;//미입력
    if(sex.value.isNotEmpty){
      if (sex.value == '남')
        sexNum = MALE;
      else
        sexNum = FEMALE;
    }

    var res = await ApiProvider().post(
        '/User/Insert/NeedInfo',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
          'nickname': nickName.value,
          'location': location.value,
          'sex': sexNum == nullInt ? null : sexNum,
          'birthday': birthday.value,
        }));

    if (res != null) {
      GlobalData.loggedInUser.value.nickName = nickName.value;
      GlobalData.loggedInUser.value.location = location.value;
      GlobalData.loggedInUser.value.sex = sexNum;
      GlobalData.loggedInUser.value.birthday = birthday.value;

      Get.to(() => InitiationPetPage());
    }
  }

  // user edit 정보 보내기
  Future<void> userEdit({required List imageList}) async {
    int sexNum = nullInt;//미입력
    if(sex.value.isNotEmpty){
      if (sex.value == '남')
        sexNum = MALE;
      else
        sexNum = FEMALE;
    }

    FormData formData = FormData.fromMap({
      'userID': GlobalData.loggedInUser.value.userID,
      'nickName': nickName.value,
      'location': location.value,
      'information': '',
      'sex': sexNum == nullInt ? null : sexNum,
      'birthday': birthday.value,
      'isDeleteImage': (imageList.length >= 1) ? 0 : 1,
      'accessToken' : GlobalData.accessToken
    });

    for (int i=0; i<imageList.length; i++) {
      if (imageList[i] is File) {
        formData.files.add(MapEntry('images', MultipartFile.fromFileSync(imageList[i].path, filename: imageList[i].path.split('/').last)));
      }
    }

    try {
      Dio dio = new Dio();
      var res = await dio.post(ApiProvider().getUrl + '/User/Edit/ProfileInfo', data: formData);
      UserData resUserData = UserData.fromJson(json.decode(res.toString()));

      GlobalData.loggedInUser(resUserData);

      syncCommunityUserData(resUserData); // 커뮤니티 글에 있는 유저 정보 수정

      // 커뮤니티 댓글, 답글에 쓰이는 심플 유저 수정한걸로 바꾸기
      for(int i = 0; i < GlobalData.simpleUserList.length; i++){
        if(GlobalData.simpleUserList[i].userID == GlobalData.loggedInUser.value.userID) {
          GlobalData.simpleUserList[i] = GlobalData.loggedInUser.value;
          break;
        }
      }

      DashBoardController.to.stateUpdate();

      Fluttertoast.showToast(
        msg: '수정을 완료했습니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );

      Get.back(); // endDrawer로
      Get.back(); // dashBoard로
    } on DioError catch (e) {
      Get.back();
      Fluttertoast.showToast(
        msg: '수정을 실패했습니다. 다시 시도해주세요.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );
      throw (e.message);
    }
  }
}
