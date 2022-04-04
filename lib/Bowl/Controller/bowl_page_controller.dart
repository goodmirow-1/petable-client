import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Model/bowl.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Bowl/resister_bowl_page.dart';
import 'package:myvef_app/intake/model/intake.dart';

class BowlPageController extends GetxController {
  static get to => Get.find<BowlPageController>();
  FoodBowlController foodBowlController = Get.put(FoodBowlController());
  WaterBowlController waterBowlController = Get.put(WaterBowlController());
  final PageController pageController = PageController();

  RxInt barIndex = 0.obs;

  RxString endDrawMenuState = '기기 등록하기'.obs;

  RxBool isHaveFoodBowl = false.obs;
  RxString foodWeightText = '0g'.obs;
  RxString foodText1 = ''.obs;
  RxString foodText2 = ''.obs;
  RxString foodText3 = ''.obs;
  RxDouble foodText2Width = (80 * sizeUnit).obs;
  RxDouble foodRatio = 0.05.obs;

  RxBool isHaveWaterBowl = false.obs;
  RxString waterVolumeText = '0mL'.obs;
  RxString waterText1 = ''.obs;
  RxString waterText2 = ''.obs;
  RxString waterText3 = ''.obs;
  RxDouble waterText2Width = (80 * sizeUnit).obs;
  RxDouble waterRatio = 0.05.obs;

  RxBool isOpenMenu = false.obs;

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  void updateFoodBowl() {
    if (foodBowlController.id == nullInt) {
      isHaveFoodBowl(false);
    } else {
      isHaveFoodBowl(true);
    }
    update();
  }

  Future<double> updateFoodData() async {
    if (foodBowlController.id == nullInt) {
      isHaveFoodBowl(false);

      return 0;
    } else {
      List<Intake> intakeList = [];
      List<Intake> recentIntake = [];

      double foodMaxWeight = 100;
      double foodWeight = 0;

      double recentIntakeWeight = 0;
      String recentIntakeTime = '';

      var tmpIntakes = await ApiProvider().post(
          '/Bowl/Select/Recent/Intake',
          jsonEncode({
            'petID': GlobalData.mainPet.value.id,
            'bowlType': foodBowlController.type,
          }));

      if (tmpIntakes is List) {
        //타입 1~3까지 여러 데이터는 리스트로 넘어옴
        for (int i = 0; i < tmpIntakes.length; i++) {
          intakeList.add(Intake.fromJson(tmpIntakes[i]));
        }
      } else {
        //방금 밥을 준 경우 타입1만 하나 넘어옴. 리스트 x
        if (tmpIntakes == false) {
          //밥을 준 적이 없음.
        } else {
          intakeList.add(Intake.fromJson(tmpIntakes));
        }
      }

      if (intakeList.length > 0) {
        if (intakeList[0].state == INTAKE_STATE_FEED) {
          foodMaxWeight = intakeList[0].weight;
          foodWeight = intakeList[0].weight;
          recentIntakeTime = intakeList[0].createdAt;
        }

        //최신 정보를 마지막으로 반영하기위해 역순으로 검색
        for (int i = intakeList.length - 1; i > 0; i--) {
          if (intakeList[i].state == INTAKE_STATE_END) {
            recentIntake.add(intakeList[i]);
            recentIntakeWeight = intakeList[i - 1].weight - intakeList[i].weight;
            foodWeight = intakeList[i].weight;
            recentIntakeTime = intakeList[i].createdAt;
            break;
          }
        }
      }

      //그릇 없는 상태인지 체크
      var tmpIntakeNoBowl = await ApiProvider().post(
          '/Bowl/Select/Recent/EmtpyBowl',
          jsonEncode({
            'petID': GlobalData.mainPet.value.id,
            'bowlType': foodBowlController.type,
          }));

      if(tmpIntakeNoBowl != null){
        Intake intakeNoBowl = Intake.fromJson(tmpIntakeNoBowl);

        if (intakeNoBowl.createdAt.compareTo(recentIntakeTime) > 0) {
          foodWeight = 0;
        }
      }

      if (intakeList.length == 0) {
        //섭취데이터가 없을 때
        foodWeightText('0g');
        foodRatio(0.05);

        foodText1('아이를 위해');
        foodText2('밥');
        foodText3('을 채워 주세요!');
        foodText2Width(25 * sizeUnit);

        return foodRatio.value;
      }

      int _foodWeight = foodWeight.round();
      if (_foodWeight < 0) _foodWeight = 0; //음수일 경우 처리

      foodWeightText(_foodWeight.toString() + 'g');
      foodRatio(foodWeight / foodMaxWeight < 0.05 ? 0.05 : foodWeight / foodMaxWeight);
      if (foodRatio.value >= 1) {
        foodText1('현재');
        foodText2('가득 차');
        foodText3('있어요!');
        foodText2Width(80 * sizeUnit);
      } else if (foodRatio.value > 0.05) {
        String tmp = replaceDate(recentIntakeTime);
        String time = timeCheck(tmp);
        if (time == '방금')
          foodText1(time);
        else
          foodText1('약 ' + time + '에');

        int amount = recentIntakeWeight.round();
        if (amount < 0) amount = 0; //음수일 경우 처리
        double tmpWidth = 40 * sizeUnit;
        if (amount >= 10) tmpWidth += 15 * sizeUnit;
        if (amount >= 100) tmpWidth += 15 * sizeUnit;
        foodText2(amount.toString() + 'g');
        foodText3('먹었어요!');
        foodText2Width(tmpWidth);
      } else {
        foodText1('아이를 위해');
        foodText2('밥');
        foodText3('을 채워 주세요!');
        foodText2Width(25 * sizeUnit);
      }
      isHaveFoodBowl(true);

      return foodRatio.value;
    }
  }

