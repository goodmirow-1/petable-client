import 'dart:math';

import 'package:flutter/services.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/pet.dart';

class Advice {
  int id;
  String months;
  String days;
  String contents;
  int contentType;
  String petType;
  int priority;

  Advice({
    this.id = nullInt,
    this.months = '',
    this.days = '',
    this.contents = '',
    this.contentType = 0, //0 : INFO, 1 : ACTIVE, 2 : DAILY
    this.petType = '',
    this.priority = 0,
  });
}

List<Advice> globalAdviceList = [];

Future<void> getAdviceData() async {
  if(globalAdviceList.isNotEmpty) return;

  late List<String> tsvRows;
  late List<String> tsvHeadingRow;
  var tsv = await rootBundle.loadString("assets/text/advice.tsv");

  List<String> tsvSplit = tsv.split('\n');
  tsvHeadingRow = tsvSplit[0].split('\t');

  // 행들의 집합
  tsvSplit.removeAt(0);
  tsvRows = tsvSplit;

  List<String> splitList = [];

  for (int i = 0; i < tsvRows.length; i++) {
    splitList = tsvRows[i].split('\t');
    splitList[splitList.length - 1] = splitList[splitList.length - 1].split('\r')[0];

    Advice advice = Advice(
      id: int.parse(splitList[0]),
      months: splitList[1],
      days:  splitList[2],
      contents:  splitList[3],
      contentType: int.parse(splitList[4]),
      petType: splitList[5],
      priority: int.parse(splitList[6])
    );

    globalAdviceList.add(advice);
  }
}

String checkToken(String contents){
  List<String> splitList = contents.split('|');
  String res = '';

  for(var i = 0 ; i < splitList.length; ++i){
    res += splitList[i];

    if(i < (splitList.length - 1)){
      res += "\n";
    }
  }

  return res;
}

String getCustomizedAdviceContents(Pet pet){

  List<Advice> adviceList = globalAdviceList;
  List<Advice> checkList = [];

  DateTime todayDate = DateTime.now();

  for(int i = 0 ; i < adviceList.length; ++i) {
    //우선순위 검사
    if (adviceList[i].priority != 0) {
      return checkToken(adviceList[i].contents);
    }
    else if (adviceList[i].contentType == 2) { // 날짜형 검사
      if(adviceList[i].days != '-' || adviceList[i].days != ''){
        List<String> dayList = adviceList[i].days.split('|');

        for (int j = 0; j < dayList.length; ++j) {
          //같은 날짜면
          if (todayDate.day == int.parse(dayList[j])) {
            return checkToken(adviceList[i].contents);
          }
        }
      }
    }else if(adviceList[i].contentType == 1){ //펫 상태에 따른 계산 필요

    }else if(adviceList[i].contentType == 0){ //기본
      if(adviceList[i].months == '-' || adviceList[i].months == ''){
        if((adviceList[i].petType == "" || adviceList[i].petType == "-")){
          checkList.add(adviceList[i]);
        }else{
          if(int.parse(adviceList[i].petType) == pet.type){
            checkList.add(adviceList[i]);
          }
        }
      }else{
        List<String> monthList = adviceList[i].months.split('|');

        for (int j = 0; j < monthList.length; ++j) {
          //같은 날짜면
          if (todayDate.month == int.parse(monthList[j])) {
            checkList.add(adviceList[i]);
          }
        }
      }
    }
  }

  return checkList.length == 0 ? checkToken(globalAdviceList[0].contents) : checkToken(checkList[Random().nextInt(checkList.length - 1)].contents);
}

//예비 마이베프용 한마디
String getWillBeMyVefAdviceContents(){
  List<Advice> adviceList = globalAdviceList;
  List<Advice> checkList = [];

  for(int i = 0 ; i < adviceList.length; ++i){
    if((adviceList[i].petType != "" && adviceList[i].petType != "-") && int.parse(adviceList[i].petType) == PET_TYPE_ECT){
      checkList.add(adviceList[i]);
    }
  }

  return checkList.length == 0 ? checkToken(globalAdviceList[0].contents) : checkToken(checkList[Random().nextInt(checkList.length - 1)].contents);
}