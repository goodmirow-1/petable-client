import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/AppConfig.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/global_login.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Login/Controller/CreateAccountController.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:kakao_flutter_sdk/all.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

import '../terms_of_service_page.dart';

class LoginController extends GetxController {
  static get to => Get.find<LoginController>();

  final CreateAccountController _createAccountController = Get.put(CreateAccountController());

  RxString email = ''.obs; // 이메일
  RxString password = '1'.obs; // 패스워드

  RxBool showPw = false.obs; // 패스워드 보이기 여부
  RxBool radioValue = true.obs; // 라디오 버튼
  RxBool isOk = true.obs; // 로그인 버튼

  bool loading = true; // 로딩 여부
  RxInt loginType = LOGIN_TYPE_EMAIL.obs; //로그인 type

  // 로그인
  Future<void> loginFunc({bool isAutoLogin = false}) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var versionRes = await ApiProvider().post('/Check/AppVersion', jsonEncode({
        "version" : packageInfo.version
    }));

    if(versionRes == false){
      showVfDialog(
        title: '앱이 업데이트 되었어요.',
        colorType: vfGradationColorType.Blue,
        description: '반려동물을 위해\n최신 버전을 업데이트 해주세요.',
        okFunc: () {
          StoreRedirect.redirect(
              androidAppId: "kr.co.myvef.myvef_app",
              iOSAppId: "1595514486"
          );
        }
      );
      return;
    }

    String loginUrl = kReleaseMode
        ? loginType.value != LOGIN_TYPE_EMAIL
            ? '/User/Login/Social'
            : '/User/Login'
        : '/User/DebugLogin';

    // 자동 로그인이 아닐 때 로딩
    if (!isAutoLogin) vfLoadingDialog(colorList: loadingRedColorList);

    var res = await ApiProvider().post(
        loginUrl,
        jsonEncode({
          "email": email.value,
          "password": password.value,
        }));

    if (res != null) {
      // 자동 로그인으로 넘어오지 않았을 때
      if (!isAutoLogin) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool('autoLoginKey', radioValue.value); // 자동 로그인 설정

        // 자동 로그인 체크 했다면
        if (radioValue.value) {
          prefs.setString('autoLoginEmail', email.value); // 자동 로그인 이메일
          prefs.setString('autoLoginPw', password.value); // 자동 로그인 패스워드
          prefs.setInt('loginType', loginType.value);
        }
      }

      GlobalData.loggedInUser(UserData.fromJson(res['result']));
      GlobalData.accessToken = res['AccessToken'];
      GlobalData.refreshToken = res['RefreshToken'];
      GlobalData.accessTokenExpiredAt = res['AccessTokenExpiredAt'];

