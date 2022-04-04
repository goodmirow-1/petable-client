import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/model/calorie.dart';
import 'package:myvef_app/intake/model/snack.dart';
import 'package:myvef_app/intake/model/snack_intake.dart';
import 'package:myvef_app/intake/controller/snack_intake_database.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:myvef_app/intake/model/water.dart';

class SnackController{

  setSnack() async {
    int petID = GlobalData.mainPet.value.id;

    await setSnackByServer();
    //마지막으로 처리된 snackIntakeID 가져옴
    int lastSnackIntakeIDFromCalorie = await CalorieController().getLastSnackIntakeID();
    int lastSnackIntakeIDFromWater = await WaterController().getLastSnackIntakeID();
    int lastProcessedID = lastSnackIntakeIDFromCalorie > lastSnackIntakeIDFromWater ? lastSnackIntakeIDFromCalorie : lastSnackIntakeIDFromWater;

    CalorieController calorieController = Get.put(CalorieController());
    WaterController waterController = Get.put(WaterController());

    //Snack 계산
    List<SnackIntake> _snackList = await SnackDBHelper().getSnackList(petID: petID, id: lastProcessedID);

    List<Calorie> _calorieList = [];
    List<Water> _waterList = [];

    for (int i = 0; i < _snackList.length; i++) {
      Snack _snack = getSnackBySnackID(_snackList[i].snackID);
      DateTime _time = dateTimeFromString(_snackList[i].time);

      //물 섭취시 칼로리 입력x
      if(_snackList[i].snackID != 0){
        _calorieList.add(Calorie(
            petID: petID,
            amount: _snackList[i].weight * _snack.calorie / 100,//snack kcal/100g 환산
            type: CALORIE_TYPE_SNACK,
            time: _time,
            snackIntakeID: _snackList[i].id
        ));
      }

      _waterList.add(Water(
          petID: petID,
          amount: _snackList[i].weight * _snack.water,
          type: _snackList[i].snackID == 0 ? WATER_TYPE_DRINK : WATER_TYPE_EAT, // 물이면 마신걸로
          time: _time,
          snackIntakeID: _snackList[i].id
      ));
    }
    await calorieController.insertCalorieList(_calorieList);
    await waterController.insertWaterList(_waterList);
  }

  setSnackByServer() async {
    int petID = GlobalData.mainPet.value.id;
    int lastIntakeID = await SnackDBHelper().getLastSnackID(petID);

    var tmpIntakes = await ApiProvider().post(
        '/Pet/Select/IntakeSnack',
        jsonEncode({
          'petID': petID,
          'id': lastIntakeID,
        }));

    if (tmpIntakes != null) {
      List<SnackIntake> _snackIntakeList = [];
      for (int i = 0; i < tmpIntakes.length; i++) {
        _snackIntakeList.add(SnackIntake.fromJson(tmpIntakes[i]));
      }
      await SnackDBHelper().insertMulti(_snackIntakeList);
    }
  }

  insertSnack(SnackIntake snackIntake) async {
    var res = await ApiProvider().post(
        '/Pet/Insert/IntakeSnack',
        jsonEncode({
          'petID': snackIntake.petID,
          'snackID': snackIntake.snackID,
          'amount': snackIntake.weight,
          'time': snackIntake.time,
        }));
    if (res != null) {
      SnackIntake resSnackIntake = SnackIntake.fromJson(res);
      await SnackDBHelper().insert(resSnackIntake);
      return;
    } else {
      Fluttertoast.showToast(
        msg: '등록에 실패했습니다!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
      );
      return;
    }
  }
}
