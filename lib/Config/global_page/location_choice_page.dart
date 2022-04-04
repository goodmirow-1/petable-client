import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Data/location.dart';

class LocationChoicePage extends StatefulWidget {
  const LocationChoicePage({Key? key}) : super(key: key);

  @override
  _LocationChoicePageState createState() => _LocationChoicePageState();
}

class _LocationChoicePageState extends State<LocationChoicePage> {
  final TextEditingController locationEditingController = TextEditingController();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  double myLatitude = nullDouble;
  double myLongtitude = nullDouble;
  bool isPermission = false;
  bool isLoading = false;
  List<LocationData> showList = [];
  List<LocationData> compressList = [];
  List<LocationData> searchList = [];
  Timer? debounce;

  @override
  void initState() {
    Future.microtask(() async {
      isPermission = await _handlePermission(false);
      setState(() {
        if (isPermission) {
          Get.back();
        }
        if (isLoading == true) isLoading = false;
      });
    });

    locationEditingController.addListener(() {
      _onSearchChanged(locationEditingController.text);
    });

    super.initState();
  }

  @override
  void dispose() {
    locationEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  _onSearchChanged(String text) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (text.length == 0) {
          searchList.clear();
        } else {
          searchList = globalLocationDataList.where((element) => element.name.contains(text)).toList();
        }
      });
    });
  }

  _checkDialog() {
    showVfDialog(
      title: '위치정보 이용에 대한 액세스 권한이 없어요',
      description: '설정 앱에서 권한을 수정할 수 있어요.',
      colorType: vfGradationColorType.Violet,
      isCancelButton: true,
      okFunc: () async {
        Get.back();

        AppSettings.openLocationSettings();
      },
    );
  }

  Future<bool> _handlePermission(bool mustDo) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkDialog();
      return false;
    }

    permission = await geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        _checkDialog();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _checkDialog();
      return false;
    }

    vfLoadingDialog(text: '지역 정보를 불러오는 중입니다...');
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    myLatitude = prefs.getDouble('myLatitude') ?? nullDouble;
    myLongtitude = prefs.getDouble('myLongtitude') ?? nullDouble;

    if (mustDo == true || (myLatitude == nullDouble && myLongtitude == nullDouble)) {
      final Position position = await geolocatorPlatform.getCurrentPosition();

      myLatitude = position.latitude;
      myLongtitude = position.longitude;

      prefs.setDouble('myLatitude', myLatitude);
      prefs.setDouble('myLongtitude', myLongtitude);
    }

    if (myLatitude == nullDouble && myLongtitude == nullDouble) {
      //인천광역시 송도3동
      myLatitude = 37.38210673994046;
      myLongtitude = 126.66227018861542;


      myLatitude = 37.3322;
      myLongtitude =  -122.0110;
    }

    compressList = globalLocationDataList.where((element) => (myLatitude - element.latitude).abs() <= 0.25 && (myLongtitude - element.longitude).abs() <= 0.25).toList();

    if (compressList.length == 0) {
      Fluttertoast.showToast(
        msg: '위치 정보를 불러올 수 없습니다.\n 기본 값으로 설정됩니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );

      showList.add(globalLocationDataList.singleWhere((element) => element.name == '인천광역시 연수구 송도3동'));
    } else {
      int findIndex = 0;
      compressList[findIndex].distance = geolocatorPlatform.distanceBetween(myLatitude, myLongtitude, compressList[findIndex].latitude, compressList[findIndex].longitude);

      for (int i = 1; i < compressList.length; ++i) {
        compressList[i].distance = geolocatorPlatform.distanceBetween(myLatitude, myLongtitude, compressList[i].latitude, compressList[i].longitude);
        //가장가까운 데이터 찾
        if (compressList[findIndex].distance > compressList[i].distance) {
          findIndex = i;
        }

        //1km미만
        if (compressList[i].distance < 10000) {
          showList.add(compressList[i]);
        }
      }

      if (showList.length > 2) {
        showList.sort((a, b) => a.distance.compareTo(b.distance));
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(
            context,
            title: '지역 선택',
          ),
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit, bottom: 16 * sizeUnit),
            child: Column(
              children: [
                locationSearchText(),
                SizedBox(
                  height: 16 * sizeUnit,
                ),
                locationSearchCurrent(),
                if (isPermission) ...[
                  if (locationEditingController.text == "") ...[
                    SizedBox(
                      height: 24 * sizeUnit,
                    ),
                    showLocationList(showList)
                  ] else ...[
                    if (searchList.length != 0) ...[
                      SizedBox(
                        height: 24 * sizeUnit,
                      ),
                      showLocationList(searchList)
                    ] else ...[
                      SizedBox(
                        height: 112 * sizeUnit,
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          vfBetiBodyBadStateWidget(),
                          SizedBox(
                            height: 16 * sizeUnit,
                          ),
                          Text(
                            '검색 결과가 없어요!',
                            style: VfTextStyle.subTitle2(),
                          ),
                        ],
                      ))
                    ]
                  ],
                ] else ...[
                  if (locationEditingController.text == "") ...[
                    SizedBox(
                      height: 112 * sizeUnit,
                    ),
                    if (false == isLoading) ...[
                      Expanded(
                          child: Column(
                        children: [
                          vfBetiBodyBadStateWidget(),
                          SizedBox(
                            height: 16 * sizeUnit,
                          ),
                          Text(
                            '현재 위치로 동네를 받아오지 못했어요\n' + '내 동네를 검색해 주세요',
                            textAlign: TextAlign.center,
                            style: VfTextStyle.body1(),
                          ),
                        ],
                      ))
                    ]
                  ] else if (locationEditingController.text != "" && searchList.length == 0) ...[
                    SizedBox(
                      height: 112 * sizeUnit,
                    ),
                    if (false == isLoading) ...[
                      Expanded(
                          child: Column(
                        children: [
                          vfBetiBodyBadStateWidget(),
                          SizedBox(
                            height: 16 * sizeUnit,
                          ),
                          Text(
                            '검색 결과가 없어요!',
                            style: VfTextStyle.subTitle2(),
                          ),
                        ],
                      ))
                    ]
                  ] else ...[
                    SizedBox(
                      height: 24 * sizeUnit,
                    ),
                    showLocationList(searchList)
                  ]
                ]
              ],
            ), // 검색 결과가 없을 땐 강아지 고양이 아이콘 있는 페이지 표시
          ),
        ),
      ),
    );
  }

  Widget locationSearchText() {
    // 전체 지역을 리스트에 담아줌
    return vfTextField(
      textEditingController: locationEditingController,
      hintText: '동명(읍,면)으로 검색 가능',
      borderColor: Colors.transparent,
      suffixIcon: IconButton(
          // 아이콘을 눌렀는지 여부에 따라 아이콘 색상 구별
          icon: locationEditingController.text == "" ? SvgPicture.asset(svgMagnifyingGlassGray) : SvgPicture.asset(svgMagnifyingGlassBlack),
          onPressed: null),
      onChanged: (value) {},
    );
  }

  Widget locationSearchCurrent() {
    return Container(
      padding: EdgeInsets.all(1 * sizeUnit),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28 * sizeUnit),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0)],
          )),
      child: InkWell(
        borderRadius: BorderRadius.circular(28 * sizeUnit),
        onTap: () {
          Future.microtask(() async {
            locationEditingController.clear();
            showList.clear();
            isPermission = await _handlePermission(true);
            setState(() {
              if (isPermission == true) {
                Get.back();
              }
              if (isLoading == true) isLoading = false;
            });
          });
        },
        child: Container(
          width: double.infinity,
          height: 36 * sizeUnit,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28 * sizeUnit),
            gradient: LinearGradient(colors: gradationColorList(vfGradationColorType.Violet, 'button')),
            boxShadow: vfBasicBoxShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/image/Global/location.svg'),
              Text(" 현재 위치로 찾기", style: VfTextStyle.subTitle2().copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget showLocationList(List<LocationData> list) {
    if (isLoading) return SizedBox.shrink();

    if (list.length < 10) {
      return Container(
        height: list.length * 48 * sizeUnit,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          color: Color.fromRGBO(255, 255, 255, 0.8),
          boxShadow: vfBasicBoxShadow,
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Center(
                  // 지역 첫번째 페이지에서는 화살표가 있고, 두번째 페이지이거나 검색할 때는 화살표가 없음
                  child: ListTile(
                      title: Text(
                        list[index].name,
                        style: VfTextStyle.body1().copyWith(height: 1.0),
                      ),
                      trailing: SvgPicture.asset(svgRightArrow))),
              onTap: () {
                Get.back(result: list[index].name);
              },
            );
          },
          separatorBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit),
              child: Container(
                height: 1 * sizeUnit,
                color: vfColorGrey,
              ),
            );
          },
          itemCount: list.length,
          shrinkWrap: true,
        ),
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          color: Color.fromRGBO(255, 255, 255, 0.8),
          boxShadow: vfBasicBoxShadow,
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Center(
                  // 지역 첫번째 페이지에서는 화살표가 있고, 두번째 페이지이거나 검색할 때는 화살표가 없음
                  child: ListTile(
                      title: Text(
                        list[index].name,
                        style: VfTextStyle.body1().copyWith(height: 1.0),
                      ),
                      trailing: SvgPicture.asset(svgRightArrow))),
              onTap: () {
                Get.back(result: list[index].name);
              },
            );
          },
          separatorBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit),
              child: Container(
                height: 1 * sizeUnit,
                color: vfColorGrey,
              ),
            );
          },
          itemCount: list.length,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
