import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/global_page/feeds_choice_page.dart';
import 'package:myvef_app/Home/Model/advice.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import '../../Config/Constant.dart';
import '../../Config/GlobalFunction.dart';
import '../../Config/GlobalWidget/GlobalWidget.dart';
import '../../Data/global_data.dart';
import '../../Data/pet.dart';
import '../../Home/main_page.dart';
import '../../Network/ApiProvider.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../intake/model/feed.dart';

class PetController extends GetxController {
  final FeedChoiceController feedChoiceController = Get.put(FeedChoiceController());

  RxString type = GlobalData.mainPet.value.type == PET_TYPE_DOG
      ? '강아지'.obs
      : GlobalData.mainPet.value.type == PET_TYPE_CAT
          ? '고양이'.obs
          : GlobalData.mainPet.value.type == PET_TYPE_ECT
              ? '예비 마이베프'.obs
              : ''.obs;

  RxString name = GlobalData.mainPet.value.name.obs;
  RxString sex = (GlobalData.mainPet.value.sex == MALE || GlobalData.mainPet.value.sex == NEUTERING_MALE)
      ? '남'.obs
      : (GlobalData.mainPet.value.sex == FEMALE || GlobalData.mainPet.value.sex == NEUTERING_FEMALE)
          ? '여'.obs
          : ''.obs;
  RxString neutering = (GlobalData.mainPet.value.sex == MALE || GlobalData.mainPet.value.sex == FEMALE)
      ? 'X'.obs
      : (GlobalData.mainPet.value.sex == NEUTERING_MALE || GlobalData.mainPet.value.sex == NEUTERING_FEMALE)
          ? 'O'.obs
          : ''.obs;
  RxString birthday = GlobalData.mainPet.value.birthday.obs;
  RxString kind = GlobalData.mainPet.value.kind.obs; // 선택된 품종
  RxString disease = GlobalData.mainPet.value.disease.obs;
  RxString allergy = GlobalData.mainPet.value.allergy.obs;

  RxString feedBrandName = (GlobalData.mainPet.value.foodID != nullInt)
      ? (GlobalData.mainPet.value.foodID != -1)
          // 사료를 선택한 경우
          ? ''.obs
          // 사료를 직접 입력한 경우
          : '${GlobalData.mainPet.value.feed!.brandName} '.obs
      : ''.obs;
  RxString feedKoreaName = (GlobalData.mainPet.value.foodID != nullInt) ? GlobalData.mainPet.value.feed!.koreaName.obs : ''.obs;

  RxString obesityState = (GlobalData.mainPet.value.weightManage == WEIGHT_NORMAL)
      ? '정상'.obs
      : (GlobalData.mainPet.value.weightManage == WEIGHT_LOW_ACTIVITY)
          ? '활동량 적음'.obs
          : (GlobalData.mainPet.value.weightManage == WEIGHT_OBESITY)
              ? '비만'.obs
              : ''.obs;

  RxString pregnantState = (GlobalData.mainPet.value.pregnantLactation == PREGNANT)
      ? '임신'.obs
      : (GlobalData.mainPet.value.pregnantLactation == LACTATION)
          ? '수유'.obs
          : ''.obs;

  RxInt foodID = GlobalData.mainPet.value.foodID.obs;

  RxBool isTypeOk = false.obs;
  RxBool isNameOk = false.obs;
  RxBool isWeightOk = false.obs;
  RxBool isSexOk = false.obs;
  RxBool isNeuteringOk = false.obs;
  RxBool isBirthdayOk = false.obs;
  RxBool isKindOk = false.obs;
  RxBool isEditPetOk = true.obs; // 펫 수정완료 버튼

  RxInt firstWeight = 0.obs; // 몸무게 첫째자리
  RxInt secondWeight = 0.obs; // 몸무게 둘째자리
  RxDouble weight = GlobalData.mainPet.value.weight.obs; // 몸무게

  RxInt barIndex = 0.obs; // 수정페이지 바 인덱스

  RxList petImageList = [].obs; // 사진

  void petNameCheckValid() {
    if (name.value.isNotEmpty && validPetNameErrorText(name.value).isEmpty)
      isNameOk(true);
    else
      isNameOk(false);
  }

  void petWeightCheckValid() {
    if (weight.value != 0.0)
      isWeightOk(true);
    else
      isWeightOk(false);
  }

