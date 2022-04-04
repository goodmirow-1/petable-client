import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAbStractClass.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:myvef_app/Home/Model/advice.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:myvef_app/intake/controller/calorie_controller.dart';
import 'package:myvef_app/intake/controller/calorie_database.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';
import 'package:myvef_app/Data/location.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Notification/controller/notification_database.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:myvef_app/intake/controller/intake_database.dart';
import 'package:myvef_app/intake/controller/snack_intake_database.dart';
import 'package:myvef_app/intake/controller/water_controller.dart';
import 'package:myvef_app/intake/controller/water_database.dart';
import 'package:myvef_app/intake/model/snack.dart';
import 'package:myvef_app/setting/faq_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../intake/model/feed.dart';

class GlobalData extends GetxController with StoppableService{
  static get to => Get.find<GlobalData>();

  // 유저
  static Rx<UserData> loggedInUser = UserData().obs; // 로그인한 유저
  static RxList<UserData> userList = <UserData>[].obs;
  static List<UserData> simpleUserList = []; // 아이디, 닉네임, 프로필 사진 가진 유저 정보

  // 펫
  static Rx<Pet> mainPet = Pet().obs; // 메인 펫
  static RxList<Pet> petList = <Pet>[].obs; // 펫 리스트

  // 커뮤니티
  static RxList<Community> communityList = <Community>[].obs; // 커뮤니티 리스트
  static RxList<Community> popularCommunityList = <Community>[].obs; // 인기 커뮤니티 리스트
  static RxList<Community> filteredCommunityList = <Community>[].obs; // 필터링된 커뮤니티 리스트
  static RxList<Community> filteredPopularCommunityList = <Community>[].obs; // 필터링된 인기 커뮤니티 리스트
  static List<Community> myCommunityList = []; // 마이 커뮤니티 리스트
  static List<Community> searchedCommunityList = []; // 검색 커뮤니티 리스트
  static List<Community> profileCommunityList = []; // 프로필 커뮤니티 리스트
  static RxList<String> communityPetKinds = <String>[].obs; // 커뮤니티 품종 리스트
  static List<String> myPetKinds = []; // 내 펫의 품종 리스트

  static String accessToken = '';
  static String refreshToken = '';
  static String accessTokenExpiredAt = '';

  static StandardDeviation dongStandardDeviation = StandardDeviation(); //동 지역 평균
  static StandardDeviation siStandardDeviation = StandardDeviation(); //시별 지역 평균
  static StandardDeviation countryStandardDeviation = StandardDeviation(); //도시별 지역 평균

  // 사료
  static List<Feed> dogFeedList = []; // 강아지 선택 사료 리스트
  static List<Feed> catFeedList = []; // 고양이 선택 사료 리스트

  // 간식
  // 개 간식 리스트
  static List<Snack> dogSnackList = [];
  static List<Snack> dogEatSnackList = [];
  static List<Snack> dogDrinkSnackList = [];

  // 고양이 간식 리스트
  static List<Snack> catSnackList = [];
  static List<Snack> catEatSnackList = [];
  static List<Snack> catDrinkSnackList = [];


  // 품종
  static List<String> dogKindList = []; // 강아지 품종 리스트
  static List<String> catKindList = []; // 고양이 품종 리스트

  static List<FAQ> faqList = [];//자주 묻는 질문 리스트

  static RxBool backLoading = false.obs; // 백그라운드에서 섭취 데이터 다 받아왔는지 여부

  static DateTime? currentBackPressTime; // 백 버튼 누른 시간 (앱 종료 체크용)

  static Timer? tokenTimer;

  static bool isResisterBowl = false;

  @override
  void start() {
    super.start();

    callOnResume();
  }

  @override
  void stop() {
    super.stop();

    callOnPause();
  }

  //들고있던 전역데이터 초기화
  Future<void> callClear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final LoginController loginController = Get.find<LoginController>();
    final NavigationController navigationController = Get.find<NavigationController>();

    Get.put(FoodBowlController());
    Get.put(WaterBowlController());

    loginController.email(''); // 이메일 초기화
    loginController.password(''); // 비밀번호 초기화

    // 컨트롤러 변수 초기화
    DashBoardController.to.reset();
    GraphPageController.to.reset();
    BowlPageController.to.reset();
    FoodBowlController.to.reset();
    WaterBowlController.to.reset();