  void updateWaterBowl() {
    if (waterBowlController.id == nullInt) {
      isHaveWaterBowl(false);
    } else {
      isHaveWaterBowl(true);
    }
    update();
  }

  Future<double> updateWaterData() async {
    if (waterBowlController.id == nullInt) {
      isHaveWaterBowl(false);
      return 0;
    } else {
      List<Intake> intakeList = [];
      List<Intake> recentIntake = [];

      double waterMaxWeight = 100;
      double waterWeight = 0;

      double recentIntakeWeight = 0;
      String recentIntakeTime = '';

      var tmpIntakes = await ApiProvider().post(
          '/Bowl/Select/Recent/Intake',
          jsonEncode({
            'petID': GlobalData.mainPet.value.id,
            'bowlType': waterBowlController.type,
          }));

      if (tmpIntakes is List) {
        //타입 1~3까지 여러 데이터는 리스트로 넘어옴
        for (int i = 0; i < tmpIntakes.length; i++) {
          intakeList.add(Intake.fromJson(tmpIntakes[i]));
        }
      } else {
        //방금 밥을 준 경우 타입1만 하나 넘어옴. 리스트 x
        if (tmpIntakes == false) {
          //밥을 준 적이 없음.
        } else {
          intakeList.add(Intake.fromJson(tmpIntakes));
        }
      }

      if (intakeList.length > 0) {
        if (intakeList[0].state == INTAKE_STATE_FEED) {
          waterMaxWeight = intakeList[0].weight;
          waterWeight = intakeList[0].weight;
          recentIntakeTime = intakeList[0].createdAt;
        }

        for (int i = intakeList.length - 1; i > 0; i--) {
          if (intakeList[i].state == INTAKE_STATE_END) {
            recentIntake.add(intakeList[i]);
            recentIntakeWeight = intakeList[i - 1].weight - intakeList[i].weight;
            waterWeight = intakeList[i].weight;
            recentIntakeTime = intakeList[i].createdAt;
            break;
          }
        }
      }

      //그릇 없는 상태인지 체크
      var tmpIntakeNoBowl = await ApiProvider().post(
          '/Bowl/Select/Recent/EmtpyBowl',
          jsonEncode({
            'petID': GlobalData.mainPet.value.id,
            'bowlType': waterBowlController.type,
          }));

      if(tmpIntakeNoBowl != null){
        Intake intakeNoBowl = Intake.fromJson(tmpIntakeNoBowl);

        if (intakeNoBowl.createdAt.compareTo(recentIntakeTime) > 0) {
          waterWeight = 0;
        }
      }

      if (intakeList.length == 0) {
        //섭취데이터가 없을 때
        waterVolumeText('0mL');
        waterRatio(0.05);

        waterText1('아이를 위해');
        waterText2('물');
        waterText3('을 채워 주세요!');
        waterText2Width(25 * sizeUnit);

        return waterRatio.value;
      }

      int _waterWeight = waterWeight.round();
      if (_waterWeight < 0) _waterWeight = 0; //음수일 경우 처리

      waterVolumeText(_waterWeight.toString() + 'mL');
      waterRatio(waterWeight / waterMaxWeight < 0.05 ? 0.05 : waterWeight / waterMaxWeight);
      if (waterRatio.value >= 1) {
        waterText1('현재');
        waterText2('가득 차');
        waterText3('있어요!');
        waterText2Width(80 * sizeUnit);
      } else if (waterRatio.value > 0.05) {
        String tmp = replaceDate(recentIntakeTime);
        String time = timeCheck(tmp);
        if (time == '방금')
          waterText1(time);
        else
          waterText1('약 ' + time + '에');

        int amount = recentIntakeWeight.round();
        if (amount < 0) amount = 0; //음수일 경우 처리
        double tmpWidth = 55 * sizeUnit;
        if (amount >= 10) tmpWidth += 15 * sizeUnit;
        if (amount >= 100) tmpWidth += 15 * sizeUnit;
        waterText2(amount.toString() + 'mL');
        waterText3('마셨어요!');
        waterText2Width(tmpWidth);
      } else {
        waterText1('아이를 위해');
        waterText2('물');
        waterText3('을 채워 주세요!');
        waterText2Width(25 * sizeUnit);
      }
      isHaveWaterBowl(true);
      return waterRatio.value;
    }
  }

