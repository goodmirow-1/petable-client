import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Config/Painter/background_widget.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import '../GlobalFunction.dart';

double sizeUnit = 1;
EdgeInsets devicePadding = EdgeInsets.zero; // 기기 패딩

enum vfGradationColorType { Red, Blue, Violet, Pink } // 그라데이션 컬러 타입

class VfTextStyle {
  static TextStyle headline1() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 48 * sizeUnit,
      height: 58 / 48,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle headline2() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 32 * sizeUnit,
      height: 38 / 32,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle headline3() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 24 * sizeUnit,
      height: 30 / 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle headline4() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 20 * sizeUnit,
      height: 24 / 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle subTitle1() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 20 * sizeUnit,
      height: 24 / 20,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle subTitle2() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 16 * sizeUnit,
      height: 20 / 16,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle subTitle3() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 14 * sizeUnit,
      height: 18 / 14,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle subTitle4() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 12 * sizeUnit,
      height: 14 / 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle subTitle5() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 10 * sizeUnit,
      height: 12 / 10,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle body1() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 16 * sizeUnit,
      height: 20 / 16,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle body2() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 12 * sizeUnit,
      height: 14 / 12,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle body3() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 10 * sizeUnit,
      height: 12 / 10,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle highlight1() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 36 * sizeUnit,
      height: 44 / 36,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle highlight2() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 24 * sizeUnit,
      height: 30 / 24,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle highlight3() {
    return TextStyle(
      color: vfColorBlack,
      fontSize: 16 * sizeUnit,
      height: 20 / 16,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle bWriteDate() {
    return TextStyle(
      color: vfColorDarkGray,
      fontSize: 10 * sizeUnit,
      height: 1.2,
      fontWeight: FontWeight.normal,
    );
  }
}

Widget baseWidget(
  BuildContext context, {
  required Widget child,
  required int type, //type 1 대각선 붙은거, 2 대각선 떨어진거, 3 수평 붙은거, 0 없음
  required vfGradationColorType colorType,
  Future<bool> Function()? onWillPop,
  double blur = 30,
}) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: WillPopScope(
      onWillPop: onWillPop,
      child: Container(
        color: Colors.white,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
          child: Stack(
            children: [
              type == 0 ? SizedBox.shrink() : BackgroundWidget(type: type, colorType: colorType, blur: blur),
              if (Get.currentRoute == '/MainPage' && devicePadding.bottom != 0) ...[
                SafeArea(bottom: false, child: child),
              ] else ...[
                SafeArea(child: child),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// 텍스트 필드
Widget vfTextField({
  required TextEditingController textEditingController,
  FocusNode? focusNode,
  bool obscureText = false,
  bool autoFocus = false,
  int? maxLength,
  Function(String)? onChanged,
  Function(String)? onSubmitted,
  String? label,
  String? hintText,
  String? errorText,
  TextInputType? keyboardType,
  Widget? suffixIcon,
  Color borderColor = vfColorOrange,
  TextAlign textAlign = TextAlign.left,
  int? maxLines = 1,
  int? minLines = 1,
  TextStyle? textStyle,
  TextStyle? hintStyle,
  EdgeInsetsGeometry? contentPadding,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[
        Padding(
          padding: EdgeInsets.only(left: 8 * sizeUnit),
          child: Text(label, style: VfTextStyle.subTitle4()),
        ),
        SizedBox(height: 8 * sizeUnit),
      ],
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 14 * sizeUnit),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28 * sizeUnit),
              boxShadow: vfBasicBoxShadow,
              border: Border.all(width: 2 * sizeUnit, color: Colors.transparent),
            ),
            child: Text(
              textEditingController.text,
              style: textStyle != null ? textStyle.copyWith(color: Colors.transparent) : VfTextStyle.subTitle2().copyWith(color: Colors.transparent),
              maxLines: maxLines,
            ),
          ),
          TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: textStyle ?? VfTextStyle.subTitle2(),
            keyboardType: keyboardType,
            obscureText: obscureText,
            autofocus: autoFocus,
            maxLength: maxLength,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textAlign: textAlign,
            maxLines: maxLines,
            minLines: minLines,
            textInputAction: maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
            buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color.fromRGBO(255, 255, 255, 0.8),
              filled: true,
              hintText: hintText,
              hintStyle: hintStyle ?? VfTextStyle.subTitle2().copyWith(color: vfColorDarkGray),
              errorText: errorText,
              errorMaxLines: 2,
              isDense: true,
              contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 14 * sizeUnit),
              suffixIcon: suffixIcon,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: vfColorRed, width: 2 * sizeUnit),
                borderRadius: BorderRadius.circular(28 * sizeUnit),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: vfColorRed, width: 2 * sizeUnit),
                borderRadius: BorderRadius.circular(28 * sizeUnit),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2 * sizeUnit),
                borderRadius: BorderRadius.circular(28 * sizeUnit),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 2 * sizeUnit),
                borderRadius: BorderRadius.circular(28 * sizeUnit),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// radio 버튼 큰거
