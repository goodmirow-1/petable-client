import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/graph/model/graph_data.dart';
import 'package:jiffy/jiffy.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/intake_contoller.dart';
import 'package:myvef_app/intake/controller/snack_intake_controller.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// 그래프 타입
const int GRAPH_TYPE_FEED = 0;
const int GRAPH_TYPE_WATER = 1;

// 그래프 상태 (일, 주, 월, 년)
const int GRAPH_PERIOD_DAY = 0;
const int GRAPH_PERIOD_WEEK = 1;
const int GRAPH_PERIOD_MONTH = 2;
const int GRAPH_PERIOD_YEAR = 3;

class GraphPageController extends GetxController {
  static get to => Get.find<GraphPageController>();
  final PageController pageController = PageController();
  final CalorieController calorieController = Get.put(CalorieController());
  final WaterController waterController = Get.put(WaterController());
  final IntakeController intakeController = Get.put(IntakeController());
  final SnackController snackController = Get.put(SnackController());

  final Duration barDuration = Duration(milliseconds: 300); // 그래프 바 duration
  final double barMaxHeight = Get.height * 0.38 > 286 * sizeUnit ? 286 * sizeUnit : Get.height * 0.38; // 그래프 바 최대 높이

  RxInt barIndex = 0.obs;
  RxInt periodIndex = 0.obs; //0 일, 1 주, 2 월, 3 년

  List<GraphData> feedIntakeListForDay = []; // 사료 섭취량 리스트 (일)
  List<GraphData> feedIntakeListForWeek = []; // 사료 섭취량 리스트 (주, 월)
  List<GraphData> feedIntakeListForYear = []; // 사료 섭취량 리스트 (년)

  List<GraphData> waterIntakeListForDay = []; // 물 음수량 리스트 (일)
  List<GraphData> waterIntakeListForWeek = []; // 물 음수량 리스트 (주, 월)
  List<GraphData> waterIntakeListForYear = []; // 물 음수량 리스트 (년)

  DateTime now = DateTime.now();

  DateTime firstFeedDate = DateTime.now(); // 첫번째 데이터의 date
  DateTime lastFeedDate = DateTime.now(); // 마지막 데이터의 date

  DateTime firstWaterDate = DateTime.now(); // 첫번째 데이터의 date
  DateTime lastWaterDate = DateTime.now(); // 마지막 데이터의 date

  int feedTotalDifferDays = 0; // 마지막 데이터와 첫번째 데이터의 일수 차이
  int waterTotalDifferDays = 0; // 마지막 데이터와 첫번째 데이터의 일수 차이

  bool isLoading = false; // 로딩 여부

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  // 그래프 세팅
  Future<void> setGraph({bool setIntake = true, bool setSnack = true}) async{
    final DashBoardController dashBoardController = Get.find<DashBoardController>();

    clearGraphDataList(); // 그래프 데이터 리스트 클리어

    if(setIntake) await intakeController.setIntake(); // 최근 Intake 값 local 세팅 후 칼로리, 물 리스트에 insert
    if(setSnack) await snackController.setSnack(); // 최근 Snack 값 local 세팅 후 칼로리, 물 리스트에 insert

    sortKcalAndWater(); // 칼로리, 물 리스트 최신 날짜순으로 정렬

    dashBoardController.calTodayCalorie(); // 오늘 섭취한 칼로리 최신화 (kcal)
    dashBoardController.calTodayWater(); // 오늘 섭취한 물 최신화 (ml)
    dashBoardController.calYesterdayCalorie();//어제 섭취량 계산
    dashBoardController.calYesterdayWater();
    await dashBoardController.getTodayFeedIntake(); // 오늘 섭취한 사료 양 최신화 (g)

    // 사료
    if(calorieController.calorieList.isNotEmpty){
      setFeedDate(); // 계산에 필요한 date 세팅
      setFeedDataForDay(); // 데이터 세팅 (일 그래프)
      setFeedDataForWeek(); // 데이터 세팅 (주, 월 그래프)
      setFeedDataForYear(); // 데이터 세팅 (년 그래프)
    }

    // 물
    if(waterController.waterList.isNotEmpty){
      setWaterDate(); // 계산에 필요한 date 세팅
      setWaterDataForDay(); // 데이터 세팅 (일 그래프)
      setWaterDataForWeek(); // 데이터 세팅 (주, 월 그래프)
      setWaterDataForYear(); // 데이터 세팅 (년 그래프)
    }
  }

