import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';

class NavigationController extends GetxController {
  static get to => Get.find<NavigationController>();

  final Duration shortDuration = Duration(milliseconds: 200); // 펫 사진 duration
  final Duration longDuration = Duration(milliseconds: 300); // 펫 담은 컨테이너 duration

  RxDouble yOffset = Get.height.obs; // pet 박스 y 위치 값

  int currentIndex = 0;
  int previousIndex = 0;
  RxBool activePet = false.obs; // 펫 활성화 여부
  RxBool activeAnimation = false.obs; // 애니메이션 활성화 여부
  RxBool petChangeAnimation = false.obs; // 펫 체인지 애니메이션 활성화 여부
  Rx<Color> navItemColor = vfColorPink.obs; // 네비게이션 아이콘 컬러
  RxList<Color> navPetColors = navVioletColorList.obs; // 펫 컬러
  bool playingNavAnimation = false; // 펫 애니메이션 돌아가고 있는지

  // set nav item color
  void setColor() {
    switch (currentIndex) {
      case 0: // HOME
        navItemColor = vfColorPink.obs;
        navPetColors = navVioletColorList.obs;
        break;
      case 1: // GRAPH
        navItemColor = vfColorOrange.obs;
        navPetColors = navRedColorList.obs;
        break;
      case 3: // BOWL
        navItemColor = vfColorOrange.obs;
        navPetColors = navRedColorList.obs;
        break;
      case 4: // COMMUNITY
        navItemColor = vfColorPink.obs;
        navPetColors = navVioletColorList.obs;
        break;
    }
  }

  // 네비게이션 색 바꾸는 함수
  void changeNavColor({required Color itemColor, required List<Color> petColors}) {
    navItemColor(itemColor);
    navPetColors.value = petColors.obs;
  }

  // 네비게이션 index 바꾸는 함수
  void changeNavIndex(int index){
    previousIndex = currentIndex;
    currentIndex = index;

    if (currentIndex != previousIndex) setColor();
    update();
  }

  // 펫 토글 함수
  void togglePetFunc(RenderBox box) {
    final Offset pos = box.localToGlobal(Offset.zero);

    if(playingNavAnimation) {
      return;
    } else {
      playingNavAnimation = true;
    }

    if (!activePet.value) {
      activePet(!activePet.value);
      yOffset(pos.dy - 56 * sizeUnit - devicePadding.top); // 펫 컨테이너 올리기

      Timer(longDuration, () {
        activeAnimation(!activeAnimation.value); // 펫 컨테이너 길어지게
        playingNavAnimation = false;
      });
    } else {
      offPetFunc();
    }
  }

  // 펫 끄는 함수
  void offPetFunc() {
    activePet(false);
    activeAnimation(false); // 펫 컨테이너 줄어들게

    Timer(longDuration, () {
      yOffset(Get.height); // 펫 컨테이너 내리기
      playingNavAnimation = false;
    });
  }

  // 메인 펫 바꾸는 함수
  Future<void> changePet(Pet pet) async {
    final DashBoardController dashBoardController = Get.find<DashBoardController>();
    final GraphPageController graphPageController = Get.find<GraphPageController>();

    List<Color> loadingColors = loadingVioletColorList;

    if (navPetColors[0] == navVioletColorList[0]) {
      loadingColors = loadingVioletColorList;
    } else if (navPetColors[0] == navRedColorList[0]) {
      loadingColors = loadingRedColorList;
    } else if (navPetColors[0] == navBlueColorList[0]) {
      loadingColors = loadingBlueColorList;
    }

    vfLoadingDialog(colorList: loadingColors); // 로딩 시작

    GlobalData.mainPet(pet);

    // 애니메이션 duration 조절용
    petChangeAnimation(true);
    Timer(shortDuration, () {
      petChangeAnimation(false);
    });

    await dashBoardController.getTodayFillFeed(); // 오늘 배급 시간
    dashBoardController.graphStatus(GRAPH_STATUS.ACHIEVEMENT_RATE); // 섭취달성 그래프로 변경

    dashBoardController.stateUpdate(); // GetBuilder update

    Get.back(); // 로딩 다이어로그 끄기

    //메인펫의 보울 데이터를 보울컨트롤러에 담고, 섭취정보를 불러옴.
    Future.microtask(() async {
      GlobalData.backLoading(true); // 로딩 시작

      await getBowlData();
      //보울 세팅
      final BowlPageController bowlPageController = Get.find();
      bowlPageController.updateFoodBowl();
      bowlPageController.updateWaterBowl();

      //섭취 데이터 세팅
      await intakeDataSetting();

      await graphPageController.setGraph(setIntake: false, setSnack: false); // 그래프 세팅

      GlobalData.backLoading(false); // 로딩 끝
    });
  }
}
