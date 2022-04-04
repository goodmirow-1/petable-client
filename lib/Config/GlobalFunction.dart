// 이메일 유효성 검사
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/intake_contoller.dart';
import 'package:myvef_app/intake/controller/snack_intake_controller.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import "package:normal/normal.dart";
import 'Constant.dart';

String validEmailErrorText(String email) {
  String errMsg = '';
  if (email.isEmpty) return '';

  RegExp regExp = RegExp(r'^[0-9a-zA-Z][0-9a-zA-Z\_\-\.\+]+[0-9a-zA-Z]@[0-9a-zA-Z][0-9a-zA-Z\_\-]*[0-9a-zA-Z](\.[a-zA-Z]{2,6}){1,2}$');

  if (email.length < 6) {
    errMsg = "최소 6글자 이상의 이메일이어야 해요.";
  } else if (regExp.hasMatch(email)) {
    errMsg = '';
  } else {
    errMsg = "메일 형식에 맞게 입력해 주세요.";
  }
  return errMsg;
}

// 비밀번호 유효성 검사
String validPasswordErrorText(String password) {
  String errMsg = '';
  if (password.isEmpty) return '';

  RegExp exp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,20}$');

  if (!exp.hasMatch(password)) {
    errMsg = "비밀번호는 숫자, 대소문자 특수문자를 조합해 8~20 자리 이내로 입력해 주세요";
  } else if (password.length < 8) {
    errMsg = '8자리 이상 입력해 주세요.';
  }
  return errMsg;
}

// 비밀번호 확인
String validPasswordConfirmErrorText(String password, String passwordConfirm) {
  String errMsg = '';

  if (passwordConfirm == password) {
    errMsg = '';
  } else {
    errMsg = '비밀번호가 일치하지 않아요!';
  }
  return errMsg;
}

// 실명 유효성 검사
String validRealNameErrorText(String name) {
  String errMsg = '';

  if (name.isEmpty) return '';
  RegExp regExp = RegExp(r'(^[가-힣]{2,10}$)'); // 2 ~ 10개 한글 입력가능
  if (regExp.hasMatch(name)) {
    errMsg = '';
  } else {
    errMsg = '이름을 정확히 입력해 주세요.';
  }
  return errMsg;
}

// 핸드폰 유효성 검사
String validPhoneNumErrorText(String number) {
  String errMsg = '';

  if (number.isEmpty) return ''; // number 빈 값일 때 empty 리턴
  RegExp regExp = RegExp(r'^\d{10,11}$'); // 10 ~ 11개 숫자 입력가능
  if (regExp.hasMatch(number)) {
    errMsg = '';
  } else {
    errMsg = '휴대폰 번호를 정확히 입력해 주세요.';
  }
  return errMsg;
}

// nickname 유효성 검사
String validNickNameErrorText(String nickname) {
  String errMsg = '';
  if (nickname.isEmpty) return '';

  int utf8Length = utf8.encode(nickname).length;

  RegExp regExp = RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]'); //허용문자 _.

  if (regExp.hasMatch(nickname)) {
    return "일부 특수문자는 사용할 수 없어요.\n/!@#<>?\":`~;[]\\|=+)(*&^% -";
  }
  if (nickname.length < 2) {
    return "2자 이상 15자 이하로 입력해 주세요.";
  }
  if (nickname.length > 15 || utf8Length > 45) {
    return "2자 이상 15자 이하로 입력해 주세요.";
  }

  return errMsg;
}

// pet name 유효성 검사
String validPetNameErrorText(String nickname) {
  String errMsg = '';
  if (nickname.isEmpty) return '';

  RegExp regExp = RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]'); //허용문자 _.

  if (regExp.hasMatch(nickname)) {
    return "일부 특수문자는 사용할 수 없어요.\n/!@#<>?\":`~;[]\\|=+)(*&^% -";
  }

  return errMsg;
}

// pet 질병, 알러지 유효성 검사
String validPetAdditionalInfoErrorText(String info) {
  String errMsg = '';

  if (info.isEmpty) return '';

  RegExp regExp = RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%-]'); //허용문자 _.띄어쓰기

  if (regExp.hasMatch(info)) {
    return '특수문자는 사용할 수 없어요';
  }

  return errMsg;
}

//포커스 해제 함수
void unFocus(BuildContext context) {
  FocusManager.instance.primaryFocus!.unfocus();
}

