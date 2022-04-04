import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';

class Snack {
  int userID;
  int petID;
  int snackID;
  String category;
  String brandName;
  String koreaName;
  double perProtein; // 조단백
  double perFat; // 조지방
  double crudeAsh; // 조회분
  double crudeFiber; // 조섬유
  double water; //수분
  double calcium; // 칼슘
  double phosphorus; // 인
  int weightPerSnack; // 개당 무게
  int caloriePerSnack; // 개당 칼로리
  int calorie; // 100g당 칼로리

  Snack({
    this.userID = nullInt,
    this.petID = nullInt,
    this.snackID = nullInt,
    this.category = '',
    this.brandName = '',
    this.koreaName = '',
    this.perProtein = 0.0, // 조단백질
    this.perFat = 0.0, // 조지방
    this.crudeAsh = 0.0, // 조회분
    this.crudeFiber = 0.0, // 조섬유
    this.water = 0.0, //수분
    this.calcium = 0.0, // 칼슘
    this.phosphorus = 0.0, // 인
    this.weightPerSnack = 0, // 개당 무게
    this.caloriePerSnack = 0, // 개당 칼로리
    this.calorie = 0, // 100g당 칼로리
  });

  int getCalorie(int weightPerSnack, int caloriePerSnack, double perProtein, double perFat, double crudeFiber) {
    int calorie;
    if (weightPerSnack != 0 && caloriePerSnack != 0) {
      calorie = ((caloriePerSnack / weightPerSnack) * 100).round();
    } else {
      calorie = ((perProtein * 3.5 + perFat * 8.5 + crudeFiber * 3.5) * 100).round();
    }

    return calorie;
  }

  double getPercent(String value) {
    double percent = double.parse(value.replaceAll(' ', '').replaceAll('이상', '').replaceAll('이하', '').replaceAll('%', '')) / 100;
    return percent;
  }

  Future<void> getSnackData(List list, String tsvPath) async {
    late List<String> tsvRows;
    late List<String> tsvHeadingRow;

    var tsv = await rootBundle.loadString(tsvPath);

    List<String> tsvSplit = tsv.split('\n');
    tsvHeadingRow = tsvSplit[0].split('\t');

    // 행들의 집합
    tsvSplit.removeAt(0);
    tsvRows = tsvSplit;

    List<String> snackList = [];

    for (int i = 0; i < tsvRows.length; i++) {
      snackList = tsvRows[i].split('\t');

      var snack = Snack();

      snack.snackID = int.parse(snackList[0]);
      snack.category = snackList[1];
      snack.brandName = snackList[2];
      snack.koreaName = snackList[3];

      if (snackList[4].isNotEmpty)
        snack.perProtein = getPercent(snackList[4]);

      if (snackList[5].isNotEmpty)
        snack.perFat = getPercent(snackList[5]);

      if (snackList[6].isNotEmpty)
        snack.crudeAsh = getPercent(snackList[6]);

      if (snackList[7].isNotEmpty)
        snack.crudeFiber = getPercent(snackList[7]);

      if (snackList[8].isNotEmpty)
        snack.water = getPercent(snackList[8]);

      if (snackList[9].isNotEmpty)
        snack.calcium = getPercent(snackList[9]);

      if (snackList[10].isNotEmpty)
        snack.phosphorus = getPercent(snackList[10]);

      if (snackList[12].isNotEmpty)
        snack.weightPerSnack = double.parse(snackList[12]).round();

      if (snackList[13].isNotEmpty)
        snack.caloriePerSnack = double.parse(snackList[13]).round();

      if (snackList[14].isEmpty)
        snack.calorie = getCalorie(snack.weightPerSnack, snack.caloriePerSnack, snack.perProtein, snack.perFat, snack.crudeFiber);
      else
        snack.calorie = int.parse(snackList[14]);

      if (snack.snackID == 0 || (snack.caloriePerSnack != 0 && snack.weightPerSnack != 0) || (snack.perProtein != 0.0 || snack.perFat != 0.0 || snack.crudeFiber != 0.0))
        list.add(snack);
    }
  }
}

Snack getSnackBySnackID(int snackID) {
  Snack _snack = Snack();

  if (snackID != nullInt) {
    if (GlobalData.mainPet.value.type == PET_TYPE_DOG) {
      try {
        _snack = GlobalData.dogSnackList.singleWhere((element) => element.snackID == snackID);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (GlobalData.mainPet.value.type == PET_TYPE_CAT) {
      try {
        _snack = GlobalData.catSnackList.singleWhere((element) => element.snackID == snackID);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  return _snack;
}