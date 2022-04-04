import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Home/Model/advice.dart';
import 'package:myvef_app/Login/terms_of_service_page.dart';
import 'package:myvef_app/intake/model/feed.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Login/find_account_page.dart';
import 'package:myvef_app/intake/model/snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../setting/faq_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final Duration duration = Duration(milliseconds: 600);
  final Curve curve = Curves.easeInCubic;

  final String svgCheckIcon = 'assets/image/Login/checkIcon.svg';
  final String svgGoogle = 'assets/image/Login/google_logo.svg';
  final String svgKakao = 'assets/image/Login/kakao_logo.svg';
  final String svgApple = 'assets/image/Login/apple_logo.svg';
  final double logoHeight = 120 * sizeUnit; // 로고 높이

  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration(seconds: 1)).then((value) {
    //   //ios 앱 추적 권한 다이얼로그
    //   AppTrackingTransparency.requestTrackingAuthorization();
    // });

    Future.microtask(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      bool autoLoginKey = prefs.getBool('autoLoginKey') ?? false;

      if (autoLoginKey) {
        controller.email(prefs.getString('autoLoginEmail') ?? '');
        controller.password(prefs.getString('autoLoginPw') ?? '');
        controller.loginType(prefs.getInt('loginType') ?? LOGIN_TYPE_EMAIL);

        controller.loginFunc(isAutoLogin: true);
      } else {
        if (controller.loading) {
          Timer(Duration(seconds: 4), () {
            controller.loading = false;
            controller.stateUpdate();
          });
        }
      }
    });

    getAdviceData();

    // 사료, 간식, 품종 리스트 채우기
    Future.microtask(() async {
      GlobalData().clearExcelData();

      GlobalData.dogFeedList.add(Feed(feedID: 0, calorie: 3784, water: 0.12)); //기본사료
      GlobalData.catFeedList.add(Feed(feedID: 0, calorie: 3265, water: 0.12)); //기본사료

      GlobalData.dogSnackList.add(Snack(snackID: 0, calorie: 0, water: 1, category: '펫음료·밀크', brandName: '물', koreaName: '물')); //간식에 물 추가
      GlobalData.catSnackList.add(Snack(snackID: 0, calorie: 0, water: 1, category: '펫음료·밀크', brandName: '물', koreaName: '물')); //간식에 물 추가

      await Feed().getFeedData(GlobalData.dogFeedList, 'assets/text/dogFeed.tsv');
      await Feed().getFeedData(GlobalData.catFeedList, 'assets/text/catFeed.tsv');

      await Snack().getSnackData(GlobalData.dogSnackList, 'assets/text/dogSnack.tsv');
      await Snack().getSnackData(GlobalData.catSnackList, 'assets/text/catSnack.tsv');

      GlobalData.dogEatSnackList.clear();
      GlobalData.dogDrinkSnackList.clear();
      GlobalData.catEatSnackList.clear();
      GlobalData.catDrinkSnackList.clear();
      //간식 분류
      GlobalData.dogSnackList.forEach((snack) {
        if(snack.category.isEmpty){
        } else if(snack.category == '펫음료·밀크'){
          GlobalData.dogDrinkSnackList.add(snack);
        } else{
          GlobalData.dogEatSnackList.add(snack);
        }
      });
      GlobalData.catSnackList.forEach((snack) {
        if(snack.category.isEmpty){
        } else if(snack.category == '펫음료·밀크'){
          GlobalData.catDrinkSnackList.add(snack);
        } else{
          GlobalData.catEatSnackList.add(snack);
        }
      });

      GlobalData.dogKindList = await getKindData('assets/text/dogKind.tsv');
      GlobalData.catKindList = await getKindData('assets/text/catKind.tsv');

      getFAQData();//자주 묻는 질문
    });
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    devicePadding = MediaQuery.of(context).padding;
    debugPrint('device padding is $devicePadding');

    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      onWillPop: () => isEnd(),
      child: Scaffold(
        body: GestureDetector(
          onTap: () => unFocus(context),
          child: GetBuilder<LoginController>(
            builder: (_) => SingleChildScrollView(
              physics: controller.loading ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
              child: Stack(
                children: [
                  splashWidget(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: duration,
                        // curve: curve,
                        height: controller.loading ? (Get.height / 2) - logoHeight : Get.height * 0.1,
                      ),
                      SvgPicture.asset(
                        svgVfLogoAndText,
                        width: 148 * sizeUnit,
                        height: logoHeight,
                      ),
                      IgnorePointer(
                        ignoring: controller.loading,
                        child: AnimatedOpacity(
                          opacity: controller.loading ? 0 : 1,
                          curve: curve,
                          duration: duration,
                          child: Column(
                            children: [
                              SizedBox(height: 56 * sizeUnit),
                              buildTextFields(), // 텍스트 필드 영역
                              SizedBox(height: 16 * sizeUnit),
                              buildAutoLoginAndFindButtons(), // 자동로그인, 찾기 버튼
                              SizedBox(height: 48 * sizeUnit),
                              buildLoginButton(), // 로그인 버튼
                              SizedBox(height: 24 * sizeUnit),
                              buildEasyLogin(), // 간편 로그인 영역
                              SizedBox(height: 40 * sizeUnit),
                              buildAccountCreation(), // 계정 생성
                              SizedBox(height: 30 * sizeUnit),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 스플래시
  Widget splashWidget() {
    return Container(
      height: Get.height - 22 * sizeUnit,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: baseWidget(
                context,
                type: 1,
                colorType: vfGradationColorType.Red,
                child: Container(),
              ),
            ),
            if (controller.loading) ...[
              Center(
                child: Text(
                  'Copyright Ⓒ 2021 myvef. 모든 권리 보유.',
                  style: VfTextStyle.body2(),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(height: 20 * sizeUnit),
            ],
          ],
        ),
      ),
    );
  }

  // 로그인 버튼
  Padding buildLoginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
      child: Obx(() => vfGradationButton(
            text: 'Login',
            colorType: vfGradationColorType.Red,
            isOk: controller.isOk.value,
            buttonType: GRADATION_BUTTON_TYPE.round,
            onTap: () {
              controller.loginType.value = LOGIN_TYPE_EMAIL;
              controller.loginFunc();
            },
          )),
    );
  }

  // 계정 생성
  Row buildAccountCreation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('아이디가 없으신가요?', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
        SizedBox(width: 12 * sizeUnit),
        GestureDetector(
          onTap: () => Get.to(() => TermsOfServicePage(
                loginType: LOGIN_TYPE_EMAIL,
              )),
          child: highlightText(
            text: '계정 생성',
            style: VfTextStyle.subTitle4(),
            highlightColor: vfColorOrange,
            highlightSize: 48 * sizeUnit,
            highlightHeight: 4,
          ),
        )
      ],
    );
  }

  // 간편 로그인
  Column buildEasyLogin() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 1 * sizeUnit, width: 48 * sizeUnit, color: vfColorDarkGray),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
              child: Text('간편 로그인', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
            ),
            Container(height: 1 * sizeUnit, width: 48 * sizeUnit, color: vfColorDarkGray),
          ],
        ),
        SizedBox(height: 15 * sizeUnit),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            socialLoginButton(
              iconPath: svgKakao,
              backgroundColor: Color(0xFFFFE812),
              onTap: () async {
                controller.loginType(LOGIN_TYPE_KAKAOTALK);
                controller.kakaoLoginFunc();
              },
            ),
            if (Platform.isIOS) ...[
              SizedBox(width: 24 * sizeUnit),
              socialLoginButton(
                  iconPath: svgApple,
                  backgroundColor: Colors.black,
                  onTap: () {
                    controller.loginType(LOGIN_TYPE_APPLE);
                    controller.appleLoginFunc();
                  }),
            ],
            SizedBox(width: 24 * sizeUnit),
            socialLoginButton(
              iconPath: svgGoogle,
              backgroundColor: Colors.white,
              onTap: () {
                controller.loginType(LOGIN_TYPE_GOOGLE);
                controller.googleLoginFunc();
              },
            ),
          ],
        ),
      ],
    );
  }

  // 소셜 로그인 버튼
  Widget socialLoginButton({required String iconPath, required Color backgroundColor, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32 * sizeUnit,
        height: 32 * sizeUnit,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: vfBasicBoxShadow,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(iconPath),
      ),
    );
  }

  // 텍스트 필드 영역
  Widget buildTextFields() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 8 * sizeUnit),
              Text('로그인', style: VfTextStyle.subTitle4()),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => vfTextField(
                textEditingController: emailController,
                hintText: '이메일',
                keyboardType: TextInputType.emailAddress,
                errorText: controller.loginType.value == LOGIN_TYPE_EMAIL && validEmailErrorText(controller.email.value).isNotEmpty ? validEmailErrorText(controller.email.value) : null,
                onChanged: (value) {
                  controller.email.value = value;
                  controller.checkValid(); // 로그인 버튼 유효성 체크

                  if(controller.loginType.value != LOGIN_TYPE_EMAIL) controller.loginType(LOGIN_TYPE_EMAIL);
                },
              )),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => vfTextField(
                textEditingController: pwController,
                hintText: '비밀번호',
                suffixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14 * sizeUnit, vertical: 15 * sizeUnit),
                  child: GestureDetector(
                    onTap: () => controller.showPw(!controller.showPw.value),
                    child: SvgPicture.asset(
                      controller.showPw.value ? svgOpenedEyeIcon : svgClosedEyeIcon,
                    ),
                  ),
                ),
                obscureText: !controller.showPw.value,
                onChanged: (value) {
                  controller.password.value = value;
                  controller.checkValid(); // 로그인 버튼 유효성 체크
                },
              )),
        ],
      ),
    );
  }

  // 자동 로그인, 찾기 영역
  Widget buildAutoLoginAndFindButtons() {
    return Row(
      children: [
        SizedBox(width: 48 * sizeUnit),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.radioValue(!controller.radioValue.value),
          child: Row(
            children: [
              Obx(() => Container(
                    width: 20 * sizeUnit,
                    height: 20 * sizeUnit,
                    padding: EdgeInsets.all(2 * sizeUnit),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.radioValue.value ? vfColorOrange : vfColorGrey,
                        width: 2 * sizeUnit,
                      ),
                    ),
                    child: controller.radioValue.value ? SvgPicture.asset(svgCheckIcon) : null,
                  )),
              SizedBox(width: 8 * sizeUnit),
              Text('자동 로그인', style: VfTextStyle.subTitle4()),
            ],
          ),
        ),
        Spacer(),
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => FindAccountPage(emailPage: true)),
              child: Text('아이디 찾기', style: VfTextStyle.subTitle4()),
            ),
            SizedBox(width: 3 * sizeUnit),
            Container(
              width: 1 * sizeUnit,
              height: 14 * sizeUnit,
              color: vfColorGrey,
            ),
            SizedBox(width: 3 * sizeUnit),
            GestureDetector(
              onTap: () => Get.to(() => FindAccountPage(emailPage: false)),
              child: Text('비밀번호 찾기', style: VfTextStyle.subTitle4()),
            ),
          ],
        ),
        SizedBox(width: 48 * sizeUnit),
      ],
    );
  }

  Future<List<String>> getKindData(String tsvPath) async {
    var tsv = await rootBundle.loadString(tsvPath);

    List<String> kindList = tsv.split('\n');
    kindList.removeAt(0);

    for (int i = 0; i < kindList.length; i++) {
      kindList[i] = kindList[i].trim();
    }

    return kindList;
  }
}