  // 그래프 데이터 리스트 클리어
  void clearGraphDataList(){
    feedIntakeListForDay.clear(); // 사료 섭취량 리스트 (일)
    feedIntakeListForWeek.clear(); // 사료 섭취량 리스트 (주, 월)
    feedIntakeListForYear.clear(); // 사료 섭취량 리스트 (년)

    waterIntakeListForDay.clear(); // 물 음수량 리스트 (일)
    waterIntakeListForWeek.clear(); // 물 음수량 리스트 (주, 월)
    waterIntakeListForYear.clear(); // 물 음수량 리스트 (년)
  }

  // 칼로리, 물 리스트 최신 날짜순으로 정렬
  void sortKcalAndWater(){
    calorieController.calorieList.sort((b, a) => a.time.compareTo(b.time));
    waterController.waterList.sort((b,a) => a.time.compareTo(b.time));
  }

  // 계산에 필요한 사료 date 세팅
  void setFeedDate() {
    // 오늘 날짜와 마지막 데이터의 날짜 세팅 (계산하기 편하게 day 까지만)
    firstFeedDate = DateTime(now.year, now.month, now.day);
    lastFeedDate = DateTime(calorieController.calorieList.last.time.year, calorieController.calorieList.last.time.month, calorieController.calorieList.last.time.day);

    // 오늘 날짜와 가장 마지막 데이터가 몇 일 차이 나는지
    feedTotalDifferDays = firstFeedDate.difference(lastFeedDate).inDays;
  }

  // 계산에 필요한 물 date 세팅
  void setWaterDate() {
    // 오늘 날짜와 마지막 데이터의 날짜 세팅 (계산하기 편하게 day 까지만)
    firstWaterDate = DateTime(now.year, now.month, now.day);
    lastWaterDate = DateTime(waterController.waterList.last.time.year, waterController.waterList.last.time.month, waterController.waterList.last.time.day);

    // 오늘 날짜와 가장 마지막 데이터가 몇 일 차이 나는지
    waterTotalDifferDays = firstWaterDate.difference(lastWaterDate).inDays;
  }

  // 사료 데이터 세팅 (일 그래프)
  void setFeedDataForDay() {
    // 갯수 맞춰서 만들기
    feedIntakeListForDay = List.generate(24 * (feedTotalDifferDays + 1), (index) => GraphData());

    for (int i = 0; i < calorieController.calorieList.length; i++) {
      DateTime lastDate = calorieController.calorieList[calorieController.calorieList.length - 1].time; // 마지막 데이터 date
      DateTime currentDate = calorieController.calorieList[i].time; // 현재 index 데이터 date

      // 마지막 데이터와 현재 i 값에 해당하는 데이터가 몇 일 차이 나는지
      int differDay = (DateTime(lastDate.year, lastDate.month, lastDate.day).difference(DateTime(currentDate.year, currentDate.month, currentDate.day)).inDays) * -1;

      int idx = (feedIntakeListForDay.length - 1) - (differDay * 24) - calorieController.calorieList[i].time.hour; // 데이터가 들어갈 index 계산

      if (calorieController.calorieList[i].type == INTAKE_MAIN) {
        feedIntakeListForDay[idx].main += calorieController.calorieList[i].amount.round();
        feedIntakeListForDay[idx].total += calorieController.calorieList[i].amount.round();
      } else {
        feedIntakeListForDay[idx].sub += calorieController.calorieList[i].amount.round();
        feedIntakeListForDay[idx].total += calorieController.calorieList[i].amount.round();
      }
    }
  }

