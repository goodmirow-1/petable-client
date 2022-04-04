import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';

import '../../Config/GlobalWidget/GlobalWidget.dart';
import '../resister_bowl_page.dart';

class ResisterBowlPageController extends GetxController {
  static get to => Get.find<ResisterBowlPageController>();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  RxInt pageIndex = 0.obs;

  String stepNumber = '1';

  RxBool isCanNext = true.obs;

  RxBool isManual = false.obs; //수동입력여부

  RxString wifiName = ''.obs;
  String wifiID = '';
  String wifiPW = '';

  RxBool showPw = false.obs;

  RxBool isConnectWifi = false.obs;

  int petID = nullInt;
  int bowlType = nullInt; //0 밥그릇 1 물그릇

  final NetworkInfo _networkInfo = NetworkInfo();

  Future<void> initNetworkInfo() async {
    try {
      wifiName.value = await _networkInfo.getWifiName() ?? '연결된 와이파이가 없습니다.';
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      wifiName.value = 'error';
    }
    if (pageIndex.value == 0 && (wifiName.value == 'error' || wifiName.value != '연결된 와이파이가 없습니다.')) {
      isCanNext(true);
      isConnectWifi(true);
    } else {
      isConnectWifi(false);
    }
  }

  Future<bool> requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.request();

    initNetworkInfo();

