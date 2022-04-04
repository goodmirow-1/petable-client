import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/global_page/feeds_choice_page.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/snack_intake_controller.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:myvef_app/intake/model/snack_intake.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class SnackDirectInputPage extends StatelessWidget {
  SnackDirectInputPage({Key? key}) : super(key: key);

  final GraphPageController controller = Get.find<GraphPageController>();
  final SnackController snackController = Get.find<SnackController>();
  final CalorieController calorieController = Get.find<CalorieController>();
  final WaterController waterController = Get.find<WaterController>();
  final TextEditingController textEditingController = TextEditingController();

  RxString snackName = ''.obs; // 종류
  RxString dateTime = ''.obs; // 시간
  RxString amount = ''.obs; // 급여량

  int snackID = 0; // 선택된 사료 ID
  bool isFeed = true; // 사료인지 물인지
  String unit = 'g';

  @override
  Widget build(BuildContext context) {
    isFeed = controller.barIndex.value == GRAPH_TYPE_FEED;
    unit = isFeed ? 'g' : 'ml';

    return baseWidget(
      context,
      type: 2,
      colorType: isFeed ? vfGradationColorType.Red : vfGradationColorType.Blue,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '직접입력',
          backFunc: () {
            unFocus(context);
            Get.back();
          },
        ),
        body: GestureDetector(
          onTap: () => unFocus(context),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 24 * sizeUnit),
                      inputField(
                        label: '종류*',
                        hintText: '제품선택',
                        rxString: snackName,
                        onTap: () => Get.to(() => FeedChoicePage(
                                  petType: GlobalData.mainPet.value.type,
                                  isSnack: true,
                                  isDrink: !isFeed,
                                  colorType: isFeed ? vfGradationColorType.Red : vfGradationColorType.Blue,
                                ))!
                            .then((value) {
                          if (value != null) {
                            snackID = value[0]; // 사료 ID
                            snackName(value[1]); // 사료 이름

                            // 개당 무게가 있으면 급여량 자동으로 넣어주기
                            if(value[2] > 0) {
                              textEditingController.text = value[2].toString(); // 텍스트 필드 삽입
                              amount(value[2].toString());
                            }

                          }
                        }),
                      ),
                      SizedBox(height: 24 * sizeUnit),
                      inputField(
                        label: '시간*',
                        hintText: 'YYYY.MM.DD',
                        rxString: dateTime,
                        onTap: () => dateTimePicker(context: context, color: isFeed ? Colors.orange : Colors.blue),
                      ),
                      SizedBox(height: 24 * sizeUnit),
                      inputTextField(
                        label: '급여량($unit)*',
                        hintText: '급여량 입력',
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() => vfGradationButton(
                    text: '완료',
                    colorType: isFeed ? vfGradationColorType.Red : vfGradationColorType.Blue,
                    isOk: isOk.value,
                    onTap: () async{
                      unFocus(context);
                      vfLoadingDialog(); // 로딩 시작

                      String formatDateTime = dateTime.value.replaceAll('.', '-') + ':00';

                      SnackIntake snack = SnackIntake.fromJson({
                        'PetID': GlobalData.mainPet.value.id,
                        'SnackID': snackID,
                        'Amount': double.parse(amount.value),
                        'Time': formatDateTime,
                      });

                      await snackController.insertSnack(snack); // 먹은 스낵 서버에 쏘고 local DB 저장
                      await controller.setGraph(setIntake: false); // 스낵 칼로리, 물 리스트에 저장하고 그래프 세팅

                      controller.stateUpdate(); // setState

                      Get.back(); // 로딩 끝
                      Get.back(); // 그래프 페이지로 이동

                      Fluttertoast.showToast(
                        msg: '입력이 완료되었습니다.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // 종류, 시간
  Column inputField({required String label, required String hintText, required RxString rxString, required GestureTapCallback onTap}) {
    return Column(
      children: [
        Text(
          label,
          style: VfTextStyle.highlight3(),
        ),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
          child: GestureDetector(
            onTap: onTap,
            child: vfWideContainer(
              padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
              child: Obx(() => Text(
                    rxString.value.isEmpty ? hintText : rxString.value,
                    style: VfTextStyle.subTitle2().copyWith(color: rxString.value.isEmpty ? vfColorDarkGray : vfColorBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  // 급여량
  Column inputTextField({required String label, required String hintText}) {
    return Column(
      children: [
        Text(
          label,
          style: VfTextStyle.highlight3(),
        ),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
          child: vfTextField(
            textEditingController: textEditingController,
            borderColor: isFeed ? vfColorOrange : vfColorSkyBlue,
            keyboardType: TextInputType.number,
            hintText: hintText,
            textAlign: TextAlign.center,
            textStyle: VfTextStyle.subTitle2(),
            hintStyle: VfTextStyle.subTitle2().copyWith(color: vfColorDarkGray),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
            maxLength: 5,
            onChanged: (value) {
              if(value.isNotEmpty && double.parse(value) > 999){
                textEditingController.text = amount.value;
                textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));

                Fluttertoast.showToast(
                  msg: '급여량은 999g까지 입력 가능합니다.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                  textColor: Colors.white,
                );
              } else {
                amount(value);
              }
            },
          ),
        ),
      ],
    );
  }

  // 년, 월, 일
  Future<void> dateTimePicker({required BuildContext context, required MaterialColor color}) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'),
      initialDatePickerMode: DatePickerMode.day,
      errorFormatText: '날짜를 올바르게 입력해주세요. ex) 2019. 07 .31.',
      errorInvalidText: '날짜를 올바르게 입력해주세요.',
      fieldLabelText: '날짜 입력',
      builder: (context, child) {
        return Theme(
          data: pickerThemeData(color: color),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        String year = value.year.toString();
        String month = (value.month.toString().length > 1) ? value.month.toString() : '0' + value.month.toString();
        String day = (value.day.toString().length > 1) ? value.day.toString() : '0' + value.day.toString();
        dateTime(year + '.' + month + '.' + day);
        timePicker(context: context, color: color);
      }
    });
  }

  // 시간
  Future<void> timePicker({required BuildContext context, required MaterialColor color}) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: pickerThemeData(color: color),
          child: child!,
        );
      },
    ).then((value) {
      String _hour = '';
      String _minute = '';
      if (value != null) {
        _hour = value.hour.toString();
        _minute = value.minute.toString();

        if (_hour.length < 2) _hour = '0' + _hour;
        if (_minute.length < 2) _minute = '0' + _minute;
      } else {
        _hour = '00';
        _minute = '00';
      }

      dateTime(dateTime.value += ' $_hour:$_minute');
    });
  }

  ThemeData pickerThemeData({required MaterialColor color}) {
    return ThemeData(
      fontFamily: 'SpoqaHanSansNeo',
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: color,
      ),
    );
  }

  RxBool get isOk => (snackName.value.isNotEmpty && dateTime.value.isNotEmpty && amount.value.isNotEmpty && amount.value != '.').obs;
}