  // 물 데이터 세팅 (일 그래프)
  void setWaterDataForDay() {
    // 갯수 맞춰서 만들기
    waterIntakeListForDay = List.generate(24 * (waterTotalDifferDays + 1), (index) => GraphData());

    for (int i = 0; i < waterController.waterList.length; i++) {
      DateTime lastDate = waterController.waterList[waterController.waterList.length - 1].time; // 마지막 데이터 date
      DateTime currentDate = waterController.waterList[i].time; // 현재 index 데이터 date

      // 마지막 데이터와 현재 i 값에 해당하는 데이터가 몇 일 차이 나는지
      int differDay = (DateTime(lastDate.year, lastDate.month, lastDate.day).difference(DateTime(currentDate.year, currentDate.month, currentDate.day)).inDays) * -1;

      int idx = (waterIntakeListForDay.length - 1) - (differDay * 24) - waterController.waterList[i].time.hour; // 데이터가 들어갈 index 계산

      if (waterController.waterList[i].type == INTAKE_MAIN) {
        waterIntakeListForDay[idx].main += waterController.waterList[i].amount.round();
        waterIntakeListForDay[idx].total += waterController.waterList[i].amount.round();
      } else {
        waterIntakeListForDay[idx].sub += waterController.waterList[i].amount.round();
        waterIntakeListForDay[idx].total += waterController.waterList[i].amount.round();
      }
    }
  }

  // 사료 데이터 세팅 (주, 월 그래프)
  void setFeedDataForWeek() {
    double mainIntake = 0.0; // 섭취량
    double subIntake = 0.0; // 섭취량
    DateTime preDate = firstFeedDate; // 이전 일자

    feedIntakeListForWeek = List.generate(feedTotalDifferDays + 1, (index) => GraphData());

    for (int i = 0; i < calorieController.calorieList.length; i++) {
      if (i > 0) preDate = DateTime(calorieController.calorieList[i - 1].time.year, calorieController.calorieList[i - 1].time.month, calorieController.calorieList[i - 1].time.day); // 하나 전 데이터

      // 전 데이터와 같은 날이면
      if (calorieController.calorieList[i].time.year == preDate.year && calorieController.calorieList[i].time.month == preDate.month && calorieController.calorieList[i].time.day == preDate.day) {
        if (calorieController.calorieList[i].type == INTAKE_MAIN) {
          mainIntake += calorieController.calorieList[i].amount; // 섭취량 더해주기
        } else {
          subIntake += calorieController.calorieList[i].amount; // 섭취량 더해주기
        }
      } else {
        int idx = firstFeedDate.difference(preDate).inDays; // 첫 번째 데이터와 전 데이터의 차이로 index 구하기

        // 데이터 삽입
        feedIntakeListForWeek[idx].main = mainIntake.round();
        feedIntakeListForWeek[idx].sub = subIntake.round();
        feedIntakeListForWeek[idx].total = feedIntakeListForWeek[idx].main + feedIntakeListForWeek[idx].sub;

        // 초기화
        mainIntake = 0;
        subIntake = 0;

        // 처음부터 다시 더하기
        if (calorieController.calorieList[i].type == INTAKE_MAIN) {
          mainIntake = calorieController.calorieList[i].amount;
        } else {
          subIntake = calorieController.calorieList[i].amount;
        }
      }

      // 마지막 index 면 다음 일로 넘어가지 않기 때문에 그냥 넣어주기
      if (i == calorieController.calorieList.length - 1) {
        int lastIndex = feedIntakeListForWeek.length - 1;

        feedIntakeListForWeek[lastIndex].main = mainIntake.round();
        feedIntakeListForWeek[lastIndex].sub = subIntake.round();
        feedIntakeListForWeek[lastIndex].total = feedIntakeListForWeek[lastIndex].main + feedIntakeListForWeek[lastIndex].sub;
      }
    }
  }