Widget vfWideRadioButtonWrap({
  required List<String> stringList,
  required String value,
  required Function(String) onTap,
  Color fillColor = vfColorOrange,
  EdgeInsetsGeometry? margin,
}) {
  return Column(
    children: List.generate(stringList.length, (index) {
      String text = stringList[index];
      bool isChecked = text == value;

      return GestureDetector(
        onTap: () => onTap(text),
        child: Container(
          margin: margin,
          child: vfWideContainer(
            fillColor: isChecked ? fillColor : Color.fromRGBO(255, 255, 255, 0.8),
            isChecked: isChecked,
            child: Text(text, style: VfTextStyle.subTitle2().copyWith(color: isChecked ? Colors.white : vfColorBlack)),
          ),
        ),
      );
    }),
  );
}

// radio 버튼 작은거
Widget vfFitRadioButtonWrap({
  required List<String> stringList,
  required String value,
  required Function(String) onTap,
  double spacing = 0, // sizeUnit 밑에서 하고있음
  double runSpacing = 0, // sizeUnit 밑에서 하고있음
  Color fillColor = vfColorOrange,
  WrapAlignment alignment = WrapAlignment.start,
  double? width,
  TextAlign? textAlign,
}) {
  return Wrap(
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    children: List.generate(stringList.length, (index) {
      String text = stringList[index];
      bool isChecked = text == value;

      return GestureDetector(
        onTap: () => onTap(text),
        child: vfFitContainer(
          isChecked: isChecked,
          fillColor: fillColor,
          child: Text(
            text,
            style: VfTextStyle.body1().copyWith(color: isChecked ? Colors.white : vfColorBlack),
            textAlign: textAlign,
          ),
          width: width,
        ),
      );
    }),
  );
}