    CalorieController.to.reset();
    WaterController.to.reset();

    if(navigationController.activePet.value) navigationController.offPetFunc(); // 펫 바꾸는 위젯 활성화 되어있다면 끄기

    prefs.setBool('autoLoginKey', false); // 자동 로그인 끄기
    prefs.setString('autoLoginEmail', ''); // 자동 로그인 이메일
    prefs.setString('autoLoginPw', ''); // 자동 로그인 패스워드
    prefs.setInt('loginType', 0);
    prefs.setDouble('myLatitude', nullDouble);
    prefs.setDouble('myLongtitude', nullDouble);
    prefs.remove('communityPetKindList'); // 필터 품종 리스트 삭제

    loggedInUser = UserData().obs;
    userList.clear();
    simpleUserList.clear();

    mainPet = Pet().obs;
    petList.clear();
    communityList.clear();
    popularCommunityList.clear();
    filteredCommunityList.clear();
    filteredPopularCommunityList.clear();
    myCommunityList.clear();
    searchedCommunityList.clear();
    profileCommunityList.clear();
    communityPetKinds.clear();
    myPetKinds.clear();

    accessToken = '';
    refreshToken = '';
    accessTokenExpiredAt = '';

    dongStandardDeviation = StandardDeviation();
    siStandardDeviation = StandardDeviation();
    countryStandardDeviation = StandardDeviation();

    clearExcelData();

    NotiDBHelper().dropTable();

    IntakeDBHelper().dropTable();
    SnackDBHelper().dropTable();
    WaterDBHelper().dropTable();
    CalorieDBHelper().dropTable();

    FeedDBHelper().dropTable();

    tokenTimer!.cancel();
  }

  Future<void> clearExcelData() async {
    dogFeedList.clear();
    catFeedList.clear();

    dogSnackList.clear();
    catSnackList.clear();

    dogKindList.clear();
    catKindList.clear();
  }

  void addUser(UserData user){
    userList.add(user);
  }

  UserData? getUser(int userID){
    if(userID == nullInt) return null;

    return userList.singleWhere((element) => element.userID == userID);
  }

  Future<UserData> getFutureUser(int userID) async {
    UserData? user;

    userList.forEach((element) {
      if(element.userID == userID){
        user = element;
      }
    });

    if(user == null){
      var res = await ApiProvider().post('/User/Select', jsonEncode({
        'userID' : userID
      }));

      if(res != null){
        user = UserData.fromJson(res);
        userList.add(user!);
      }else{
        throw Exception();
      }
    }

    return Future.value(user);
  }

  UserData? getSimpleUser(int userID){
    if(userID == nullInt) return null;

    return simpleUserList.singleWhere((element) => element.userID == userID);
  }

  Future<UserData> getFutureSimpleUser(int userID) async {
    UserData? user;

    for(int i = 0; i < simpleUserList.length; i++) {
      if(simpleUserList[i].userID == userID) {
        user = simpleUserList[i];
        break;
      }
    }

    if(user == null){
      var res = await ApiProvider().post('/User/Select/SimpleData', jsonEncode({
        'UserID' : userID
      }));

      if(res != null){
        user = UserData.fromJson(res);
        simpleUserList.add(user);
      }else{
        throw Exception();
      }
    }

    return Future.value(user);
  }

  void callOnResume(){
    if(loggedInUser.value.userID != nullInt){
      ApiProvider().post('/OnResume', jsonEncode({
        "userID" : loggedInUser.value.userID
      }));
    }
  }

  void callOnPause(){
    if(loggedInUser.value.userID != nullInt){
      ApiProvider().post('/OnPause', jsonEncode({
        "userID" : loggedInUser.value.userID
      }));
    }
  }

  Future<Community> getFutureCommunity(int communityID) async {
    Community? community;

    for(int i = 0; i < communityList.length; i++) {
      if(communityList[i].id == communityID) {
        community = communityList[i];
        break;
      }
    }

    if(community == null){
      var res = await ApiProvider().post('/CommunityPost/Select/ID', jsonEncode({
        'id' : communityID
      }));

      if(res != null){
        community = Community.fromJson(res);

        await getFutureSimpleUser(res['userID']);

        communityList.add(community);
        communityList.sort((b, a) => a.id.compareTo(b.id));
      }else{
        Community tempCommunity = Community();

        return Future.value(tempCommunity);
      }
    }

    return Future.value(community);
  }
}