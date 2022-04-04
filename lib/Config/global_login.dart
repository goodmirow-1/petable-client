import 'dart:convert';

import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/location.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/Home/Model/advice.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Network/firebaseNotification.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Notification/controller/notification_database.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:myvef_app/initiation/initiation_user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'Constant.dart';
import 'GlobalFunction.dart';

Future<void> globalLogin(Map res, {bool isAutoLogin = false}) async {
  final DashBoardController dashBoardController = Get.find<DashBoardController>();

  await getStandardDeviation(); // 지역 표춘 편차 가져오기
  await getPetData(res); // 펫 데이터 가져오기
  await getCommunityData(); // 커뮤니티 데이터 가져오기

  DashBoardController.to.healthLocation = GlobalData.loggedInUser.value.dong.obs; // 건강점수 행정 구역 세팅

  // 펫이 있을 경우
  if(GlobalData.mainPet.value.id != nullInt) {
    await dashBoardController.getTodayFillFeed(); // 오늘 배급 시간 가져오기
  }

  NotificationController.notiList.clear();
  NotificationController.notiList.value = await NotiDBHelper().getAllData();

  NotificationController notificationController = Get.put(NotificationController());
  //notificationController.makeTempNotiList();
  await notificationController.setNotificationListByEvent();
  await notificationController.setNeedRegistryNotification();
  notificationController.setShowRedDot();

  FirebaseNotifications().setFcmToken('');

  new FirebaseNotifications().setUpFirebase();

  if (GlobalData.loggedInUser.value.nickName == '' || GlobalData.loggedInUser.value.location == '') {
    final LoginController loginController = Get.find<LoginController>();

    loginController.loading = false; // 로딩 끄기
    loginController.stateUpdate();

    if(!isAutoLogin)  Get.back(); // 로딩 다이어로그 끄기

    // user 정보가 없는 경우 user 정보 입력 페이지로 이동
    Get.to(() => InitiationUserPage());
  } else {
    GlobalData().callOnResume();
    Get.offAll(() => MainPage());
  }
}

// 커뮤니티 데이터 가져오기
Future<void> getCommunityData() async {
  final prefs = await SharedPreferences.getInstance();

  // 기기에 저장된 품종 불러오기
  GlobalData.myPetKinds.addAll(['강아지 전체', '고양이 전체']);
  GlobalData.petList.forEach((element) {
    if (!GlobalData.myPetKinds.contains(element.kind)) {
      GlobalData.myPetKinds.add(element.kind);
    }
  });

  GlobalData.communityPetKinds.addAll(prefs.getStringList('communityPetKindList') ?? GlobalData.myPetKinds); // 커뮤니티 필터 품종 리스트 set

  FilterController.to.resetFilterBoolList(); // 필터 bool 리스트 세팅

  // 전체
  GlobalData.communityList.clear();

  var tmpCommunity = await ApiProvider().post(
      '/CommunityPost/Select',
      jsonEncode({
        'index': GlobalData.communityList.length,
      }));

  if (tmpCommunity != null) {
    for (int i = 0; i < tmpCommunity.length; i++) {
      GlobalData.communityList.add(Community.fromJson(tmpCommunity[i]));
    }
  }

  // 인기
  GlobalData.popularCommunityList.clear();

  var tmpPopularCommunity = await ApiProvider().post(
      '/CommunityPost/Select/Popular',
      jsonEncode({
        'index': GlobalData.popularCommunityList.length,
      }));

  if (tmpPopularCommunity != null) {
    for (int i = 0; i < tmpPopularCommunity.length; i++) {
      GlobalData.popularCommunityList.add(Community.fromJson(tmpPopularCommunity[i]));
    }
  }
}

// 펫 데이터 가져오기 및 메인 펫 설정, 보울 데이터 가져오기
Future<void> getPetData(Map res) async {
  GlobalData.petList.clear();

  var tmpPets = res["result"]['Pets'] as List;

  for (int i = 0; i < tmpPets.length; i++) {
    Pet pet = Pet.fromJson(tmpPets[i]);
    pet.advice = getCustomizedAdviceContents(pet);
    GlobalData.petList.add(pet);

    // 입력한 사료 데이터 가져오기
    if (GlobalData.petList[i].foodID != nullInt) {
      if (GlobalData.petList[i].foodID == -1) {
        GlobalData.petList[i].feed = await FeedDBHelper().getFeedData(GlobalData.petList[i].id);
        GlobalData.petList[i].feed!.feedID = -1;
      } else {
        if (GlobalData.petList[i].type == PET_TYPE_DOG) {
          GlobalData.petList[i].feed = GlobalData.dogFeedList.singleWhere((element) => element.feedID == GlobalData.petList[i].foodID);
        } else if (GlobalData.petList[i].type == PET_TYPE_CAT) {
          GlobalData.petList[i].feed = GlobalData.catFeedList.singleWhere((element) => element.feedID == GlobalData.petList[i].foodID);
        }
        GlobalData.petList[i].feed!.userID = GlobalData.petList[i].userId;
        GlobalData.petList[i].feed!.petID = GlobalData.petList[i].id;
      }
    }
  }

  if (GlobalData.petList.isNotEmpty) {
    GlobalData.mainPet(GlobalData.petList[0]);

    //메인펫의 보울 데이터를 보울컨트롤러에 담고, 섭취정보를 불러옴.
    Future.microtask(() async {
      final GraphPageController graphPageController = Get.find<GraphPageController>();

      GlobalData.backLoading(true); // 로딩 시작

      await getBowlData(); //보울 세팅
      //보울 세팅
      final BowlPageController bowlPageController = Get.find();
      bowlPageController.updateFoodBowl();
      bowlPageController.updateWaterBowl();

      await intakeDataSetting(); //섭취 데이터 세팅

      await graphPageController.setGraph(setIntake: false, setSnack: false); // 그래프 세팅

      GlobalData.backLoading(false); // 로딩 끝
    });
  }

  if(GlobalData.mainPet.value.type == PET_TYPE_ECT){
    GlobalData.mainPet.value.advice = getWillBeMyVefAdviceContents();
  }
}

//지역 표준편차 정보 가져오기
Future<void> getStandardDeviation() async {
  var res = await ApiProvider().post('/User/Select/StandardDeviation', jsonEncode({"location": GlobalData.loggedInUser.value.location}));

  if(res['DONG'] != null) GlobalData.dongStandardDeviation = StandardDeviation.fromJson(res['DONG']);
  if(res['SI'] != null) GlobalData.siStandardDeviation = StandardDeviation.fromJson(res['SI']);
  if(res['COUNTRY'] != null) GlobalData.countryStandardDeviation = StandardDeviation.fromJson(res['COUNTRY']);
}