// 다이얼로그
showVfDialog({
  required String title,
  required vfGradationColorType colorType,
  String description = '',
  String okText = '확인',
  String cancelText = '취소',
  GestureTapCallback? okFunc,
  Color okColor = vfColorRed,
  bool isCancelButton = false,
  GestureTapCallback? cancelFunc,
  GestureTapCallback? emptyPlaceTap,
  bool isBarrierDismissible = true,
  Widget? middleWidget,
}) {
  TextStyle titleStyle = VfTextStyle.headline4();
  TextStyle descriptionStyle = VfTextStyle.subTitle4();

  List<Color> colorList = gradationColorList(colorType, 'background');

  return Get.dialog(
    Stack(
      children: [
        if (isBarrierDismissible == true) ...[
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: colorList)),
            ),
            onTap: () {
              if (emptyPlaceTap == null)
                Get.back();
              else
                emptyPlaceTap();
            },
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: colorList)),
          ),
        ],
        Center(
          child: Container(
            width: 280 * sizeUnit,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20 * sizeUnit),
              boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 6 * sizeUnit, offset: Offset(0, 6))],
            ),
            child: DefaultTextStyle(
              style: TextStyle(decoration: TextDecoration.none),
              child: Padding(
                padding: EdgeInsets.fromLTRB(33 * sizeUnit, 24 * sizeUnit, 33 * sizeUnit, 24 * sizeUnit),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty) Text(title, style: titleStyle, textAlign: TextAlign.center),
                    if (middleWidget != null) middleWidget,
                    if (description.isNotEmpty) ...[
                      SizedBox(
                        height: 16 * sizeUnit,
                      ),
                      Text(
                        description,
                        style: descriptionStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(
                      height: 24 * sizeUnit,
                    ),
                    vfGradationButton(
                      text: okText,
                      colorType: colorType,
                      buttonType: GRADATION_BUTTON_TYPE.round,
                      onTap: okFunc == null
                          ? () {
                              Get.back();
                            }
                          : okFunc,
                    ),
                    if (isCancelButton) ...[
                      SizedBox(height: 8 * sizeUnit),
                      vfGradationButton(
                        text: cancelText,
                        isCancelButton: true,
                        isOk: false,
                        colorType: vfGradationColorType.Violet,
                        buttonType: GRADATION_BUTTON_TYPE.round,
                        onTap: cancelFunc == null
                            ? () {
                                Get.back();
                              }
                            : cancelFunc,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    barrierColor: Colors.white.withOpacity(0),
  );
}

// 앱바
PreferredSize vfAppBar(
  BuildContext context, {
  String title = '',
  bool isBackButton = true,
  GestureTapCallback? backFunc,
  List<Widget>? actions,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(56 * sizeUnit),
    child: AppBar(
      centerTitle: true,
      elevation: 0,
      toolbarHeight: 56 * sizeUnit,
      backgroundColor: Colors.transparent,
      leading: isBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit),
              child: GestureDetector(
                onTap: backFunc == null ? () => Get.back() : backFunc,
                child: Padding(
                  padding: EdgeInsets.all(4 * sizeUnit),
                  child: SvgPicture.asset(
                    svgBackArrow,
                  ),
                ),
              ),
            )
          : Container(),
      title: Text(
        title,
        style: VfTextStyle.headline4(),
      ),
      actions: actions,
    ),
  );
}

// 그라데이션 버튼
enum GRADATION_BUTTON_TYPE { normal, round }

Widget vfGradationButton({
  required String text,
  required vfGradationColorType colorType,
  bool isOk = true,
  bool isCancelButton = false,
  GRADATION_BUTTON_TYPE buttonType = GRADATION_BUTTON_TYPE.normal,
  required GestureTapCallback onTap,
}) {
  List<Color> colorList = gradationColorList(colorType, 'button');

  bool haveBottomPadding = devicePadding.bottom != 0;
  BorderRadius? borderRadius = buttonType == GRADATION_BUTTON_TYPE.round || haveBottomPadding ? BorderRadius.circular(28 * sizeUnit) : null;

  return Container(
    margin: EdgeInsets.symmetric(horizontal: buttonType == GRADATION_BUTTON_TYPE.normal && haveBottomPadding ? 24 * sizeUnit : 0),
    child: Material(
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          if (isOk || isCancelButton) onTap();
        },
        child: Container(
          width: double.infinity,
          height: buttonType == GRADATION_BUTTON_TYPE.round ? 48 * sizeUnit : 56 * sizeUnit,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: (buttonType == GRADATION_BUTTON_TYPE.round) ? Border.all(color: Color.fromRGBO(255, 255, 255, 0.8)) : null,
            color: isOk ? null : vfColorGrey,
            borderRadius: borderRadius,
            gradient: isOk ? LinearGradient(colors: colorList) : null,
            boxShadow: vfBasicBoxShadow,
          ),
          child: Text(
            text,
            style: buttonType == GRADATION_BUTTON_TYPE.normal && !haveBottomPadding ? VfTextStyle.subTitle1().copyWith(color: Colors.white) : VfTextStyle.subTitle2().copyWith(color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

// 계정 생성, 찾기 페이지 헤더
Padding vfAccountHeader({required String title, required String subTitle}) {
  return Padding(
    padding: EdgeInsets.only(left: 20 * sizeUnit),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          svgVfLogo,
          width: 156 * sizeUnit,
          height: 88 * sizeUnit,
        ),
        SizedBox(height: 24 * sizeUnit),
        Text(title, style: VfTextStyle.headline3()),
        SizedBox(height: 8 * sizeUnit),
        Text(subTitle, style: VfTextStyle.subTitle4())
      ],
    ),
  );
}

// 베프 라운드 컨테이너 와이드한거
Container vfWideContainer({
  required Widget child,
  bool isChecked = false,
  Color? fillColor,
  Alignment alignment = Alignment.center,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    padding: EdgeInsets.all(1 * sizeUnit),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24 * sizeUnit),
      gradient: isChecked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0.2)],
            )
          : null,
    ),
    child: Container(
      height: 48 * sizeUnit,
      alignment: alignment,
      decoration: BoxDecoration(
        color: isChecked ? fillColor : Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.circular(24 * sizeUnit),
        boxShadow: vfBasicBoxShadow,
      ),
      child: (alignment == Alignment.centerLeft)
          ? Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit),
              child: child,
            )
          : Padding(
              padding: padding != null ? padding : EdgeInsets.zero,
              child: child,
            ),
    ),
  );
}