  // 물 데이터 세팅 (주, 월 그래프)
  void setWaterDataForWeek() {
    double mainIntake = 0.0; // 섭취량
    double subIntake = 0.0; // 섭취량
    DateTime preDate = firstWaterDate; // 이전 일자

    waterIntakeListForWeek = List.generate(waterTotalDifferDays + 1, (index) => GraphData());

    for (int i = 0; i < waterController.waterList.length; i++) {
      if (i > 0) preDate = DateTime(waterController.waterList[i - 1].time.year, waterController.waterList[i - 1].time.month, waterController.waterList[i - 1].time.day); // 하나 전 데이터

      // 전 데이터와 같은 날이면
      if (waterController.waterList[i].time.year == preDate.year && waterController.waterList[i].time.month == preDate.month && waterController.waterList[i].time.day == preDate.day) {
        if (waterController.waterList[i].type == INTAKE_MAIN) {
          mainIntake += waterController.waterList[i].amount; // 섭취량 더해주기
        } else {
          subIntake += waterController.waterList[i].amount; // 섭취량 더해주기
        }
      } else {
        int idx = firstWaterDate.difference(preDate).inDays; // 첫 번째 데이터와 전 데이터의 차이로 index 구하기

        // 데이터 삽입
        waterIntakeListForWeek[idx].main = mainIntake.round();
        waterIntakeListForWeek[idx].sub = subIntake.round();
        waterIntakeListForWeek[idx].total = waterIntakeListForWeek[idx].main + waterIntakeListForWeek[idx].sub;

        // 초기화
        mainIntake = 0;
        subIntake = 0;

        // 처음부터 다시 더하기
        if (waterController.waterList[i].type == INTAKE_MAIN) {
          mainIntake = waterController.waterList[i].amount;
        } else {
          subIntake = waterController.waterList[i].amount;
        }
      }

      // 마지막 index 면 다음 일로 넘어가지 않기 때문에 그냥 넣어주기
      if (i == waterController.waterList.length - 1) {
        int lastIndex = waterIntakeListForWeek.length - 1;

        waterIntakeListForWeek[lastIndex].main = mainIntake.round();
        waterIntakeListForWeek[lastIndex].sub = subIntake.round();
        waterIntakeListForWeek[lastIndex].total = waterIntakeListForWeek[lastIndex].main + waterIntakeListForWeek[lastIndex].sub;
      }
    }
  }

  // 사료 데이터 세팅 (년 그래프)
  void setFeedDataForYear() {
    Jiffy firstMonth = Jiffy(DateTime(firstFeedDate.year, firstFeedDate.month)); // 처음 데이터의 dateTime
    int totalDifferMonth = firstMonth.diff(DateTime(lastFeedDate.year, lastFeedDate.month), Units.MONTH).toInt(); // 첫 달과 마지막 달 개월 수 차이
    double mainIntake = 0.0; // 섭취량
    double subIntake = 0.0; // 섭취량
    DateTime preDate = firstMonth.dateTime; // 이전 데이터의 date
    List<DateTime> mainCountList = []; // 달에 먹은 횟수 체크를 위한 리스트

    feedIntakeListForYear = List.generate(totalDifferMonth + 1, (index) => GraphData()); // 몇 개의 월 보여줄지 세팅

    for (int i = 0; i < calorieController.calorieList.length; i++) {
      // 현재 데이터 dateTime (년, 월, 일)
      DateTime currentDataDate = DateTime(calorieController.calorieList[i].time.year, calorieController.calorieList[i].time.month, calorieController.calorieList[i].time.day);

      if (i > 0) preDate = DateTime(calorieController.calorieList[i - 1].time.year, calorieController.calorieList[i - 1].time.month); // 이전 데이터의 date

      // 오늘 먹은양 빼고
      if(now.difference(currentDataDate).inDays > 0) {
        // 같은 해, 같은 달이면 먹은양 더해주기
        if (calorieController.calorieList[i].time.year == preDate.year && calorieController.calorieList[i].time.month == preDate.month) {
          if (calorieController.calorieList[i].type == INTAKE_MAIN) {
            mainIntake += calorieController.calorieList[i].amount;
          } else {
            subIntake += calorieController.calorieList[i].amount;
          }

          // 먹은 양이 있고 리스트에 포함되어있지 않을 때
          if(calorieController.calorieList[i].amount > 0 && !mainCountList.contains(currentDataDate)) {
            mainCountList.add(currentDataDate);
          }
        } else {
          int differMonth = firstMonth.diff(preDate, Units.MONTH).toInt(); // 이전 데이터와 처음 데이터의 월 차이

          // 한 번도 먹지 않았을 때는 length 1로
          if(mainCountList.isEmpty) mainCountList.add(now);

          // 한 달 총 먹은양 / 한 달 먹은 횟수
          double _tmpTotal = mainIntake + subIntake;
          feedIntakeListForYear[differMonth].total = (_tmpTotal / mainCountList.length).round();
          feedIntakeListForYear[differMonth].main = _tmpTotal != 0 ? (mainIntake / _tmpTotal * feedIntakeListForYear[differMonth].total).round() : 0;
          feedIntakeListForYear[differMonth].sub = _tmpTotal != 0 ? (subIntake / _tmpTotal * feedIntakeListForYear[differMonth].total).round() : 0;

          // 초기화
          mainIntake = 0;
          subIntake = 0;
          mainCountList.clear();

          // 처음부터 다시 더하기
          if (calorieController.calorieList[i].type == INTAKE_MAIN) {
            mainIntake = calorieController.calorieList[i].amount;
          } else {
            subIntake = calorieController.calorieList[i].amount;
          }

          // 먹은 양이 있고 리스트에 포함되어있지 않을 때
          if(calorieController.calorieList[i].amount > 0 && !mainCountList.contains(currentDataDate)) {
            mainCountList.add(currentDataDate);
          }
        }

        // 마지막 index 면 다음 월로 넘어가지 않기 때문에 그냥 넣어주기
        if (i == calorieController.calorieList.length - 1) {

          // 한 번도 먹지 않았을 때는 length 1로
          if(mainCountList.isEmpty) mainCountList.add(now);

          // 한 달 총 먹은양 / 한 달 먹은 횟수
          double _tmpTotal = mainIntake + subIntake;
          feedIntakeListForYear.last.total = (_tmpTotal / mainCountList.length).round();
          feedIntakeListForYear.last.main = _tmpTotal != 0 ? (mainIntake / _tmpTotal * feedIntakeListForYear.last.total).round() : 0;
          feedIntakeListForYear.last.sub = _tmpTotal != 0 ? (subIntake / _tmpTotal * feedIntakeListForYear.last.total).round() : 0;
        }
      }

    }
  }

