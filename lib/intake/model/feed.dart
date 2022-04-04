import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';

class Feed {
  int userID;
  int petID;
  int feedID; // 기본 제공 사료 리스트에서만 사용. 커스텀 사료는 사용 안해서 기본값 nullInt
  String brandName;
  String koreaName;
  String englishName;
  double perProtein; // 조단백
  double perFat; // 조지방
  double crudeAsh; // 조회분
  double crudeFiber; // 조섬유
  double water; //수분
  double calcium; // 칼슘
  double phosphorus; // 인
  int calorie; // kg당 칼로리

  Feed({
    this.userID = nullInt,
    this.petID = nullInt,
    this.feedID = nullInt,
    this.brandName = '',
    this.koreaName = '',
    this.englishName = '',
    this.perProtein = 0.0, // 조단백질
    this.perFat = 0.0, // 조지방
    this.crudeAsh = 0.0, // 조회분
    this.crudeFiber = 0.0, // 조섬유
    this.water = 0.0, //수분
    this.calcium = 0.0, // 칼슘
    this.phosphorus = 0.0, // 인
    this.calorie = 0, // kg당 칼로리
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      userID: json['UserID'] ?? nullInt,
      brandName: json['brandName'] ?? '',
      koreaName: json['koreaName'] ?? '',
      englishName: json['englishName'] ?? '',
      perFat: json['perFat'] ?? 0.0,
      perProtein: json['perProtein'] ?? 0.0,
      crudeFiber: json['carbohydrate'] ?? 0.0,
      calorie: json['calorie'] ?? 0,
    );
  }

  // 사료 데이터 가져오기
  Future<void> getFeedData(List list, String tsvPath) async {
    late List<String> tsvRows;
    late List<String> tsvHeadingRow;

    var tsv = await rootBundle.loadString(tsvPath);

    List<String> tsvSplit = tsv.split('\n');
    tsvHeadingRow = tsvSplit[0].split('\t');

    // 행들의 집합
    tsvSplit.removeAt(0);
    tsvRows = tsvSplit;

    List<String> feedList = [];

    for (int i = 0; i < tsvRows.length; i++) {
      feedList = tsvRows[i].split('\t');

      var feed = Feed();

      feed.feedID = int.parse(feedList[0]);
      feed.brandName = feedList[1];
      feed.koreaName = feedList[2];
      feed.englishName = feedList[3];

      if (feedList[4].isNotEmpty) feed.perProtein = getPercent(feedList[4]);

      if (feedList[5].isNotEmpty) feed.perFat = getPercent(feedList[5]);

      if (feedList[6].isNotEmpty) feed.crudeAsh = getPercent(feedList[6]);

      if (feedList[7].isNotEmpty) feed.crudeFiber = getPercent(feedList[7]);

      if (feedList[8].isNotEmpty) feed.water = getPercent(feedList[8]);

      if (feedList[9].isNotEmpty) feed.calcium = getPercent(feedList[9]);

      if (feedList[10].isNotEmpty) feed.phosphorus = getPercent(feedList[10]);

      if (feedList[11].isNotEmpty) feed.calorie = int.parse(feedList[11]);

      feed.setCalorie();

      list.add(feed);
    }
  }

  double getPercent(String value) {
    double percent = double.parse(value.replaceAll(' ', '').replaceAll('이상', '').replaceAll('이하', '').replaceAll('%', '')) / 100;

    return percent;
  }

  //칼로리 없을때 칼로리 계산식을 통해 칼로리를 채우고 수분, 조회분도 없을경우 채움.
  void setCalorie() {
    if (water == 0) water = 0.1;
    if (crudeAsh == 0) crudeAsh = 0.065;
    if (calorie == 0) {
      double hap = perProtein + perFat;
      hap += water + crudeAsh + crudeFiber + calcium + phosphorus;
      double carbohydrate = 1 - hap;
      calorie = ((perProtein * 3.5 + perFat * 8.5 + carbohydrate * 3.5) * 1000).round();
    }
  }
}

Future<Feed> getFeedByFoodID(int foodID) async {
  Feed _feed = Feed();

  if (foodID == -1) {
    _feed = await FeedDBHelper().getFeedData(GlobalData.mainPet.value.id);
    if (_feed.feedID == nullInt) {
      if (GlobalData.mainPet.value.type == PET_TYPE_DOG) {
        _feed = GlobalData.dogFeedList[0];
      } else if (GlobalData.mainPet.value.type == PET_TYPE_CAT) {
        _feed = GlobalData.catFeedList[0];
      }
    }
  } else if (foodID == nullInt) {
    if (GlobalData.mainPet.value.type == PET_TYPE_DOG) {
      _feed = GlobalData.dogFeedList[0];
    } else if (GlobalData.mainPet.value.type == PET_TYPE_CAT) {
      _feed = GlobalData.catFeedList[0];
    }
  } else {
    if (GlobalData.mainPet.value.type == PET_TYPE_DOG) {
      try {
        _feed = GlobalData.dogFeedList.singleWhere((element) => element.feedID == foodID);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (GlobalData.mainPet.value.type == PET_TYPE_CAT) {
      try {
        _feed = GlobalData.catFeedList.singleWhere((element) => element.feedID == foodID);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  return _feed;
}