//형광펜 밑줄 텍스트
Widget highlightText({
  required String text,
  required TextStyle style,
  required Color highlightColor,
  required double highlightSize,
  double highlightHeight = 10,
}) {
  return Container(
    width: highlightSize,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: highlightHeight * sizeUnit / 3,
          child: Container(
            height: highlightHeight * sizeUnit,
            width: highlightSize,
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(5 * sizeUnit),
            ),
          ),
        ),
        Text(
          text,
          style: style,
        ),
      ],
    ),
  );
}

// 베프 라운드 컨테이너 핏한거
Widget vfFitContainer({
  required child,
  bool isChecked = false,
  Color fillColor = vfColorOrange,
  double? width,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    padding: EdgeInsets.all(1 * sizeUnit),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24 * sizeUnit),
      gradient: isChecked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0.2)],
            )
          : null,
    ),
    child: Container(
      height: 32 * sizeUnit,
      width: width,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 6 * sizeUnit),
      decoration: BoxDecoration(
        color: isChecked ? fillColor : Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.circular(24 * sizeUnit),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: child,
    ),
  );
}

// 그라데이션 아이콘 위젯
Widget vfGradationIconWidget({required String iconPath, bool isBorder = true, BlendMode? blendMode, double size = 40}) {
  return Container(
      width: size * sizeUnit,
      height: size * sizeUnit,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        backgroundBlendMode: blendMode,
        gradient: LinearGradient(
          colors: [vfGradationViolet2.withOpacity(0.6), vfGradationViolet1.withOpacity(0.4)],
          stops: [0.5, 1.6], //그라데이션 위치 보정값
        ),
      ),
      child: Center(
          child: SvgPicture.asset(
        iconPath,
        width: isBorder ? size - 2 * sizeUnit : size * sizeUnit,
        height: isBorder ? size - 2 * sizeUnit : size * sizeUnit,
      )));
}

// datePicker
Future<String?> vfDatePicker({required BuildContext context, required MaterialColor color}) async {
  final DateTime _now = DateTime.now();
  String? result;

  await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
            height: 190,
            color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                Container(
                  height: 180,
                  child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      mode: CupertinoDatePickerMode.date,
                      maximumYear: _now.year,
                      minimumYear: _now.year - 100,
                      onDateTimeChanged: (val) {
                        result = val.toString().replaceAll('-', '.');
                      }),
                ),
              ],
            ),
          ));

  if (result != null) {
    return result!.substring(0, 10);
  } else {
    return result;
  }
}