  // 물 데이터 세팅 (년 그래프)
  void setWaterDataForYear() {
    Jiffy firstMonth = Jiffy(DateTime(firstWaterDate.year, firstWaterDate.month)); // 처음 데이터의 dateTime
    int totalDifferMonth = firstMonth.diff(DateTime(lastWaterDate.year, lastWaterDate.month), Units.MONTH).toInt(); // 첫 달과 마지막 달 개월 수 차이
    double mainIntake = 0.0; // 섭취량
    double subIntake = 0.0; // 섭취량
    DateTime preDate = firstMonth.dateTime; // 이전 데이터의 date
    List<DateTime> mainCountList = []; // 달에 먹은 횟수 체크를 위한 리스트

    waterIntakeListForYear = List.generate(totalDifferMonth + 1, (index) => GraphData()); // 몇 개의 월 보여줄지 세팅

    for (int i = 0; i < waterController.waterList.length; i++) {
      // 현재 데이터 dateTime (년, 월, 일)
      DateTime currentDataDate = DateTime(waterController.waterList[i].time.year, waterController.waterList[i].time.month, waterController.waterList[i].time.day);

      if (i > 0) preDate = DateTime(waterController.waterList[i - 1].time.year, waterController.waterList[i - 1].time.month); // 이전 데이터의 date

      // 오늘 먹은양 빼고
      if(now.difference(currentDataDate).inDays > 0) {
        // 같은 해, 같은 달이면 먹은양 더해주기
        if (waterController.waterList[i].time.year == preDate.year && waterController.waterList[i].time.month == preDate.month) {
          if (waterController.waterList[i].type == INTAKE_MAIN) {
            mainIntake += waterController.waterList[i].amount;
          } else {
            subIntake += waterController.waterList[i].amount;
          }

          // 먹은 양이 있고 리스트에 포함되어있지 않을 때
          if(waterController.waterList[i].amount > 0 && !mainCountList.contains(currentDataDate)) {
            mainCountList.add(currentDataDate);
          }
        } else {
          int differMonth = firstMonth.diff(preDate, Units.MONTH).toInt(); // 이전 데이터와 처음 데이터의 월 차이

          // 한 번도 먹지 않았을 때는 length 1로
          if(mainCountList.isEmpty) mainCountList.add(now);

          // 한 달 총 먹은양 / 한 달 먹은 횟수
          double _tmpTotal = mainIntake + subIntake;
          waterIntakeListForYear[differMonth].total = (_tmpTotal / mainCountList.length).round();
          waterIntakeListForYear[differMonth].main = _tmpTotal != 0 ? (mainIntake / _tmpTotal * waterIntakeListForYear[differMonth].total).round() : 0;
          waterIntakeListForYear[differMonth].sub = _tmpTotal != 0 ? (subIntake / _tmpTotal * waterIntakeListForYear[differMonth].total).round() : 0;

          // 초기화
          mainIntake = 0;
          subIntake = 0;
          mainCountList.clear();

          // 처음부터 다시 더하기
          if (waterController.waterList[i].type == INTAKE_MAIN) {
            mainIntake = waterController.waterList[i].amount;
          } else {
            subIntake = waterController.waterList[i].amount;
          }

          // 먹은 양이 있고 리스트에 포함되어있지 않을 때
          if(waterController.waterList[i].amount > 0 && !mainCountList.contains(currentDataDate)) {
            mainCountList.add(currentDataDate);
          }
        }

        // 마지막 index 면 다음 월로 넘어가지 않기 때문에 그냥 넣어주기
        if (i == waterController.waterList.length - 1) {

          // 한 번도 먹지 않았을 때는 length 1로
          if(mainCountList.isEmpty) mainCountList.add(now);

          // 한 달 총 먹은양 / 한 달 먹은 횟수
          double _tmpTotal = mainIntake + subIntake;
          waterIntakeListForYear.last.total = (_tmpTotal / mainCountList.length).round();
          waterIntakeListForYear.last.main = _tmpTotal != 0 ? (mainIntake / _tmpTotal * waterIntakeListForYear.last.total).round() : 0;
          waterIntakeListForYear.last.sub = _tmpTotal != 0 ? (subIntake / _tmpTotal * waterIntakeListForYear.last.total).round() : 0;
        }
      }

    }
  }