// 그라데이션 리스트 반환 함수
List<Color> gradationColorList(vfGradationColorType colorType, String location) {
  List<Color> colorList = [];

  if (location == 'button') {
    switch (colorType) {
      case vfGradationColorType.Red:
        colorList = [vfGradationRed2, vfGradationRed1];
        break;
      case vfGradationColorType.Blue:
        colorList = [vfGradationBlue1, vfGradationBlue2];
        break;
      case vfGradationColorType.Violet:
        colorList = [vfGradationViolet2, vfGradationViolet1];
        break;
      case vfGradationColorType.Pink:
        colorList = [vfColorPink40, vfColorPink60];
        break;
    }
  } else if (location == 'background') {
    switch (colorType) {
      case vfGradationColorType.Red:
        colorList = [vfBackgroundGradationRed2, vfBackgroundGradationRed1];
        break;
      case vfGradationColorType.Blue:
        colorList = [vfBackgroundGradationBlue1, vfBackgroundGradationBlue2];
        break;
      case vfGradationColorType.Violet:
        colorList = [vfBackgroundGradationViolet2, vfBackgroundGradationViolet1];
        break;
      case vfGradationColorType.Pink:
        colorList = [vfColorPink40, vfColorPink60];
        break;
    }
  }

  return colorList;
}

String replaceDate(String date) {
  if (date == "") return "";

  DateTime dateTime = DateTime.parse(date);
  //dateTime = dateTime.add(Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

  String replaceStr = dateTime.toString();
  return replaceStr.replaceAll('T', ' ').replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '');
}

String replaceDateToDateTime(String date) {
  DateTime dateTime = DateTime.parse(date);
  dateTime = dateTime.add(Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

  String months = dateTime.month < 10 ? '0' + dateTime.month.toString() : dateTime.month.toString();
  String days = dateTime.day < 10 ? '0' + dateTime.day.toString() : dateTime.day.toString();

  String hours = dateTime.hour < 10 ? '0' + dateTime.hour.toString() : dateTime.hour.toString();
  String minutes = dateTime.minute < 10 ? '0' + dateTime.minute.toString() : dateTime.minute.toString();
  String seconds = dateTime.second < 10 ? '0' + dateTime.second.toString() : dateTime.second.toString();

  return dateTime.year.toString() + '-' + months + '-' + days + ' ' + hours + ':' + minutes + ':' + seconds;
}

String timeCheck(String tmp) {
  int year = int.parse(tmp[0] + tmp[1] + tmp[2] + tmp[3]);
  int month = int.parse(tmp[4] + tmp[5]);
  int day = int.parse(tmp[6] + tmp[7]);
  int hour = int.parse(tmp[8] + tmp[9]);
  int minute = int.parse(tmp[10] + tmp[11]);
  int second = int.parse(tmp[12] + tmp[13]);

  final date1 = DateTime(year, month, day, hour, minute, second);
  var date2 = DateTime.now();
  final differenceDays = date2.difference(date1).inDays;
  final differenceHours = date2.difference(date1).inHours;
  final differenceMinutes = date2.difference(date1).inMinutes;
  final differenceSeconds = date2.difference(date1).inSeconds;

  if (differenceDays > 13) {
    return "$month" + "월 " + "$day" + "일";
  } else if (differenceDays > 6) {
    return "일주일전";
  } else {
    if (differenceDays > 1) {
      return "$differenceDays" + "일전";
    } else if (differenceDays == 1) {
      return "하루전";
    } else {
      if (differenceHours >= 1) {
        return "$differenceHours" + "시간전";
      } else {
        if (differenceMinutes >= 1) {
          return "$differenceMinutes" + "분전";
        } else {
          if (differenceSeconds >= 0) {
            return "$differenceSeconds" + "초전";
          } else {
            return "방금";
          }
        }
      }
    }
  }
}

//DateTime.toString 변환했던 문자열을 DateTime 으로 바꿔주는 함수
DateTime dateTimeFromString(String dateString) {
  int year = int.parse(dateString.substring(0, 4));
  int month = int.parse(dateString.substring(5, 7));
  int day = int.parse(dateString.substring(8, 10));
  int hour = int.parse(dateString.substring(11, 13));
  int minute = int.parse(dateString.substring(14, 16));
  int second = int.parse(dateString.substring(17, 19));

  return DateTime(year, month, day, hour, minute, second);
}

// 펫 나이 체크
String petAgeCheck(String birthday) {
  String result = '';
  int age = nullInt;

  if (birthday.isNotEmpty) {
    int year = int.parse(birthday[0] + birthday[1] + birthday[2] + birthday[3]);
    int month = int.parse(birthday[5] + birthday[6]);
    int day = int.parse(birthday[8] + birthday[9]);

    final birthDate = DateTime(year, month, day);
    DateTime now = DateTime.now();

    age = now.year - birthDate.year; // 몇 살인지 체크

    // 생일 안지났으면 -1살
    if (birthDate.month > now.month) {
      age--;
    } else if (birthDate.month == now.month) {
      if (birthDate.day > now.day) {
        age--;
      }
    }

    // 0살이면
    if (age == 0) {
      age = now.month - birthDate.month; // 개월 수 체크

      // 이번 달에 태어난 경우
      if (now.year == birthDate.year && age == 0) {
        result = '0개월';
        return result;
      }

      if (age <= 0) age += 12; // 개월 수가 음수인 경우 해가 바뀌는거기 때문에 + 12개월

      if (birthDate.day > now.day) age--; // 생일 안지난 경우 -1개월

      result = age.toString() + '개월';
    } else {
      if (age < 1) age = 0; // 오늘 날짜보다 지난 생일 예외체크
      result = age.toString() + '살';
    }
  }

  return result;
}

void accessTokenCheck() {
  GlobalData.tokenTimer = Timer.periodic(Duration(minutes: 5), (timer) {
    if (int.parse(GlobalData.accessTokenExpiredAt) < int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10))) {
      Future.microtask(() async {
        debugPrint('refresh token call in func');

        var res = await ApiProvider().post('/User/Check/Token', jsonEncode({"userID": GlobalData.loggedInUser.value.userID, "refreshToken": GlobalData.refreshToken}));

        if (res != null) {
          GlobalData.accessToken = res['AccessToken'] as String;
          GlobalData.accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
        }
      });
    }
  });
}

