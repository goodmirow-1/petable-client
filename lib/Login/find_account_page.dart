import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/Controller/find_account_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Login/iamport_certification_page.dart';
import 'package:myvef_app/Network/ApiProvider.dart';

class FindAccountPage extends StatefulWidget {
  FindAccountPage({Key? key, required this.emailPage}) : super(key: key);

  final bool emailPage;

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {
  final FindAccountController controller = Get.put(FindAccountController());

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    if(widget.emailPage){
      controller.activeNext.value = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 4,
      colorType: vfGradationColorType.Blue,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      flexibleHeightBox(),
                      vfAccountHeader(title: widget.emailPage ? '아이디를 잊어버리셨네요!' : '비밀번호를 잊어버리셨네요!', subTitle: '본인확인을 위한 인증을 진행해 주세요.'),
                      SizedBox(height: 100*sizeUnit),
                      buildTextFieldArea(),
                    ],
                  ),
                ),
              ),
              Obx(
                () => vfGradationButton(
                  text: '다음',
                  colorType: vfGradationColorType.Blue,
                  isOk: controller.activeNext.value,
                  onTap: () async {

                    String emailPage = 'true';
                    if (false == widget.emailPage) {
                     emailPage = 'false';

                     var res = await ApiProvider().post('/User/IDCheck', jsonEncode({
                        "email" : controller.email.value
                      }));

                     if(res == null){
                       showVfDialog(
                         title: '아이디 검색에 실패했어요.',
                         colorType: vfGradationColorType.Blue,
                         description: '입력 정보를 확인하고,\n다시 시도해 주세요.',
                       );
                       return;
                     }
                    }

                    Get.to(()=>iamportCertificationPage(redirectPage: '/FindCompletePage?' + emailPage,));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
      child: Column(
        children: [
          if (widget.emailPage) ...[
            buildTextWidget(
              text1: '아이디를 찾기 위한',
              text2: '본인확인 인증 절차',
              text3: '를 진행해 주세요.',
            ),
          ] else ...[
            Obx(() => vfTextField(
                  textEditingController: emailController,
                  label: '아이디',
                  hintText: '이메일 입력',
                  borderColor: vfColorSkyBlue,
                  errorText: validEmailErrorText(controller.email.value).isNotEmpty ? validEmailErrorText(controller.email.value) : null,
                  onChanged: (value) {
                    controller.email(value);
                    controller.checkNextForFindPw();
                  },
                )),
          ],
          Row(children: [SizedBox(height: 20 * sizeUnit)]), // 버튼이랑 조금 떨어트리기 위해
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
              highlightSize: 192 * sizeUnit,
            ),
            Text(text3, style: VfTextStyle.subTitle2())
          ],
        )
      ],
    );
  }
}