  // state update 용도
  void stateUpdate() {
    update();
  }

  void initScroll(ItemScrollController itemScrollController) {
    itemScrollController.jumpTo(index: 0);
  }

  // 화면에 따른 그래프 처리 (일)
  Map<String, dynamic> listenableFuncForDay({required List<GraphData> intakeList, required int start, required int end}) {
    DateTime endDate = now;
    String startTime = '';
    String endTime = '';
    int intake = 0;
    int maxIntake = 0; // intake 최대값
    int selectedIndex = 0; // 선택된 index

    endDate = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt(), 23).subtract(Duration(hours: start - 3));

    // 오늘 날짜보다 크면 오늘 23시로 고정
    if(DateTime(now.year, now.month, now.day).difference(endDate).inDays < 0) {
      endDate = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt(), 23);
    }

    startTime = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt(), 24).subtract(Duration(hours: end - 3)).toString().substring(0, 13).replaceAll('-', '.');
    endTime = endDate.toString().substring(0, 13).replaceAll('-', '.');

    // 섭취량 계산
    if(intakeList.isNotEmpty){
      for (int i = 0; i < end - start; i++) {
        int num = (start - 3) + i;

        if (num >= 0) {
          intake += intakeList[num].total; // 섭취량 더하기

          // 섭취량 최대 값 최신화
          if (maxIntake <= intakeList[num].total) {
            if (intakeList[num].total > 100) {
              maxIntake = calMaxIntake(intakeList[num].total);
            } else {
              maxIntake = 100;
            }
          }
        }
      }

      // 말풍선으로 그램 수 나오는거
      selectedIndex = start + 4;

      // start 기반으로 index 계산
      int idx2 = selectedIndex - 4 > intakeList.length - 1 ? intakeList.length - 1 : selectedIndex - 4;

      if (intakeList[idx2].total == 0) {
        for (int i = 0; i < end - start; i++) {
          if(idx2 + i > intakeList.length - 1) {
            selectedIndex = intakeList.length - 1;
            break;
          } else if (intakeList[idx2 + i].total > 0) {
            selectedIndex += i;
            break;
          }
        }
      }
    }

    return {
      'startTime': startTime,
      'endTime': endTime,
      'intake': intake,
      'maxIntake': maxIntake,
      'selectedIndex': selectedIndex,
    };
  }

  // 화면에 따른 그래프 처리 (주)
  Map<String, dynamic> listenableFuncForWeek({required List<GraphData> intakeList, required int start, required int end}) {
    String startTime = '';
    String endTime = '';
    int intake = 0;
    int maxIntake = 0; // intake 최대값
    int selectedIndex = 0; // 선택된 index
    int haveCalorieDataCount = 0; // 칼로리를 가지고 있는 데이터의 수

    startTime = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt()).subtract(Duration(days: end - 1)).toString().substring(0, 10).replaceAll('-', '.');
    endTime = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt()).subtract(Duration(days: start)).toString().substring(0, 10).replaceAll('-', '.');

    // 섭취량 계산
    if(intakeList.isNotEmpty) {
      for (int i = 0; i < end - start; i++) {
        // 오늘 섭취한 칼로리가 아니고, 칼로리가 0이 아닐경우
        if (start + i != 0 && intakeList[start + i].total > 0) {
          intake += intakeList[start + i].total;
          haveCalorieDataCount++;
        }

        // 섭취량 최대 값 최신화
        if (maxIntake <= intakeList[start + i].total) {
          if (intakeList[start + i].total > 100) {
            maxIntake = calMaxIntake(intakeList[start + i].total);
          } else {
            maxIntake = 100;
          }
        }
      }

      if (haveCalorieDataCount == 0) haveCalorieDataCount = 1;
      intake = (intake / haveCalorieDataCount).round();

      // 말풍선으로 그램 수 나오는거
      selectedIndex = start + 1;

      if (intakeList[selectedIndex - 1].total == 0) {
        for (int i = 0; i < end - start; i++) {
          if (intakeList[(selectedIndex - 1) + i].total > 0) {
            selectedIndex += i;
            break;
          }
        }
      }
    }

    return {
      'startTime': startTime,
      'endTime': endTime,
      'intake': intake,
      'maxIntake': maxIntake,
      'selectedIndex': selectedIndex,
    };
  }

  // 화면에 따른 그래프 처리 (월)
  Map<String, dynamic> listenableFuncForMonth({required List<GraphData> intakeList, required int start, required int end}) {
    DateTime endDate = now;
    String startTime = '';
    String endTime = '';
    int intake = 0;
    int maxIntake = 0; // intake 최대값
    int selectedIndex = 0; // 선택된 index
    int haveCalorieDataCount = 0; // 칼로리를 가지고 있는 데이터의 수

    endDate = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt(), 23).subtract(Duration(days: start - 3));

    // 오늘 날짜보다 크면 오늘로 고정
    if (now.difference(endDate).inDays < 0) {
      endDate = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt());
    }

    startTime = DateTime(now.year.toInt(), now.month.toInt(), now.day.toInt()).subtract(Duration(days: end - 4)).toString().substring(0, 10).replaceAll('-', '.');
    endTime = endDate.toString().substring(0, 10).replaceAll('-', '.');

    // 섭취량 계산
    if(intakeList.isNotEmpty) {
      for (int i = 0; i < end - start; i++) {
        int idx = (start - 3) + i;

        if (idx >= 0) {
          // 오늘 섭취한 칼로리가 아니고, 칼로리가 0이 아닐 경우
          if (idx > 0 && intakeList[idx].total > 0) {
            intake += intakeList[idx].total; // 섭취량 더하기
            haveCalorieDataCount++;
          }

          // 섭취량 최대 값 최신화
          if (maxIntake <= intakeList[idx].total) {
            if (intakeList[idx].total > 100) {
              maxIntake = calMaxIntake(intakeList[idx].total);
            } else {
              maxIntake = 100;
            }
          }
        }
      }

      if (haveCalorieDataCount == 0) haveCalorieDataCount = 1;
      intake = (intake / haveCalorieDataCount).round(); // 섭취량 일 수로 나누기

      // 말풍선으로 그램 수 나오는거
      selectedIndex = start + 4;

      // start 기반으로 index 계산
      int idx2 = selectedIndex - 4 > intakeList.length - 1 ? intakeList.length - 1 : selectedIndex - 4;

      // 선택된 인덱스 값이 0 이면 다음으로 넘기기
      if (intakeList[idx2].total == 0) {
        for (int i = 0; i < end - start; i++) {
          int _num = idx2 + i >= intakeList.length ? intakeList.length - 1 : idx2 + i;

          if (intakeList[_num].total > 0) {
            selectedIndex += i;
            break;
          }
        }
      }
    }

    return {
      'startTime': startTime,
      'endTime': endTime,
      'intake': intake,
      'maxIntake': maxIntake,
      'selectedIndex': selectedIndex,
    };
  }

  // 화면에 따른 그래프 처리 (년)
  Map<String, dynamic> listenableFuncForYear({required List<GraphData> intakeList, required int start, required int end}) {
    String startTime = '';
    String endTime = '';
    int intake = 0;
    int maxIntake = 0; // intake 최대값
    int selectedIndex = 0; // 선택된 index
    int haveCalorieDataCount = 0; // 칼로리를 가지고 있는 데이터의 수

    DateTime startDate = Jiffy(now).subtract(months: end - 1).dateTime; // 화면 가장 왼쪽에 있는 달
    DateTime endDate = Jiffy(now).subtract(months: start).dateTime; // 화면 가장 오른쪽에 있는 달

    startTime = startDate.toString().substring(0, 7).replaceAll('-', '.');
    endTime = endDate.toString().substring(0, 7).replaceAll('-', '.');

    // 섭취량 계산
    if(intakeList.isNotEmpty) {
      for (int i = 0; i < end - start; i++) {
        if (intakeList[start + i].total > 0) {
          intake += intakeList[start + i].total;
          haveCalorieDataCount++;
        }

        // 섭취량 최대 값 최신화
        if (maxIntake <= intakeList[start + i].total) {
          if (intakeList[start + i].total > 100) {
            maxIntake = calMaxIntake(intakeList[start + i].total);
          } else {
            maxIntake = 100;
          }
        }
      }

      if (haveCalorieDataCount == 0) haveCalorieDataCount = 1;
      intake = (intake / haveCalorieDataCount).round(); // 일일 평균 구하기

      // 말풍선으로 그램 수 나오는거
      selectedIndex = start + 1;

      if (intakeList[selectedIndex - 1].total == 0) {
        for (int i = 0; i < end - start; i++) {
          if (intakeList[(selectedIndex - 1) + i].total > 0) {
            selectedIndex += i;
            break;
          }
        }
      }
    }

    return {
      'startTime': startTime,
      'endTime': endTime,
      'intake': intake,
      'maxIntake': maxIntake,
      'selectedIndex': selectedIndex,
    };
  }

  // y축 보조선 최대 값 계산 함수
  int calMaxIntake(int intakeAmount) {
    int result = 0;

    int interval = yInterval(intakeAmount); // 최고 칼로리양에 따라 보조선 간격 정하기

    result = (intakeAmount + 10) ~/ 10 * 10; // 1의 자리에서 올림

    while (result % interval != 0) {
      result += 10;
    }

    return result;
  }

  // 칼로리양에 따라 보조선 간격 정하기
  int yInterval(int intakeAmount) {
    int result = 0;

    if (intakeAmount <= 200) {
      result = 20;
    } else if (intakeAmount <= 450) {
      result = 50;
    } else {
      result = (intakeAmount ~/ 9 + 100) ~/ 100 * 100; // 보조선 갯수만큼 나눈 뒤 10의 자리에서 올림
    }

    return result;
  }

  bool get isShortPhone => Get.height < 700;

  // 그래프 페이지 컨트롤러 변수 초기화
  void reset() {
    barIndex = 0.obs;
    periodIndex = 0.obs; //0 일, 1 주, 2 월, 3 년

    feedIntakeListForDay = []; // 사료 섭취량 리스트 (일)
    feedIntakeListForWeek = []; // 사료 섭취량 리스트 (주, 월)
    feedIntakeListForYear = []; // 사료 섭취량 리스트 (년)

    waterIntakeListForDay = []; // 물 음수량 리스트 (일)
    waterIntakeListForWeek = []; // 물 음수량 리스트 (주, 월)
    waterIntakeListForYear = []; // 물 음수량 리스트 (년)

    now = DateTime.now();

    firstFeedDate = DateTime.now(); // 첫번째 데이터의 date
    lastFeedDate = DateTime.now(); // 마지막 데이터의 date

    firstWaterDate = DateTime.now(); // 첫번째 데이터의 date
    lastWaterDate = DateTime.now(); // 마지막 데이터의 date

    feedTotalDifferDays = 0; // 마지막 데이터와 첫번째 데이터의 일수 차이
    waterTotalDifferDays = 0; // 마지막 데이터와 첫번째 데이터의 일수 차이

    isLoading = false; // 로딩 여부
  }
}