  void typeCheckValid() {
    if (type.value.isNotEmpty)
      isTypeOk(true);
    else
      isTypeOk(false);
  }

  void petSexCheckValid() {
    if (sex.value.isNotEmpty)
      isSexOk(true);
    else
      isSexOk(false);
  }

  void petNeuteringCheckValid() {
    if (neutering.value.isNotEmpty)
      isNeuteringOk(true);
    else
      isNeuteringOk(false);
  }

  void petBirthCheckValid() {
    if (birthday.value.isNotEmpty)
      isBirthdayOk(true);
    else
      isBirthdayOk(false);
  }

  void kindCheckValid() {
    if (kind.value.isNotEmpty)
      isKindOk(true);
    else
      isKindOk(false);
  }

  void initiationBackFunc(PageController pageController) {
    if (pageController.page == 0)
      Get.back();
    else
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
  }

  void nextFunc(PageController pageController) {
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void editPetCheckValid() {
    if (name.value.isNotEmpty &&
        birthday.value.isNotEmpty &&
        kind.value.isNotEmpty &&
        weight.value != 0.0 &&
        sex.value.isNotEmpty &&
        neutering.value.isNotEmpty &&
        validPetNameErrorText(name.value).isEmpty &&
        validPetAdditionalInfoErrorText(disease.value).isEmpty &&
        validPetAdditionalInfoErrorText(allergy.value).isEmpty)
      isEditPetOk(true);
    else
      isEditPetOk(false);
  }

  void editBackFunc(BuildContext context) {
    unFocus(context);
    showVfDialog(
        title: '수정을\n취소하시겠어요?',
        colorType: vfGradationColorType.Violet,
        isCancelButton: true,
        okFunc: () {
          Get.back();
          Get.back();
        });
  }

  void setBowl() {
    //메인펫의 보울 데이터를 보울컨트롤러에 담고, 섭취정보를 불러옴.
    Future.microtask(() async {
      await getBowlData();
      //보울 세팅
      final BowlPageController bowlPageController = Get.find();
      bowlPageController.updateFoodBowl();
      bowlPageController.updateWaterBowl();
    });
  }

  // GlobalData.mainPet.feed 초기화
  Future<void> resetFeed(Pet pet) async {
    if (pet.foodID != nullInt) {
      if (pet.foodID == -1) {
        pet.feed = await FeedDBHelper().getFeedData(pet.id);
        pet.feed!.feedID = -1;
      } else {
        if (pet.type == PET_TYPE_DOG) {
          pet.feed = GlobalData.dogFeedList.singleWhere((element) => element.feedID == pet.foodID);
        } else if (pet.type == PET_TYPE_CAT) {
          pet.feed = GlobalData.catFeedList.singleWhere((element) => element.feedID == pet.foodID);
        }
        pet.feed!.userID = pet.userId;
        pet.feed!.petID = pet.id;
      }
    }
  }

  // imageList 초기화
  void resetImageList(Pet pet) {
    List<PetPhotos> newImageList = [];
    newImageList.addAll(pet.petPhotos);
    for (int i = 0; i < pet.petPhotos.length; i++) {
      newImageList[pet.petPhotos[i].index] = pet.petPhotos[i];
    }
    pet.petPhotos = newImageList;
  }

//pet info 정보 보내기
  Future<void> petInsertOrModify({required int isCreate, required List<dynamic> imageList, required bool isAdd}) async {
    // 변수 셋팅
    int typeNum;
    int sexNum;
    int pregnantStateNum;
    int obesityStateNum;
    double recommendedIntake = 0; //칼로리 물 공통

    if (type.value == '강아지')
      typeNum = PET_TYPE_DOG;
    else if (type.value == '고양이')
      typeNum = PET_TYPE_CAT;
    else
      typeNum = PET_TYPE_ECT;

    if (sex.value == '남') {
      if (neutering.value == 'X')
        sexNum = MALE;
      else
        sexNum = NEUTERING_MALE;
    } else {
      if (neutering.value == 'X')
        sexNum = FEMALE;
      else
        sexNum = NEUTERING_FEMALE;
    }

    if (pregnantState.value == '임신')
      pregnantStateNum = PREGNANT;
    else if (pregnantState.value == '수유')
      pregnantStateNum = LACTATION;
    else
      pregnantStateNum = NONE;

    if (obesityState.value == '활동량 적음')
      obesityStateNum = WEIGHT_LOW_ACTIVITY;
    else if (obesityState.value == '비만')
      obesityStateNum = WEIGHT_OBESITY;
    else
      obesityStateNum = WEIGHT_NORMAL;

    GlobalData.mainPet.value.type = typeNum;
    GlobalData.mainPet.value.weight = weight.value;
    GlobalData.mainPet.value.sex = sexNum;
    GlobalData.mainPet.value.birthday = birthday.value;
    GlobalData.mainPet.value.foodID = foodID.value;
    GlobalData.mainPet.value.pregnantLactation = pregnantStateNum;
    GlobalData.mainPet.value.weightManage = obesityStateNum;

    //칼로리 물 공통.
    recommendedIntake = calRecommendedDaily(GlobalData.mainPet.value);

    for (int i = 0; i < imageList.length; i++) {
      if (imageList[i] is PetPhotos) {
        imageList[i].index = i;
      }
    }

    //사료 칼로리, 수분 계산
    int foodCalorie = 0;
    double foodWater = 0;
    if (foodID.value == -1) {
      //직접입력 사료일때
      Feed feed = await getFeedByFoodID(-1);
      foodCalorie = feed.calorie;
      foodWater = feed.water;
    } else {
      if (typeNum == PET_TYPE_DOG) {
        foodCalorie = GlobalData.dogFeedList.singleWhere((element) => element.feedID == foodID.value).calorie;
        foodWater = GlobalData.dogFeedList.singleWhere((element) => element.feedID == foodID.value).water;
      } else {
        foodCalorie = GlobalData.catFeedList.singleWhere((element) => element.feedID == foodID.value).calorie;
        foodWater = GlobalData.catFeedList.singleWhere((element) => element.feedID == foodID.value).water;
      }
    }

    // pet 서버에 전송할 데이터 셋팅
    FormData formData = FormData.fromMap({
      'userID': GlobalData.loggedInUser.value.userID,
      'index': GlobalData.petList.length,
      'type': typeNum,
      'name': name.value,
      'birthday': birthday.value,
      'kind': kind.value,
      'weight': weight.value,
      'sex': sexNum,
      'foodID': foodID.value,
      'foodCalorie': foodCalorie,
      'foodWater': foodWater,
      'disease': disease.value,
      'allergy': allergy.value,
      'isCreate': isCreate,
      'id': GlobalData.mainPet.value.id,
      'foodRecommendedIntake': recommendedIntake,
      'waterRecommendedIntake': recommendedIntake,
      'pregnantState': pregnantStateNum,
      'obesityState': obesityStateNum,
      'accessToken': GlobalData.accessToken
    });

    for (int i = 0; i < imageList.length; i++) {
      if (imageList[i] is File) {
        formData.files.add(MapEntry('images', MultipartFile.fromFileSync(imageList[i].path, filename: imageList[i].path.split('/').last)));
      }
    }

    if (isCreate == 0) {
      List<int> idList = [];
      for (int i = 0; i < imageList.length; i++) {
        if (imageList[i] is PetPhotos) {
          idList.add(imageList[i].id);
        }
      }

      // fileidlist는 유지할 기존 파일들의 id를 전송
      for (int i = 0; i < idList.length; i++) {
        formData.fields.add(MapEntry('fileidlist', idList[i].toString()));
      }

      // removeidlist는 지울 파일들의 id를 전송
      for (int i = 0; i < GlobalData.mainPet.value.petPhotos.length; i++) {
        if (!idList.contains(GlobalData.mainPet.value.petPhotos[i].id)) {
          formData.fields.add(MapEntry('removeidlist', GlobalData.mainPet.value.petPhotos[i].id.toString()));
        }
      }
    }

    // pet 서버에 데이터 전송
    try {
      vfLoadingDialog(); // 로딩 시작

      Dio dio = new Dio();
      var res = await dio.post(ApiProvider().getUrl + '/Pet/InsertOrModify', data: formData);
      Pet resPet = Pet.fromJson(json.decode(res.toString()));

      // db에서 기존 사료 삭제
      await FeedDBHelper().deleteData(resPet.id);

      // 직접 입력한 경우
      if (resPet.foodID == -1) {
        // 사료 정보 보내기
        await ApiProvider().post(
            '/Pet/Insert/UserCustomFood',
            jsonEncode({
              'userID': GlobalData.loggedInUser.value.userID,
              'brandName': feedChoiceController.customFeed.value.brandName,
              'koreaName': feedChoiceController.customFeed.value.koreaName,
              'englishName': feedChoiceController.customFeed.value.englishName,
              'perProtein': feedChoiceController.customFeed.value.perProtein,
              'perFat': feedChoiceController.customFeed.value.perFat,
              'carbohydrate': feedChoiceController.customFeed.value.crudeFiber,
              'water': feedChoiceController.customFeed.value.water,
              'calorie': feedChoiceController.customFeed.value.calorie,
            }));

        // 사료 정보 db에 담기
        feedChoiceController.customFeed.value.userID = resPet.userId;
        feedChoiceController.customFeed.value.petID = resPet.id;
        await FeedDBHelper().createData(feedChoiceController.customFeed.value);
      }

      resetFeed(resPet);
      resetImageList(resPet);

      final prefs = await SharedPreferences.getInstance();
      final FilterController filterController = Get.find<FilterController>();

      // 펫 리스트 동기화
      if(GlobalData.mainPet.value.kind != resPet.kind) {
        int overlapCount = 0; // 품종 중복 카운트

        // 품종 중복 체크
        GlobalData.petList.forEach((element) {
          if(element.kind == GlobalData.mainPet.value.kind) overlapCount++;
        });

        if(isCreate == 0 && overlapCount < 2) GlobalData.communityPetKinds.remove(GlobalData.mainPet.value.kind); // 수정일 때 기존 품종 삭제
        if(!GlobalData.communityPetKinds.contains(resPet.kind)) GlobalData.communityPetKinds.add(resPet.kind); // 품종이 포함되어있지 않다면 새로운 품종 추가
        if(isCreate == 0 && overlapCount < 2) GlobalData.myPetKinds.remove(GlobalData.mainPet.value.kind); // 수정일 때 기존 품종 삭제
        if(!GlobalData.myPetKinds.contains(resPet.kind)) GlobalData.myPetKinds.add(resPet.kind); // 품종이 포함되어있지 않다면 새로운 품종 추가
        filterController.communityPetKindCheckList = List.generate(GlobalData.communityPetKinds.length, (index) => false).obs; // boolList 세팅
        prefs.setStringList('communityPetKindList', GlobalData.communityPetKinds); // preference 세팅
      }

      if (isCreate == 0) {
        // 수정의 경우
        GlobalData.mainPet(resPet);
        GlobalData.petList[GlobalData.petList.indexWhere((element) => element.id == resPet.id)] = resPet;

        Get.back(); // endDrawer로
        Get.back(); // dashBoard로
      } else {
        if (isAdd == false) {
          // initiation의 경우
          resPet.advice = getCustomizedAdviceContents(resPet); // 수의사 한마디 세팅
          GlobalData.mainPet(resPet);
          GlobalData.petList.add(resPet);

          setBowl();

          Get.offAll(() => MainPage());
        } else {
          // add pet 의 경우
          resPet.advice = getCustomizedAdviceContents(resPet); // 수의사 한마디 세팅
          if (GlobalData.mainPet.value.id == nullInt) {
            GlobalData.mainPet(resPet);

            setBowl();
          }
          GlobalData.petList.add(resPet);

          Get.back(); // endDrawer로
          Get.back(); // dashBoard로
        }
      }

      DashBoardController.to.stateUpdate();

      if (isCreate == 0)
        Fluttertoast.showToast(
            msg: '반려동물 수정이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: Colors.white);
      else
        Fluttertoast.showToast(
            msg: '반려동물이 추가되었어요.', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: Colors.white);

      Get.back(); // 로딩 다이어로그 끄기
    } on DioError catch (e) {
      Get.back(); // 로딩 다이어로그 끄기

      if (isCreate == 0)
        Fluttertoast.showToast(
            msg: '반려동물 수정을 실패했습니다. 다시 시도해주세요.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
            textColor: Colors.white);
      else
        Fluttertoast.showToast(
            msg: '반려동물 추가에 실패했습니다. 다시 시도해주세요.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
            textColor: Colors.white);
      throw (e.message);
    }
  }
}