  void endDrawerFunc() {
    int _bowlType = barIndex.value;
    int state = 0; // 0 기기 없음. 1 기기 있음.
    int bowlID = nullInt;
    if (_bowlType == BOWL_TYPE_FOOD && isHaveFoodBowl.value) {
      state = 1;
      bowlID = GlobalData.mainPet.value.foodBowl!.id;
    } else if (_bowlType == BOWL_TYPE_WATER && isHaveWaterBowl.value) {
      state = 1;
      bowlID = GlobalData.mainPet.value.waterBowl!.id;
    }

    if (state == 0) {
      Get.back();
      //기기 등록 연결
      Get.to(() => ResisterBowlPage(type: _bowlType));
    } else if (state == 1) {
      //기기 해제 연결
      showVfDialog(
        title: '기기등록을\n해제하시겠어요?',
        colorType: vfGradationColorType.Red,
        description: '기기 등록을 해제하셔도\n기존 데이터는 삭제 되지않아요.',
        okFunc: () async {
          var res = await ApiProvider().post(
              '/Bowl/Disconnect/Pet',
              jsonEncode({
                'id': bowlID,
              }));
          if (res != null) {
            if (res) {
              //모든 보울 데이터 삭제
              if (_bowlType == BOWL_TYPE_FOOD) {
                foodBowlController.reset();
                GlobalData.mainPet.value.foodBowl = null;
                GlobalData.petList.forEach((pet) {
                  if (pet.id == GlobalData.mainPet.value.id) {
                    pet.foodBowl = null;
                  }
                });
                updateFoodBowl();
              } else if (_bowlType == BOWL_TYPE_WATER) {
                waterBowlController.reset();
                GlobalData.mainPet.value.waterBowl = null;
                GlobalData.petList.forEach((pet) {
                  if (pet.id == GlobalData.mainPet.value.id) {
                    pet.waterBowl = null;
                  }
                });
                updateWaterBowl();
              }
            }
          } else {
            //삭제 실패
            Get.snackbar('title', '기기등록 해제에 실패했어요!');
          }
          Get.back();
          Get.back();
        },
        isCancelButton: true,
      );
    }
  }

  //영점 조절하기
  void endDrawerFunc2() {
    int _bowlType = barIndex.value;
    int state = 0; // 0 기기 없음. 1 기기 있음.
    if (_bowlType == BOWL_TYPE_FOOD && isHaveFoodBowl.value) {
      state = 1;
    } else if (_bowlType == BOWL_TYPE_WATER && isHaveWaterBowl.value) {
      state = 1;
    }

    if (state == 0) {
      //기기가 없으면
      showVfDialog(
        title: '기기등록을\n먼저 진행해주세요.',
        colorType: vfGradationColorType.Red,
      );
    } else if (state == 1) {
      Get.back();
      //영점 조절하기 안내로 보냄

      Get.to(() => ResisterBowlPage(type: _bowlType, isReset: true));
    }
  }

  // 보울 페이지 컨트롤러 변수 초기화
  void reset() {
    barIndex = 0.obs;

    isHaveFoodBowl = false.obs;
    foodWeightText = '0g'.obs;
    foodText1 = ''.obs;
    foodText2 = ''.obs;
    foodText3 = ''.obs;
    foodText2Width = (80 * sizeUnit).obs;
    foodRatio = 0.05.obs;

    isHaveWaterBowl = false.obs;
    waterVolumeText = '0mL'.obs;
    waterText1 = ''.obs;
    waterText2 = ''.obs;
    waterText3 = ''.obs;
    waterText2Width = (80 * sizeUnit).obs;
    waterRatio = 0.05.obs;

    isOpenMenu = false.obs;
  }
}
