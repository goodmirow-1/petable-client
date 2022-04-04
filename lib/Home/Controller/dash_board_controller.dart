import 'dart:convert';

import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/intake_database.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:myvef_app/intake/model/intake.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:intl/intl.dart';
import 'package:myvef_app/intake/model/water.dart';

enum GRAPH_STATUS { ACHIEVEMENT_RATE, CURRENT_INTAKE, INTAKE_COUNT } // 달성률, 현재 섭취량, 현재 섭취 횟수

enum ADMINISTRATIVE_DIVISION { COUNTRY, DO_SI, EUP_MYEON_DONG } // 나라 > 도/특별시/광역시 > 시/군/구/읍/면/동

class DashBoardController extends GetxController {
  static get to => Get.find<DashBoardController>();
  final DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  RxInt profileIndex = 0.obs; // 프로필 이미지 인덱스
  Rx<GRAPH_STATUS> graphStatus = GRAPH_STATUS.ACHIEVEMENT_RATE.obs; // 그래프 상태
  Rx<ADMINISTRATIVE_DIVISION> administrativeDivision = ADMINISTRATIVE_DIVISION.EUP_MYEON_DONG.obs; // 행정구역 상태

  RxInt healthScoreGuideLevel = 1.obs; // 가이드 단계
  RxInt feedDiaryGuideLevel = 1.obs; // 가이드 단계
  RxInt petKindInfoGuideLevel = 1.obs; // 가이드 단계

  RxDouble todayWaterIntake = 0.0.obs; // 오늘 먹은 물 양 (ml)
  RxDouble todayKcalIntake = 0.0.obs; // 오늘 섭취한 칼로리 (kcal)
  double todayGramIntake = 0.0; // 오늘 섭취한 사료 양 (g)

  RxDouble yesterdayWaterIntake = 0.0.obs; // 어제 먹은 물 양 (ml)
  RxDouble yesterdayCalIntake = 0.0.obs; // 어제 섭취한 칼로리 (kcal)

  RxString healthLocation = ''.obs; // 유저 행정 구역
  RxDouble healthFeedScore = 0.0.obs; // 건강점수 섭취 점수
  RxDouble healthFeedRatio = 0.0.obs; // 건강점수 섭취 ratio
  RxDouble healthWaterScore = 0.0.obs; // 건강점수 수분 점수
  RxDouble healthWaterRatio = 0.0.obs; // 건강점수 수분 ratio
  RxDouble healthWeightRatio = 0.0.obs; // 건강점수 ratio

  int todayFeedIntakeCount = 0; // 오늘 사료 먹은 횟수
  int todayWaterIntakeCount = 0; // 오늘 물 먹은 횟수

  String todayFeedFillTime = '-'; // 오늘 배급 시간

  // 오늘 섭취한 사료 (g)
  Future<void> getTodayFeedIntake() async {
    todayGramIntake = 0.0; // 오늘 먹은 사료 양 초기화
    List<Intake> _intakeList = await IntakeDBHelper().getTodayFeedIntakeList(now); // 오늘 먹은 사료 가져오기 (g)

    //최신 섭취정보부터 다먹은 상태 이전값과 비교하여 먹은 양을 오늘 섭취량에 누적. 마지막 인덱스는 이전이 없기때문에 검사하지 않음.
    for (int i = 0; i < _intakeList.length - 1; i++) {
      if (_intakeList[i].state == INTAKE_STATE_END) {
        todayGramIntake += _intakeList[i + 1].weight - _intakeList[i].weight;
      }
    }

    setTopPercent(); // 건강 점수 퍼센트 세팅
  }

  // 오늘 섭취한 칼로리 (kcal)
  void calTodayCalorie() {
    final CalorieController calorieController = Get.find<CalorieController>();

    todayKcalIntake(0.0); // 오늘 먹은 양 초기화
    todayFeedIntakeCount = 0; // 사료 먹은 횟수 초기화

    for (int i = 0; i < calorieController.calorieList.length; i++) {
      DateTime waterDate = DateTime(calorieController.calorieList[i].time.year, calorieController.calorieList[i].time.month, calorieController.calorieList[i].time.day);

      if (now.difference(waterDate).inDays == 0) {
        todayKcalIntake.value += calorieController.calorieList[i].amount.round(); // 오늘 먹은 양
        todayFeedIntakeCount++; // 사료, 간식 먹은 횟수
      } else {
        break;
      }
    }
  }

