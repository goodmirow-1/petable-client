import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/twinkle_light_breath_widget.dart';
import 'package:myvef_app/Config/GlobalWidget/twinkle_light_widget2.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: vfAppBar(context, title: '매뉴얼'),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: SingleChildScrollView(
            child: Column(
              children: [
                whenRegisterDevice(), // 기기 등록 시
                whenAdjustingScale(), // 저울 영점 조절 시
                errorInUse(), // 사용 중 오류 시
                howToResetDevice(), // 기기 초기화 방법
                SizedBox(height: 32 * sizeUnit),
              ],
            ),
          ), // 기기 등록 시
        ),
      ),
    );
  }

  // 기기 등록 시
  Column whenRegisterDevice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24 * sizeUnit),
        Text('기기 등록 시', style: VfTextStyle.headline4()),
        SizedBox(height: 16 * sizeUnit),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
          ),
          child: Column(
            children: [
              headerRow(),
              SizedBox(height: 8 * sizeUnit),
              Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: vfColorGrey),
              SizedBox(height: 16 * sizeUnit),
              customRow(
                text01: '불빛이 계속 켜져\n있음',
                text02: '전원 ON',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '서서히 밝아 졌다\n서서히 줄어듬',
                text02: '앱과 wifi 연결\n대기중',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLightBreath(
                        duration: 1000,
                        top: 65 * sizeUnit,
                        left: 55 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '2번 깜박이고 1초 쉼',
                text02: '건전지 부족 wifi\n연결 진입 실패',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [200, 200, 200, 1000],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '0.2초 간격으로 계속\n깜박임',
                text02: 'wifi 연결 시도',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [200, 200],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '약 1초마다 짧게\n번쩍 거림',
                text02: 'wifi 연결 성공 및\n기기 등록 완료',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [50, 800],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '3번 깜박이고 1초 쉼',
                text02: 'wifi 연결 실패 시',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [200, 200, 200, 200, 200, 1000],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 저울 영점 조절 시
  Column whenAdjustingScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32 * sizeUnit),
        Text('저울 영점 조절 시', style: VfTextStyle.headline4()),
        SizedBox(height: 16 * sizeUnit),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
          ),
          child: Column(
            children: [
              headerRow(),
              SizedBox(height: 8 * sizeUnit),
              Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: vfColorGrey),
              SizedBox(height: 16 * sizeUnit),
              customRow(
                text01: '매우빠르게 깜빡임',
                text02: '서버 통신 및\n업데이트 중',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [50, 50],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '0.5초 마다\n깜빡임',
                text02: '저울 초기화 대기 중',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [500, 500],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '불빛이 계속 켜져\n있음',
                text02: '그릇무게 측정\n대기 중',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
              customRow(
                text01: '3번 깜박이고 1초 쉼',
                text02: 'wifi 연결 실패 시',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [200, 200, 200, 200, 200, 1000],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 사용 중 오류 시
  Column errorInUse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32 * sizeUnit),
        Text('사용 중 오류 시', style: VfTextStyle.headline4()),
        SizedBox(height: 16 * sizeUnit),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
          ),
          child: Column(
            children: [
              headerRow(),
              SizedBox(height: 8 * sizeUnit),
              Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: vfColorGrey),
              SizedBox(height: 16 * sizeUnit),
              customRow(
                text01: '10초 간격으로 깜박\n거림',
                text02: 'wifi 연결 불량',
                widget: Container(
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                  child: Stack(
                    children: [
                      Image.asset(
                        svgBowlBottom,
                        width: 244 * sizeUnit,
                        height: 244 * sizeUnit,
                      ),
                      TwinkleLight2(
                        onOffTime: [10000, 10000],
                        top: 63 * sizeUnit,
                        left: 54 * sizeUnit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row headerRow() {
    return Row(
      children: [
        subject(width: 102 * sizeUnit, text: 'LED'),
        SizedBox(width: 12 * sizeUnit),
        subject(width: 100 * sizeUnit, text: '상태'),
        SizedBox(width: 12 * sizeUnit),
        subject(width: 70 * sizeUnit, text: 'LED 확인', alignment: Alignment.center),
      ],
    );
  }

  // 기기 초기화 방법
  Column howToResetDevice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32 * sizeUnit),
        Text('기기 초기화 방법', style: VfTextStyle.headline4()),
        SizedBox(height: 16 * sizeUnit),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
          ),
          child: Row(
            children: [
              Text(
                '설정버튼을 5초간 꾹 눌러주세요.\n불빛이 들어오고 손을 떼면 깜박거리며\n초기화가 진행됩니다.',
                style: VfTextStyle.body2(),
              ),
              Spacer(),
              checkButton(
                onTap: () => showVfDialog(
                  title: '',
                  colorType: vfGradationColorType.Red,
                  middleWidget: Container(
                    width: 244 * sizeUnit,
                    height: 244 * sizeUnit,
                    child: Stack(
                      children: [
                        Image.asset(
                          svgBowlBottomWithButton,
                          width: 244 * sizeUnit,
                          height: 244 * sizeUnit,
                        ),
                        TwinkleLight2(
                          onOffTime: [0,5000,1000,200,200,200,200,200,200,200,200,200,10000],
                          top: 63 * sizeUnit,
                          left: 54 * sizeUnit,
                        ),
                      ],
                    ),
                  ),
                  description: '설정버튼을 5초간 꾹 눌러주세요.\n불빛이 들어오고 손을 떼면 깜박거리며\n초기화가 진행됩니다.\n\n초기화가 완료되면,\n불빛이 켜진 상태를 유지합니다.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget customRow({required String text01, required String text02, required Widget widget}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * sizeUnit),
      child: Row(
        children: [
          SizedBox(
            width: 102 * sizeUnit,
            child: Text(
              text01,
              style: VfTextStyle.body2(),
            ),
          ),
          SizedBox(width: 12 * sizeUnit),
          SizedBox(
            width: 100 * sizeUnit,
            child: Text(
              text02,
              style: VfTextStyle.body2(),
            ),
          ),
          SizedBox(width: 12 * sizeUnit),
          checkButton(
            onTap: () => showVfDialog(
              title: '',
              middleWidget: widget,
              colorType: vfGradationColorType.Red,
              description: text02,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector checkButton({required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70 * sizeUnit,
        height: 24 * sizeUnit,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: vfColorOrange,
          borderRadius: BorderRadius.circular(12 * sizeUnit),
        ),
        child: Text(
          '확인하기',
          style: VfTextStyle.subTitle4().copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget subject({required String text, required double width, Alignment? alignment}) {
    return Container(
      alignment: alignment ?? Alignment.centerLeft,
      width: width,
      child: Text(
        text,
        style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
      ),
    );
  }
}
