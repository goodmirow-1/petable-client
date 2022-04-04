import 'dart:math';

import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';
import 'package:myvef_app/intake/model/feed.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Bowl/Model/bowl.dart';
import '../intake/model/feed.dart';
import 'global_data.dart';

class Pet {
  int id; // 펫 고유 id
  int userId;
  int index; // petList index
  int type; // 강아지 0, 고양이 1, 예비 2
  String name;
  String birthday;
  String kind; // 품종
  double weight;
  int sex;
  int foodID;
  String disease;
  String allergy;
  String createdAt;
  String updatedAt;
  List<PetPhotos> petPhotos;
  Bowl? foodBowl;
  Bowl? waterBowl;
  double foodRecommendedIntake; // 칼로리 권장 섭취량
  double waterRecommendedIntake; // 물 권장 섭취량
  double weightRecommended; // 권장 무게
  String advice;
  int pregnantLactation; //없음0 임신1 수유2
  int weightManage; //없음 0 / 살쪘음 or 활동량 적음 1 / 비만 or 체중 감량 목표 2
  Feed? feed;

  Pet({
    this.id = nullInt,
    this.userId = nullInt,
    this.index = nullInt,
    this.type = PET_TYPE_ECT,
    this.name = '',
    this.birthday = '',
    this.kind = '',
    this.weight = nullDouble,
    this.sex = nullInt,
    this.foodID = nullInt,
    this.disease = '',
    this.allergy = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.petPhotos = const [],
    this.foodBowl,
    this.waterBowl,
    this.foodRecommendedIntake = nullDouble,
    this.waterRecommendedIntake = nullDouble,
    this.weightRecommended = nullDouble,
    this.advice = '',
    this.pregnantLactation = 0,
    this.weightManage = 0,
    this.feed,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    var tmpBowls = json["BowlDeviceTables"] == null ? [] : json["BowlDeviceTables"] as List;
    List<Bowl> bowlList = [];
    Bowl? foodBowl;
    Bowl? waterBowl;
    for (int i = 0; i < tmpBowls.length; i++) {
      bowlList.add(Bowl.fromJson(tmpBowls[i]));
    }
    bowlList.forEach((bowl) {
      if (bowl.type == BOWL_TYPE_FOOD) {
        foodBowl = bowl;
      } else if (bowl.type == BOWL_TYPE_WATER) {
        waterBowl = bowl;
      }
    });

    return Pet(
      id: json["id"] ?? nullInt,
      userId: json["UserID"] ?? nullInt,
      index: json["Index"] ?? nullInt,
      type: json["Type"] ?? PET_TYPE_ECT,
      name: json["Name"] ?? '',
      birthday: json["Birthday"] ?? '',
      kind: json["Kind"] ?? '',
      weight: json["Weight"].toDouble(),
      sex: json["Sex"] ?? nullInt,
      foodID: json["FoodID"] ?? nullInt,
      disease: json["Disease"] ?? '',
      allergy: json["Allergy"] ?? '',
      createdAt: replaceDate(json['createdAt'] ?? ''),
      updatedAt: replaceDate(json['updatedAt'] ?? ''),
      petPhotos: json['PetPhotos'] == null ? [] : (json['PetPhotos'] as List).map((e) => PetPhotos.fromJson(e)).toList(),
      foodBowl: foodBowl,
      waterBowl: waterBowl,
      foodRecommendedIntake: json['FoodRecommendedIntake'] == null
          ? nullDouble
          : json['FoodRecommendedIntake'] is double
              ? json['FoodRecommendedIntake']
              : (json['FoodRecommendedIntake'] as int).toDouble(),
      waterRecommendedIntake: json['WaterRecommendedIntake'] == null
          ? nullDouble
          : json['WaterRecommendedIntake'] is double
              ? json['WaterRecommendedIntake']
              : (json['WaterRecommendedIntake'] as int).toDouble(),
      weightRecommended: json['WeightRecommended'] == null
          ? nullDouble
          : json['WeightRecommended'] is double
              ? json['WeightRecommended']
              : (json['WeightRecommended'] as int).toDouble(),
      pregnantLactation: json['PregnantState'] ?? 0,
      weightManage: json['ObesityState'] ?? 0,
    );
  }

  factory Pet.setData({required Pet oldPet, required Pet newPet}) => Pet(
        id: newPet.id == nullInt ? oldPet.id : newPet.id,
        userId: newPet.userId == nullInt ? oldPet.userId : newPet.userId,
        index: newPet.index == nullInt ? oldPet.index : newPet.index,
        type: newPet.type == nullInt ? oldPet.type : newPet.type,
        name: newPet.name.isEmpty ? oldPet.name : newPet.name,
        birthday: newPet.birthday.isEmpty ? oldPet.birthday : newPet.birthday,
        kind: newPet.kind.isEmpty ? oldPet.kind : newPet.kind,
        weight: newPet.weight == nullDouble ? oldPet.weight : newPet.weight,
        sex: newPet.sex == nullInt ? oldPet.sex : newPet.sex,
        foodID: newPet.foodID == nullInt ? oldPet.foodID : newPet.foodID,
        disease: newPet.disease.isEmpty ? oldPet.disease : newPet.disease,
        allergy: newPet.allergy.isEmpty ? oldPet.allergy : newPet.allergy,
        createdAt: newPet.createdAt.isEmpty ? oldPet.createdAt : newPet.createdAt,
        updatedAt: newPet.updatedAt.isEmpty ? oldPet.updatedAt : newPet.updatedAt,
        petPhotos: newPet.petPhotos.isEmpty ? oldPet.petPhotos : newPet.petPhotos,
        foodRecommendedIntake: newPet.foodRecommendedIntake == nullDouble ? oldPet.foodRecommendedIntake : newPet.foodRecommendedIntake,
        waterRecommendedIntake: newPet.waterRecommendedIntake == nullDouble ? oldPet.waterRecommendedIntake : newPet.waterRecommendedIntake,
        weightRecommended: newPet.weightRecommended == nullDouble ? oldPet.weightRecommended : newPet.weightRecommended,
        feed: newPet.feed ?? oldPet.feed,
        pregnantLactation: newPet.pregnantLactation == nullInt ? oldPet.pregnantLactation : newPet.pregnantLactation,
        weightManage: newPet.weightManage == nullInt ? oldPet.weightManage : newPet.weightManage,
      );
}

class PetPhotos {
  int id;
  int petId;
  int index;
  String imageUrl;
  String createdAt;
  String updatedAt;