// weightPicker
Future vfWeightPicker({
  required BuildContext context,
  required RxInt firstWeight,
  required RxInt secondWeight,
  required RxDouble weight,
  required Function validCheckFunc,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200 * sizeUnit,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: firstWeight.value,
                ),
                itemExtent: 32 * sizeUnit,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  firstWeight(index);
                  weight(index + (((weight * 10) % 10)) / 10);
                  validCheckFunc();
                },
                children: List.generate(
                  100,
                  (index) => Center(
                    child: Text('$index'),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: secondWeight.value,
                ),
                itemExtent: 32 * sizeUnit,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  secondWeight(index);
                  weight(((weight * 10) ~/ 10) + index / 10);
                  validCheckFunc();
                },
                children: List.generate(
                  10,
                  (index) => Center(
                    child: Text('$index'),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

//사료 직접입력에서 사용중
Future vfNumberPicker({
  required BuildContext context,
  required RxDouble value, //선택을 저장할 변수
  required int max, //정수부 어디까지 + 1
  required int decimalPointBelow, //소숫점 아래 어디까지
}) {
  int num1 = 0; //정수부
  int num2 = 0; //소수부
  int _decimal = pow(10, decimalPointBelow).toInt();
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200 * sizeUnit,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: num1,
                ),
                itemExtent: 32 * sizeUnit,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  num1 = index;
                  value(num1.toDouble() + num2 / _decimal);
                },
                children: List.generate(
                  max,
                  (index) => Center(
                    child: Text('$index'),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: num2,
                ),
                itemExtent: 32 * sizeUnit,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  num2 = index;
                  value(num1.toDouble() + num2 / _decimal);
                },
                children: List.generate(
                  _decimal,
                  (index){
                    String text = index.toString();

                    while(text.length < decimalPointBelow){
                      text = '0'+text;
                    }
                    return Center(
                      child: Text(text),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// 새로고침
Widget vfCustomRefreshIndicator({required Widget child, required Future<void> onRefresh(), Color indicatorColor = vfColorPink}) {
  return CustomRefreshIndicator(
    onRefresh: () async {
      await onRefresh();
      return Future.delayed(const Duration(milliseconds: 500));
    },
    builder: (
      BuildContext context,
      Widget child,
      IndicatorController indicatorController,
    ) {
      return AnimatedBuilder(
        animation: indicatorController,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              !indicatorController.isDragging && !indicatorController.isHiding && !indicatorController.isIdle
                  ? Positioned(
                      top: 12 * sizeUnit * indicatorController.value,
                      child: GradientCircularProgressIndicator(radius: 16, strokeWidth: 4),
                    )
                  : Container(),
              Transform.translate(
                offset: Offset(0, 60 * sizeUnit * indicatorController.value),
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              ),
            ],
          );
        },
      );
    },
    child: child,
  );
}

// 베프 로딩 다이어로그
vfLoadingDialog({String text = '', List<Color> colorList = loadingVioletColorList}) {
  if (text == '') {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: GradientCircularProgressIndicator(gradientColors: colorList),
        ),
      ),
    );
  } else {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientCircularProgressIndicator(gradientColors: colorList),
              SizedBox(
                height: 16 * sizeUnit,
              ),
              Text(
                text,
                style: VfTextStyle.headline4(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 검색 결과 없음 위젯
Widget noSearchResultWidget({String text = '검색 결과가 없어요!'}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        vfBetiBodyBadStateWidget(),
        SizedBox(height: 16 * sizeUnit),
        Text(text, style: VfTextStyle.subTitle2()),
      ],
    ),
  );
}

Widget vfPramBodyGoodStateWidget() {
  return SvgPicture.asset(
    svgPramBodyGoodState,
    width: 176 * sizeUnit,
    height: 120 * sizeUnit,
  );
}

Widget vfBetiBodyBadStateWidget() {
  return SvgPicture.asset(
    svgBetiBodyBadState,
    width: 90 * sizeUnit,
    height: 106 * sizeUnit,
  );
}

Widget vfBetiHeadBadStateWidget({double scale = 1.0}) {
  return SvgPicture.asset(
    svgBetiHeadBadState,
    width: 48 * sizeUnit * scale,
    height: 44 * sizeUnit * scale,
  );
}