//지명 약어화 함수
String abbreviateForLocation(String location) {
  List<String> locationList = location.split(' ');
  String header = locationList[0];

  switch (locationList[0]) {
    case '서울특별시':
      header = '서울';
      break;
    case '인천광역시':
      header = '인천';
      break;
    case '경기도':
      header = '경기';
      break;
    case '강원도':
      header = '강원';
      break;
    case '충청남도':
      header = '충남';
      break;
    case '충청북도':
      header = '충북';
      break;
    case '세종특별자치시':
      header = '세종';
      break;
    case '대전광역시':
      header = '대전';
      break;
    case '경상북도':
      header = '경북';
      break;
    case '경상남도':
      header = '경남';
      break;
    case '대구광역시':
      header = '대구';
      break;
    case '부산광역시':
      header = '부산';
      break;
    case '전라북도':
      header = '전북';
      break;
    case '전라남도':
      header = '전남';
      break;
    case '광주광역시':
      header = '광주';
      break;
    case '울산광역시':
      header = '울산';
      break;
    case '제주특별자치도':
      header = '제주';
      break;
  }

  String res = header;
  for (int i = 1; i < locationList.length; ++i) {
    res += ' ' + locationList[i];
  }

  return res;
}

Future<bool> isBigFile(var file) async {
  int fileSize = (await file.readAsBytes()).lengthInBytes;

  //약 10mb
  if (fileSize >= 10500000) {
    Fluttertoast.showToast(msg: "용량이 10mb 이상인 파일은 전송할 수 없습니다.", toastLength: Toast.LENGTH_SHORT);
    return Future.value(true);
  }

  return Future.value(false);
}

//섭취데이터 세팅, 로그인시, 메인펫 변경시
Future<void> intakeDataSetting() async {
  CalorieController calorieController = Get.put(CalorieController());
  WaterController waterController = Get.put(WaterController());
  await calorieController.setCalorie();
  await waterController.setWater();
  await IntakeController().setIntake();
  await SnackController().setSnack();
}

//공백 제어 함수
String controlSpace(String text) {
  String result = text;
  while (result.contains('\t')) {
    result = result.replaceAll('\t', ' ');
  }
  while (result.contains('\n\n\n')) {
    result = result.replaceAll('\n\n\n', '\n\n');
  }
  while (result.contains('\n ')) {
    result = result.replaceAll('\n ', ' ');
  }
  while (result.contains('　')) {
    result = result.replaceAll('　', '  ');
  }
  while (result.contains('\u200B')) {
    result = result.replaceAll('\u200B', '');
  }
  while (result.contains('   ')) {
    result = result.replaceAll('   ', '  ');
  }
  return result;
}

//공백 제거 함수
String removeSpace(String text) {
  String result = text;
  result = result.replaceAll(' ', '');
  result = result.replaceAll('\n', '');
  result = result.replaceAll('　', '');
  result = result.replaceAll('\t', '');
  result = result..replaceAll('\u200B', '');

  return result;
}

// 상위 % 계산 함수
double topPercent(double value, double mean, double standardDeviation) {
  double z = (value - mean) / standardDeviation;
  double percent = 1 - Normal.cdf(z);

  if (percent.isNaN)
    percent = 1.0;
  else
    percent = (percent * 100).round() / 100;

  return percent;
}

// 앱 종료 체크 함수
Future<bool> isEnd() async {
  DateTime now = DateTime.now();

  if (GlobalData.currentBackPressTime == null || now.difference(GlobalData.currentBackPressTime!) > Duration(seconds: 2)) {
    GlobalData.currentBackPressTime = now;

    Fluttertoast.showToast(
      msg: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
      textColor: Colors.white,
    );
    // showSheepsToast(context: context, text: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');

    return Future.value(false);
  }
  return Future.value(true);
}