    if (!status.isGranted) {
      // 허용이 안된 경우
      showVfDialog(
          title: "권한 설정을 확인해주세요.",
          colorType: vfGradationColorType.Violet,
          description: '와이파이 정보를 위해\n 위치 정보 권한이 필요합니다.',
          okFunc: () {
            openAppSettings();
          },
          okText: "설정하기"
      ).then((value) => initNetworkInfo());
      return false;
    }
    return true;
  }

  Future<bool> requestIosLocationPermission(BuildContext context) async {
    LocationPermission checkLocationPermission = await geolocatorPlatform.checkPermission();

    initNetworkInfo();

    if (checkLocationPermission == LocationPermission.denied || checkLocationPermission == LocationPermission.deniedForever) {
      LocationPermission permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        showVfDialog(
          title: "권한 설정을 확인해주세요.",
          colorType: vfGradationColorType.Violet,
          description: '와이파이 정보를 위해\n 위치 정보 권한이 필요합니다.',
          okFunc: () {
              openAppSettings();
          },
          okText: "설정하기"
        ).then((value) => initNetworkInfo());
        return false;
      }
    }

    return true;
  }

  Future<bool> checkDeviceWifi() async {
    String _wifiName = '';
    if (isManual.value) {
      return true;
    } else {
      try {
        _wifiName = await _networkInfo.getWifiName() ?? 'error';
      } on PlatformException catch (e) {
        debugPrint(e.toString());
        _wifiName = 'Failed to get Wifi Name';
      }
    }

    if (_wifiName == 'MyBowl') {
      return true;
    } else {
      return false;
    }
  }

  connection() async {
    var uri = Uri.parse('http://192.168.4.1:8888/id=$petID&type=$bowlType&ip=$wifiID&pwd=$wifiPW');

    send() async {
      bool isOK = await checkDeviceWifi();
      if (isOK) {
        try {
          await http.Client().get(uri);
        } on SocketException {}
      }
    }

    send();
  }

  void pageChangeFunc(int index) async {
    pageIndex.value = index;
    switch (pageIndex.value) {
      case 0:
        {
          isCanNext(false);
          initNetworkInfo();
          if (pageIndex.value == 0 && (wifiName.value == 'error' || wifiName.value != '연결된 와이파이가 없습니다.')) {
            isCanNext(true);
          }
        }
        break;
      case 1:
        isCanNext(true);
        break;
      case 2:
        isCanNext(true);
        break;
      case 3:
        {
          isCanNext(isManual.value ? true : await checkDeviceWifi());
        }
        break;
      case 4:
        isCanNext(true);
        break;
      case 5:
        isCanNext(true);
        break;
      case 6:
        isCanNext(true);
        break;
      case 7:
        isCanNext(true);
        break;
      case 8:
        isCanNext(true);
        break;
    }
  }

  void successRegistrationDevice() async {
    // 펫 보울 데이터 가져오기
    var res = await ApiProvider().post(
        '/Bowl/Select/BowlInfo',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    var tmpPets = res['Pets'] as List;

    List<Pet> listPet = [];

    for (int i = 0; i < tmpPets.length; i++) {
      listPet.add(Pet.fromJson(tmpPets[i]));
    }

    listPet.forEach((pet) {
      GlobalData.petList.forEach((globalPet) {
        if (globalPet.id == pet.id) {
          globalPet.foodBowl = pet.foodBowl;
          globalPet.waterBowl = pet.waterBowl;
        }
      });
      if (GlobalData.mainPet.value.id == pet.id) {
        GlobalData.mainPet.value.foodBowl = pet.foodBowl;
        GlobalData.mainPet.value.waterBowl = pet.waterBowl;
      }
    });

    //메인펫의 보울 데이터를 보울컨트롤러에 담음.
    Future.microtask(() async {
      getBowlData();
      //보울 세팅
      final BowlPageController bowlPageController = Get.put(BowlPageController());
      bowlPageController.updateFoodBowl();
      bowlPageController.updateWaterBowl();
    });
  }

  // 저울세팅 체크
  void checkScaleInitialize() async {
    vfLoadingDialog(); // 로딩

    bool isOk = true;
    // 펫 보울 데이터 가져오기
    var res = await ApiProvider().post(
        '/Bowl/Select/BowlInfo',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    var tmpPets = res['Pets'] as List;

    List<Pet> listPet = [];

    for (int i = 0; i < tmpPets.length; i++) {
      listPet.add(Pet.fromJson(tmpPets[i]));
    }

    //그릇 무게 정상적으로 들어왔는지 확인
    for (int i = 0; i < listPet.length; i++) {
      if (listPet[i].id == GlobalData.mainPet.value.id) {
        if (bowlType == 0) {
          //밥그릇이면
          //그릇 있는지 확인
          if (listPet[i].foodBowl != null) {
            //그릇 무게 잘 들어왔는지 확인
            if (listPet[i].foodBowl!.bowlWeight == nullDouble) {
              isOk = false;
            }
          } else {
            isOk = false;
          }
        } else if (bowlType == 1) {
          //물그릇이면
          //그릇 있는지 확인
          if (listPet[i].waterBowl != null) {
            //그릇 무게 잘 들어왔는지 확인
            if (listPet[i].waterBowl!.bowlWeight == nullDouble) {
              isOk = false;
            }
          } else {
            isOk = false;
          }
        }
        break;
      }
    }
    if (!isOk) {
      Get.back(); // 로딩 끝

      //그릇 무게 측정 실패 알림
      showVfDialog(
          title: '저울 설정 실패',
          colorType: vfGradationColorType.Violet,
          description: '저울 설정이 정상적으로 완료되지 않았습니다.\n다시 시도하시겠어요?',
          isCancelButton: true,
          okText: '다시하기',
          okFunc: () {
            Get.back();
            pageIndex(6);
            ResisterBowlPage.pageController.animateToPage(6, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          });

      return;
    }

    listPet.forEach((pet) {
      GlobalData.petList.forEach((globalPet) {
        if (globalPet.id == pet.id) {
          globalPet.foodBowl = pet.foodBowl;
          globalPet.waterBowl = pet.waterBowl;
        }
      });
      if (GlobalData.mainPet.value.id == pet.id) {
        GlobalData.mainPet.value.foodBowl = pet.foodBowl;
        GlobalData.mainPet.value.waterBowl = pet.waterBowl;
      }
    });

    //메인펫의 보울 데이터를 보울컨트롤러에 담음.
    await getBowlData();
    //보울 세팅
    final BowlPageController bowlPageController = Get.put(BowlPageController());
    bowlPageController.updateFoodBowl();
    bowlPageController.updateWaterBowl();

    Get.back(); // 로딩 끝
    Get.back(); // 보울등록페이지 종료
  }
}