      accessTokenCheck();
      globalLogin(res, isAutoLogin: isAutoLogin);
    } else {
      Get.back(); // 로딩 다이어로그 끄기

      showVfDialog(
          title: '로그인에 실패했어요.',
          colorType: vfGradationColorType.Red,
          description: '아이디와 비밀번호를 확인하고,\n다시 시도해 주세요.',
          okFunc: () async {
            if (isAutoLogin == true) {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('autoLoginKey', false); // 자동 로그인 설정

              prefs.setString('autoLoginEmail', ''); // 자동 로그인 이메일
              prefs.setString('autoLoginPw', ''); // 자동 로그인 패스워드
              prefs.setInt('loginType', 0);

              Get.offAll(() => LoginPage());
            } else {
              Get.back();
            }
          });
    }
  }

  Future<void> appleLoginFunc({bool isAutoLogin = false}) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    email.value = userCredential.user!.email!;
    var res = await ApiProvider().post(
        '/User/Login/Social',
        jsonEncode({
          "email": email.value,
          'loginType': loginType.value,
        }));

    if (res != null) {
      // 자동 로그인으로 넘어오지 않았을 때
      if (!isAutoLogin) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool('autoLoginKey', radioValue.value); // 자동 로그인 설정

        // 자동 로그인 체크 했다면
        if (radioValue.value) {
          prefs.setString('autoLoginEmail', email.value); // 자동 로그인 이메일
          prefs.setString('autoLoginPw', 'social'); // 자동 로그인 패스워드
          prefs.setInt('loginType', loginType.value);
        }
      }

      GlobalData.loggedInUser(UserData.fromJson(res['result']));
      GlobalData.accessToken = res['AccessToken'];
      GlobalData.refreshToken = res['RefreshToken'];
      GlobalData.accessTokenExpiredAt = res['AccessTokenExpiredAt'];

      accessTokenCheck();
      globalLogin(res);
    } else {
      _createAccountController.email.value = email.value;
      _createAccountController.password.value = '';
      _createAccountController.name.value = '';
      _createAccountController.phone.value = '';

      email.value = '';
      password.value = '';

      Get.to(() => TermsOfServicePage(
        loginType: LOGIN_TYPE_APPLE,
      ));
    }
  }

  Future<void> kakaoLoginFunc({bool isAutoLogin = false}) async {
    final installed = await isKakaoTalkInstalled();

    if (Platform.isIOS) {
      try {
        installed ? await UserApi.instance.loginWithKakaoTalk() : await UserApi.instance.loginWithKakaoAccount();
        debugPrint('카카오 로그인 성공');
      } catch (e) {
        print('error on login: $e');
        Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_SHORT);
        return;
      }
    } else {
      try {
        if (installed) {
          await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오 로그인 성공');
        } else {
          Fluttertoast.showToast(msg: '카카오톡이 설치되지 않았어요!', toastLength: Toast.LENGTH_SHORT);
          return;
        }
      } catch (err) {
        debugPrint(err.toString());
        if (kReleaseMode)
          Fluttertoast.showToast(msg: '카카오 로그인에 문제가 생겼어요! 다른 방법으로 로그인해주세요.\n' + err.toString(), toastLength: Toast.LENGTH_SHORT);
        else
          Fluttertoast.showToast(msg: err.toString(), toastLength: Toast.LENGTH_SHORT);
        return;
      }
    }

    User user;

    user = await UserApi.instance.me();
    print("=========================[kakao account]=================================");
    debugPrint(user.kakaoAccount.toString());
    print("=========================[kakao account]=================================");

    if (user.kakaoAccount == null) return null;

    email.value = user.kakaoAccount!.email!;
    var res = await ApiProvider().post(
        '/User/Login/Social',
        jsonEncode({
          "email": email.value,
          'loginType': loginType.value,
        }));

    if (res != null) {
      // 자동 로그인으로 넘어오지 않았을 때
      if (!isAutoLogin) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool('autoLoginKey', radioValue.value); // 자동 로그인 설정

        // 자동 로그인 체크 했다면
        if (radioValue.value) {
          prefs.setString('autoLoginEmail', email.value); // 자동 로그인 이메일
          prefs.setString('autoLoginPw', 'social'); // 자동 로그인 패스워드
          prefs.setInt('loginType', loginType.value);
        }
      }

      GlobalData.loggedInUser(UserData.fromJson(res['result']));
      GlobalData.accessToken = res['AccessToken'];
      GlobalData.refreshToken = res['RefreshToken'];
      GlobalData.accessTokenExpiredAt = res['AccessTokenExpiredAt'];

      accessTokenCheck();
      globalLogin(res);
    } else {
      _createAccountController.email.value = email.value;
      _createAccountController.password.value = '';
      _createAccountController.name.value = '';
      _createAccountController.phone.value = '';

      email.value = '';
      password.value = '';

      Get.to(() => TermsOfServicePage(loginType: loginType.value));
    }
  }

  Future<void> googleLoginFunc({bool isAutoLogin = false}) async {
    GoogleSignInAccount? _currentUser;

    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    try {
      await _googleSignIn.signIn();
      _currentUser = _googleSignIn.currentUser;
    } catch (error) {
      debugPrint(error.toString());

      Fluttertoast.showToast(msg: '구글 로그인에 문제가 생겼어요! 다른 방법으로 로그인해주세요.\n' + error.toString(), toastLength: Toast.LENGTH_SHORT);
    }

    if (_currentUser == null) return;

    email.value = _currentUser.email;

    var res = await ApiProvider().post(
        '/User/Login/Social',
        jsonEncode({
          "email": email.value,
          'loginType': loginType.value,
        }));

    if (res != null) {
      // 자동 로그인으로 넘어오지 않았을 때
      if (!isAutoLogin) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool('autoLoginKey', radioValue.value); // 자동 로그인 설정

        // 자동 로그인 체크 했다면
        if (radioValue.value) {
          prefs.setString('autoLoginEmail', email.value); // 자동 로그인 이메일
          prefs.setString('autoLoginPw', 'social'); // 자동 로그인 패스워드
          prefs.setInt('loginType', loginType.value);
        }
      }

      GlobalData.loggedInUser(UserData.fromJson(res['result']));
      GlobalData.accessToken = res['AccessToken'];
      GlobalData.refreshToken = res['RefreshToken'];
      GlobalData.accessTokenExpiredAt = res['AccessTokenExpiredAt'];
      //https://play.google.com/store/apps/details?id=kr.co.myvef.myvef_app
      accessTokenCheck();
      globalLogin(res);
    } else {
      _createAccountController.email.value = email.value;
      _createAccountController.password.value = '';
      _createAccountController.name.value = '';
      _createAccountController.phone.value = '';

      email.value = '';
      password.value = '';

      Get.to(() => TermsOfServicePage(loginType: loginType.value));
    }
  }

  // 로그인 버튼 유효성 체크
  void checkValid() {
    if (myReleaseMode) {
      if (email.value.isNotEmpty && password.value.isNotEmpty && validEmailErrorText(email.value).isEmpty)
        isOk(true);
      else
        isOk(false);
    } else {
      isOk(true);
    }
  }

  void stateUpdate() {
    update();
  }
}