  PetPhotos({
    this.id = nullInt,
    this.petId = nullInt,
    this.index = nullInt,
    this.imageUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory PetPhotos.fromJson(Map<String, dynamic> json) => PetPhotos(
        id: json["id"] ?? nullInt,
        petId: json["PetID"] ?? nullInt,
        index: json["Index"] ?? nullInt,
        imageUrl: ApiProvider().getImgUrl + '/PetPhotos/' + json['PetID'].toString() + '/' + (json["ImageURL"] ?? ''),
        createdAt: replaceDate(json['createdAt'] ?? ''),
        updatedAt: replaceDate(json['updatedAt'] ?? ''),
      );
}

// 사료 하루 권장 섭취량(g) 현재 220325 쓰이는 곳 없음.
Future<double> calFoodRecommendedDailyIntake({required Pet pet, int calorie = 0}) async {
  double needCalories = calRecommendedDaily(pet);
  Feed feed = Feed();

  if (pet.foodID == nullInt) {
    if (pet.type == PET_TYPE_DOG) {
      feed = GlobalData.dogFeedList[0];
    } else if (pet.type == PET_TYPE_CAT) {
      feed = GlobalData.catFeedList[0];
    }
  } else if (pet.foodID == -1) {
    if (calorie != 0)
      feed.calorie = calorie;
    else
      feed = await FeedDBHelper().getFeedData(pet.id);
  } else {
    if (pet.type == PET_TYPE_DOG) {
      //feedID 동일한거 찾음
      for (int i = 0; i < GlobalData.dogFeedList.length; i++) {
        if (GlobalData.dogFeedList[i].feedID == pet.foodID) {
          feed = GlobalData.dogFeedList[i];
          break;
        }
      }
    } else if (pet.type == PET_TYPE_CAT) {
      //feedID 동일한거 찾음
      for (int i = 0; i < GlobalData.catFeedList.length; i++) {
        if (GlobalData.catFeedList[i].feedID == pet.foodID) {
          feed = GlobalData.catFeedList[i];
          break;
        }
      }
    }
  }

  // 하루 권장 섭취량 (g)
  double recommendedDailyIntake = needCalories / (feed.calorie / 1000); // 필요 칼로리 / 사료 g당 칼로리

  return recommendedDailyIntake;
}

//권장섭취 칼로리 및 물
double calRecommendedDaily(Pet pet) {
  double rer = 70 * pow(pet.weight, 0.75).toDouble(); //기초대사량
  double facter = -1; //활동지수

  int age = calAgeMonth(pet.birthday); //개월수 표시

  if (pet.type == 0) {
    //개
    if (age < 12) {
      if (age < 4)
        facter = 3; //4개월 미만
      else
        facter = 2; //4개월~ 12개월
    } else if (pet.pregnantLactation != NONE) {
      if (pet.pregnantLactation == PREGNANT)
        facter = 1.8; //임신중. 임신 기간에 따라 1.6~2
      else if (pet.pregnantLactation == LACTATION) facter = 3; //수유중. 새끼의 숫자와 성장단계에따라 2~6
    } else if (pet.weightManage != WEIGHT_NORMAL) {
      if (pet.weightManage == WEIGHT_LOW_ACTIVITY)
        facter = 1.2; //약간 살찜, 활동량 적음.
      else if (pet.weightManage == WEIGHT_OBESITY) facter = 1; //비만, 체중감량목표
    } else if (age > 84)
      facter = 1.4; //노령 7살 이상
    else if (pet.sex == 3 || pet.sex == 4)
      facter = 1.6; //중성화
    else
      facter = 1.8; //일반
  } else if (pet.type == 1) {
    //고양이
    if (age < 12) {
      facter = 2.5; //새끼 고양이는 자유배식도 가능
    } else if (pet.pregnantLactation != NONE) {
      if (pet.pregnantLactation == PREGNANT)
        facter = 2.5; //임신중. 임신 기간에 따라 2~3
      else if (pet.pregnantLactation == LACTATION) facter = 3; //수유중. 새끼의 숫자와 성장단계에따라 2~6
    } else if (pet.weightManage != WEIGHT_NORMAL) {
      if (pet.weightManage == WEIGHT_LOW_ACTIVITY)
        facter = 1; //약간 살찜, 활동량 적음.
      else if (pet.weightManage == WEIGHT_OBESITY) facter = 0.8; //비만, 체중감량목표
    } else if (age > 84)
      facter = 1.1; //노령 7살 이상
    else if (pet.sex == 3 || pet.sex == 4)
      facter = 1.2; //중성화
    else
      facter = 1.4; //일반
  }

  double needCalories = rer * facter; // 필요 칼로리(kcal) 및 물(ml)

  return needCalories;
}

//물, 칼로리 섭취/권장 넣으면 점수로 바꿔서 리턴함.
double convertScore(double ratio) {
  if (ratio < 0 || ratio > 2) return 0;
  if (ratio < 2 / 3) return (3 / 4 * ratio) * 100;
  if (ratio > 4 / 3) return (-3 / 4 * (ratio - 2)) * 100;

  double score = (-9 / 2 * (ratio - 2 / 3) * (ratio - 4 / 3) + 1 / 2) * 100;
  return score;
}

int calAgeMonth(String birthday) {
  int age = 0;
  final List<String> _birthday = birthday.split('.');
  final DateTime birthDate = DateTime(int.parse(_birthday[0]), int.parse(_birthday[1]), int.parse(_birthday[2]));
  final DateTime now = DateTime.now();
  int diffYear = now.year - birthDate.year;
  int diffMonth = now.month - birthDate.month;
  final int diffDay = now.day - birthDate.day;

  if (diffDay < 0) diffMonth--;
  age += diffMonth;
  if (diffMonth < 0) diffYear--;
  age += diffYear * 12;

  return age;
}