  // 오늘 섭취한 물 (ml)
  void calTodayWater() {
    final WaterController waterController = Get.find<WaterController>();

    todayWaterIntake(0.0); // 오늘 먹은 양 초기화
    todayWaterIntakeCount = 0; // 물 마신 횟수 초기화

    for (int i = 0; i < waterController.waterList.length; i++) {
      DateTime waterDate = DateTime(waterController.waterList[i].time.year, waterController.waterList[i].time.month, waterController.waterList[i].time.day);

      if (now.difference(waterDate).inDays == 0) {
        todayWaterIntake.value += waterController.waterList[i].amount.round(); // 오늘 먹은 양

        // 물 마신 횟수 (보조적으로 얻은 물은 제외)
        if (waterController.waterList[i].type == WATER_TYPE_DRINK) {
          todayWaterIntakeCount++;
        }
      } else {
        break;
      }
    }
  }

  // 오늘 배급 시간
  Future<void> getTodayFillFeed() async {
    var res = await ApiProvider().post(
        '/Pet/Select/TodayFillIntake',
        jsonEncode({
          'petID': GlobalData.mainPet.value.id,
        }));

    if (res != null) {
      Intake _intake = Intake.fromJson(res);

      int _hour = int.parse(_intake.createdAt[11] + _intake.createdAt[12]);
      int _minute = int.parse(_intake.createdAt[14] + _intake.createdAt[15]);

      final _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _hour, _minute);
      todayFeedFillTime = DateFormat('HH:mm').format(_date);
    } else {
      todayFeedFillTime = '-';
    }
  }

  // 어제 섭취한 칼로리 (kcal)
  void calYesterdayCalorie() {
    final CalorieController calorieController = Get.find<CalorieController>();

    yesterdayCalIntake(0.0); // 어제 먹은 양 초기화

    for (int i = 0; i < calorieController.calorieList.length; i++) {
      DateTime waterDate = DateTime(calorieController.calorieList[i].time.year, calorieController.calorieList[i].time.month, calorieController.calorieList[i].time.day);

      if (now.difference(waterDate).inDays == 1) {
        yesterdayCalIntake.value += calorieController.calorieList[i].amount.round();
      } else if (now.difference(waterDate).inDays == 2) {
        break;
      }
    }
  }

  // 어제 섭취한 물 (ml)
  void calYesterdayWater() {
    final WaterController waterController = Get.find<WaterController>();

    yesterdayWaterIntake(0.0); //어제 먹은 양 초기화

    for (int i = 0; i < waterController.waterList.length; i++) {
      DateTime foodDate = DateTime(waterController.waterList[i].time.year, waterController.waterList[i].time.month, waterController.waterList[i].time.day);

      if (now.difference(foodDate).inDays == 1) {
        yesterdayWaterIntake.value += waterController.waterList[i].amount.round();
      } else if (now.difference(foodDate).inDays == 2) {
        break;
      }
    }
  }

  // 그래프 상태 변경
  void changeGraphStatus() {
    switch (graphStatus.value) {
      case GRAPH_STATUS.ACHIEVEMENT_RATE:
        graphStatus(GRAPH_STATUS.CURRENT_INTAKE);
        break;
      case GRAPH_STATUS.CURRENT_INTAKE:
        graphStatus(GRAPH_STATUS.INTAKE_COUNT);
        break;
      case GRAPH_STATUS.INTAKE_COUNT:
        graphStatus(GRAPH_STATUS.ACHIEVEMENT_RATE);
        break;
    }
  }

  // 건강 점수 상태 변경
  void changeHealthScoreGraph() {
    setTopPercent(); // 건강 점수 퍼센트 세팅

    switch (administrativeDivision.value) {
      case ADMINISTRATIVE_DIVISION.EUP_MYEON_DONG:
        healthLocation(GlobalData.loggedInUser.value.si); // 행정 구역 변경
        administrativeDivision(ADMINISTRATIVE_DIVISION.DO_SI); // 행정 구역 상태 변경
        break;
      case ADMINISTRATIVE_DIVISION.DO_SI:
        healthLocation('대한민국'); // 행정 구역 변경
        administrativeDivision(ADMINISTRATIVE_DIVISION.COUNTRY); // 행정 구역 상태 변경
        break;
      case ADMINISTRATIVE_DIVISION.COUNTRY:
        healthLocation(GlobalData.loggedInUser.value.dong); // 행정 구역 변경
        administrativeDivision(ADMINISTRATIVE_DIVISION.EUP_MYEON_DONG); // 행정 구역 상태 변경
        break;
    }
  }

  // 건강 점수 퍼센트 세팅
  void setTopPercent() {
    double foodAverage = 0.0;
    double foodStandardDeviation = 0.0;

    double waterAverage = 0.0;
    double waterStandardDeviation = 0.0;

    double dogWeightAverage = 0.0;
    double dogWeightStandardDeviation = 0.0;

    double catWeightAverage = 0.0;
    double catWeightStandardDeviation = 0.0;

    switch (administrativeDivision.value) {
      case ADMINISTRATIVE_DIVISION.EUP_MYEON_DONG:
        foodAverage = GlobalData.dongStandardDeviation.foodAverage;
        foodStandardDeviation = GlobalData.dongStandardDeviation.foodStandardDeviation;

        waterAverage = GlobalData.dongStandardDeviation.waterAverage;
        waterStandardDeviation = GlobalData.dongStandardDeviation.waterStandardDeviation;

        dogWeightAverage = GlobalData.dongStandardDeviation.dogWeightAverage;
        dogWeightStandardDeviation = GlobalData.dongStandardDeviation.dogWeightStandardDeviation;

        catWeightAverage = GlobalData.dongStandardDeviation.catWeightAverage;
        catWeightStandardDeviation = GlobalData.dongStandardDeviation.catWeightStandardDeviation;
        break;

      case ADMINISTRATIVE_DIVISION.DO_SI:
        foodAverage = GlobalData.siStandardDeviation.foodAverage;
        foodStandardDeviation = GlobalData.siStandardDeviation.foodStandardDeviation;

        waterAverage = GlobalData.siStandardDeviation.waterAverage;
        waterStandardDeviation = GlobalData.siStandardDeviation.waterStandardDeviation;

        dogWeightAverage = GlobalData.siStandardDeviation.dogWeightAverage;
        dogWeightStandardDeviation = GlobalData.siStandardDeviation.dogWeightStandardDeviation;

        catWeightAverage = GlobalData.siStandardDeviation.catWeightAverage;
        catWeightStandardDeviation = GlobalData.siStandardDeviation.catWeightStandardDeviation;
        break;

      case ADMINISTRATIVE_DIVISION.COUNTRY:
        foodAverage = GlobalData.countryStandardDeviation.foodAverage;
        foodStandardDeviation = GlobalData.countryStandardDeviation.foodStandardDeviation;

        waterAverage = GlobalData.countryStandardDeviation.waterAverage;
        waterStandardDeviation = GlobalData.countryStandardDeviation.waterStandardDeviation;

        dogWeightAverage = GlobalData.countryStandardDeviation.dogWeightAverage;
        dogWeightStandardDeviation = GlobalData.countryStandardDeviation.dogWeightStandardDeviation;

        catWeightAverage = GlobalData.countryStandardDeviation.catWeightAverage;
        catWeightStandardDeviation = GlobalData.countryStandardDeviation.catWeightStandardDeviation;
        break;
    }

    //건강 점수 사료 점수
    healthFeedScore(convertScore(yesterdayCalIntake.value / GlobalData.mainPet.value.foodRecommendedIntake));

    // 건강점수 사료 ratio
    healthFeedRatio(
      1.0 -
          topPercent(
            healthFeedScore.value,
            foodAverage,
            foodStandardDeviation,
          ),
    );

    //건강점수 수분 점수
    healthWaterScore(convertScore(yesterdayWaterIntake.value / GlobalData.mainPet.value.waterRecommendedIntake));

    // 건강점수 물 ratio
    healthWaterRatio(
      1.0 -
          topPercent(
            healthWaterScore.value,
            waterAverage,
            waterStandardDeviation,
          ),
    );

    var average = GlobalData.mainPet.value.type == 0 ? dogWeightAverage : catWeightAverage;
    var standardDeviation = GlobalData.mainPet.value.type == 0 ? dogWeightStandardDeviation : catWeightStandardDeviation;

    // 건강점수 몸무게
    healthWeightRatio(
      1.0 -
          topPercent(
            GlobalData.mainPet.value.weight,
            average,
            standardDeviation,
          ),
    );
  }

  // 냠냠일지 영양상태 텍스트
  String feedDiaryNutritionText() {
    String content = '-';

    // 그릇이 있을 때 권장량 대비 먹은 양으로 content 가공
    if (BowlPageController.to.isHaveFoodBowl.value) {
      double foodRatio = yesterdayCalIntake.value / GlobalData.mainPet.value.foodRecommendedIntake;

      if (foodRatio < 0.5) content = '매우\n부족';
      else if (0.5 <= foodRatio && foodRatio < 0.7) content = '부족';
      else if (0.7 <= foodRatio && foodRatio < 0.9) content = '다소\n부족';
      else if (1.1 < foodRatio && foodRatio <= 1.3) content = '다소\n과다';
      else if (1.3 < foodRatio && foodRatio <= 1.5) content = '과다';
      else if (1.5 < foodRatio) content = '매우\n과다';
      else content = '양호';
    }

    return content;
  }

  // 냠냠일지 수분보충 텍스트
  String feedDiaryWaterText() {
    String content = '-';

    // 그릇이 있을 때 권장량 대비 먹은 양으로 content 가공
    if (BowlPageController.to.isHaveWaterBowl.value) {
      double waterRatio = yesterdayWaterIntake.value / GlobalData.mainPet.value.waterRecommendedIntake;

      if (waterRatio < 0.5) content = '매우\n부족';
      else if (0.5 <= waterRatio && waterRatio < 0.7) content = '부족';
      else if (0.7 <= waterRatio && waterRatio < 0.9) content = '다소\n부족';
      else if (1.1 < waterRatio && waterRatio <= 1.3) content = '다소\n과다';
      else if (1.3 < waterRatio && waterRatio <= 1.5) content = '과다';
      else if (1.5 < waterRatio) content = '매우\n과다';
      else content = '양호';
    }

    return content;
  }

  void stateUpdate() {
    update();
  }

  // 대시보드 컨트롤 변수 초기화
  void reset() {
    profileIndex = 0.obs; // 프로필 이미지 인덱스
    graphStatus = GRAPH_STATUS.ACHIEVEMENT_RATE.obs; // 그래프 상태
    administrativeDivision = ADMINISTRATIVE_DIVISION.EUP_MYEON_DONG.obs; // 행정구역 상태

    healthScoreGuideLevel = 1.obs; // 가이드 단계
    feedDiaryGuideLevel = 1.obs; // 가이드 단계
    petKindInfoGuideLevel = 1.obs; // 가이드 단계

    todayWaterIntake = 0.0.obs; // 오늘 먹은 물 양 (ml)
    todayKcalIntake = 0.0.obs; // 오늘 섭취한 칼로리 (kcal)
    todayGramIntake = 0.0; // 오늘 섭취한 사료 양 (g)

    healthLocation = GlobalData.loggedInUser.value.dong.obs; // 유저 행정 구역
    healthFeedRatio = 0.0.obs; // 건강점수 ratio
    healthWaterRatio = 0.0.obs; // 건강점수 ratio
    healthWeightRatio = 0.0.obs; // 건강점수 ratio

    todayFeedIntakeCount = 0; // 오늘 사료 먹은 횟수
    todayWaterIntakeCount = 0; // 오늘 물 먹은 횟수

    todayFeedFillTime = '-'; // 오늘 배급 시간
  }
}
