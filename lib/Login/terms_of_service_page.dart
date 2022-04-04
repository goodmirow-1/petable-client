import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/CreateAccountPage.dart';

import 'Controller/CreateAccountController.dart';
import 'iamport_certification_page.dart';


const int RADIO_TYPE_ALL = 0; // 전체
const int RADIO_TYPE_NORMAL = 1; // 기본
const int RADIO_TYPE_MARKETING = 2; // 마케팅

class TermsOfServicePage extends StatelessWidget {
  TermsOfServicePage({Key? key, required this.loginType}) : super(key: key);

  final CreateAccountController controller = Get.put(CreateAccountController());

  final int loginType;

  final String svgCheckIcon = 'assets/image/Login/checkIcon.svg'; // 체크 아이콘
  final String svgForwardArrowIcon = 'assets/image/Login/forwardArrowIcon.svg'; // 앞 화살표

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 4,
      colorType: vfGradationColorType.Pink,
      onWillPop: () {
        controller.backFunc2();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: vfAppBar(
          context,
          backFunc: () {
            unFocus(context);
            controller.backFunc2();
          },
        ),
        body: termsOfServicePage(context),
      ),
    );
  }


  Widget termsOfServicePage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                flexibleHeightBox(),
                vfAccountHeader(title: '반가워요! 마이베프!', subTitle: '아래 약관을 확인해 주세요.'), // 헤더
                Column(
                  children: [
                    SizedBox(height: 56 * sizeUnit),
                    customRadioButton(type: RADIO_TYPE_ALL, text: '약관 전체 동의', radioValue: controller.allAgree),
                    SizedBox(height: 16 * sizeUnit),
                    Divider(height: 1, thickness: 1, color: vfColorGrey),
                    SizedBox(height: 16 * sizeUnit),
                    customRadioButton(type: RADIO_TYPE_NORMAL, text: '이용약관 동의 (필수)', radioValue: controller.termsOfUseAgree),
                    SizedBox(height: 16 * sizeUnit),
                    customRadioButton(type: RADIO_TYPE_NORMAL, text: '개인정보 수집 및 이용 동의 (필수)', radioValue: controller.privacyAgree),
                    SizedBox(height: 16 * sizeUnit),
                    customRadioButton(
                      type: RADIO_TYPE_MARKETING,
                      text: '마케팅 정보 수신동의 (선택)',
                      radioValue: controller.marketingAgree,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Obx(() => vfGradationButton(
          text: '다음',
          colorType: vfGradationColorType.Violet,
          isOk: controller.activeNextForTerms.value,
          onTap: () {
            unFocus(context);
            if(loginType == LOGIN_TYPE_EMAIL){
              showVfDialog(
                  title: '본인인증 하시겠어요?',
                  description: '마이베프 가입을 위한 본인인증으로\n연결됩니다.',
                  colorType: vfGradationColorType.Violet,
                  isCancelButton: true,
                  okFunc: () {
                    if(kReleaseMode){
                      Get.to(()=>iamportCertificationPage(redirectPage: '/CreateAccountPage',));
                    } else {//디버그모드일때 본인인증 스킵
                      Get.to(()=>CreateAccountPage(loginType: LOGIN_TYPE_EMAIL));
                    }
                  });
            }else{
              controller.createSocialAccount(loginType);
            }
          },
        )),
      ],
    );
  }

  Widget flexibleHeightBox() {
    double height = 0;
    double deviceRatio = Get.height / Get.width;

    if (deviceRatio > 1.7) height += Get.height * 0.06;
    return SizedBox(height: height);
  }

  Widget customRadioButton({required int type, required String text, required radioValue, Color color = vfColorOrange}) {
    return Padding(
      padding: EdgeInsets.only(left: 24 * sizeUnit, right: 20 * sizeUnit),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (type == RADIO_TYPE_ALL)
                    controller.allAgreeFunc(); // 전체 동의 함수
                  else
                    radioValue(!radioValue.value);

                  controller.checkNextForTerms(); // 약관, 버튼 유효성 체크
                },
                child: Row(
                  children: [
                    Obx(() => Container(
                      width: 20 * sizeUnit,
                      height: 20 * sizeUnit,
                      padding: EdgeInsets.all(2 * sizeUnit),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: radioValue.value ? vfColorViolet : vfColorGrey, width: 2 * sizeUnit),
                      ),
                      child: radioValue.value ? SvgPicture.asset(svgCheckIcon, color: vfColorViolet) : null,
                    )),
                    SizedBox(width: 8 * sizeUnit),
                    Text(text, style: VfTextStyle.body1()),
                  ],
                ),
              ),
              Spacer(),
              if (type != RADIO_TYPE_ALL) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(4 * sizeUnit),
                    child: SvgPicture.asset(
                      svgForwardArrowIcon,
                      width: 20 * sizeUnit,
                      height: 20 * sizeUnit,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (type == RADIO_TYPE_MARKETING) ...[
            SizedBox(height: 4 * sizeUnit),
            Text(
              '다양한 프로모션 소식 및 할인 혜택에 관한 정보를 보내드립니다.',
              style: VfTextStyle.body3().copyWith(fontWeight: FontWeight.normal),
            ),
          ]
        ],
      ),
    );
  }

}
