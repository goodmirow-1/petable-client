import 'dart:convert';

import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:myvef_app/intake/model/calorie.dart';
import 'package:myvef_app/intake/model/feed.dart';
import 'package:myvef_app/intake/model/intake.dart';
import 'package:myvef_app/intake/controller/intake_database.dart';
import 'package:myvef_app/intake/model/water.dart';

class IntakeController {
  setIntake() async {
    int petID = GlobalData.mainPet.value.id;

    await setIntakeByServer();
    //마지막으로 처리된 IntakeID 가져옴
    int lastIntakeIDFromCalorie = await CalorieController().getLastIntakeID();
    int lastIntakeIDFromWater = await WaterController().getLastIntakeID();
    int lastProcessedID = lastIntakeIDFromCalorie > lastIntakeIDFromWater ? lastIntakeIDFromCalorie : lastIntakeIDFromWater;

    CalorieController calorieController = Get.put(CalorieController());
    WaterController waterController = Get.put(WaterController());

    //intakeFood 계산
    List<Intake> _intakeFoodList = await IntakeDBHelper().getIntakeList(petID: petID, type: INTAKE_TYPE_FOOD, id: lastProcessedID);

    List<Calorie> _calorieList = [];
    List<Water> _waterList = [];

    //최신 섭취정보부터 다먹은 상태 이전값과 비교하여 먹은 양을 각각 칼로리와 음수량에 추가함. 마지막 인덱스는 이전이 없기때문에 검사하지 않음.
    for (int i = 0; i < _intakeFoodList.length - 1; i++) {
      if (_intakeFoodList[i].state == INTAKE_STATE_END) {
        double intakeWeight = _intakeFoodList[i + 1].weight - _intakeFoodList[i].weight;
        if(intakeWeight < 0) intakeWeight = 0;
        Feed _feed = await getFeedByFoodID(_intakeFoodList[i].foodID);
        DateTime _time = dateTimeFromString(_intakeFoodList[i].createdAt);

        _calorieList.add(Calorie(
          petID: petID,
          amount: intakeWeight * _feed.calorie / 1000,
          time: _time,
          intakeID: _intakeFoodList[i].id,
        ));

        _waterList.add(Water(
          petID: petID,
          amount: intakeWeight * _feed.water,
          type: WATER_TYPE_EAT,
          time: _time,
          intakeID: _intakeFoodList[i].id,
        ));
      }
    }

    await calorieController.insertCalorieList(_calorieList);
    await waterController.insertWaterList(_waterList);

    List<Intake> _intakeWaterList = await IntakeDBHelper().getIntakeList(petID: petID, type: INTAKE_TYPE_WATER, id: lastProcessedID);

    _waterList.clear();

    for (int i = 0; i < _intakeWaterList.length - 1; i++) {
      if (_intakeWaterList[i].state == INTAKE_STATE_END) {
        double intakeWeight = _intakeWaterList[i + 1].weight - _intakeWaterList[i].weight;
        DateTime _time = dateTimeFromString(_intakeWaterList[i].createdAt);

        _waterList.add(Water(
          petID: petID,
          amount: intakeWeight,
          type: WATER_TYPE_DRINK,
          time: _time,
          intakeID: _intakeWaterList[i].id,
        ));
      }
    }

    await waterController.insertWaterList(_waterList);
  }

  setIntakeByServer() async {
    int petID = GlobalData.mainPet.value.id;
    int lastIntakeID = await IntakeDBHelper().getLastIntakeID(petID);

    var tmpIntakes = await ApiProvider().post(
        '/Pet/Select/IntakeData',
        jsonEncode({
          'petID': petID,
          'id': lastIntakeID,
        }));

    if (tmpIntakes != null) {
      List<Intake> intakeList = [];

      for (int i = 0; i < tmpIntakes.length; i++) {
        intakeList.add(Intake.fromJson(tmpIntakes[i]));
      }

      await IntakeDBHelper().insertMulti(intakeList);
    }
  }
}
