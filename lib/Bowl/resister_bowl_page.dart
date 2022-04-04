import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/twinkle_light_breath_widget.dart';
import 'package:myvef_app/Config/GlobalWidget/twinkle_light_widget2.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'Controller/resister_bowl_page_controller.dart';

class ResisterBowlPage extends StatelessWidget {
  final int type; //0 밥그릇, 1 물그릇
  final bool isReset;

  ResisterBowlPage({required this.type, this.isReset = false});

  final ResisterBowlPageController _controller = Get.put(ResisterBowlPageController());
  static PageController pageController = PageController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final TextEditingController _wifiIDEditingController = TextEditingController();
  final Duration _duration = Duration(milliseconds: 500);
  final Curve _curve = Curves.easeInOut;

  final String svgBowlWifiSelect = 'assets/image/bowl/bowlWifiSelect.png'; // 보울 와이파이 선택

  void backFunc() {
    switch (_controller.pageIndex.value) {
      case 0:
        GlobalData.isResisterBowl = false;
        Get.back();
        break;
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        pageController.previousPage(duration: _duration, curve: _curve);
        break;
      case 6:
        showVfDialog(
          title: '저울 초기화를\n취소하시겠어요?',
          description: '첫 사용, 건전지 교체, 와이파이정보 변경 시 저울 초기화를 진행해야 사용하실 수 있습니다.',
          colorType: vfGradationColorType.Red,
          okFunc: () {
            GlobalData.isResisterBowl = false;
            Get.back();
            Get.back();
          },
          isCancelButton: true,
        );
        break;
      case 7:
      case 8:
      case 9:
        pageController.previousPage(duration: _duration, curve: _curve);
        break;
    }
  }

  void bottomButtonTap(BuildContext context) async {
    switch (_controller.pageIndex.value) {
      case 0:
        _controller.wifiPW = _passwordEditingController.text;
        if (_controller.isManual.value) {
          _controller.wifiID = _wifiIDEditingController.text;
        } else {
          _controller.wifiID = _controller.wifiName.value;
        }
        debugPrint(_controller.wifiID + ' ' + _controller.wifiPW);

        //와이파이 이름에 5G가 포함된 경우 다이얼로그
        if(_controller.wifiID.contains('5G')){
          showVfDialog(
            title: '연결된 Wi-Fi를\n확인해 주세요.',
            colorType: vfGradationColorType.Red,
            description: 'Wi-Fi 이름에 5G가 포함되어 있어요!\n일반 Wi-Fi라면 넘어가기를 눌러주세요.',
            okText: '확인하기',
            okFunc: (){
              Get.back();
            },
            isCancelButton: true,
            cancelText: '넘어가기',
            cancelFunc: (){
              Get.back();
              pageController.nextPage(duration: _duration, curve: _curve);
            },
          );
        } else {
          pageController.nextPage(duration: _duration, curve: _curve);
        }
        break;
      case 1:
      case 2:
        pageController.nextPage(duration: _duration, curve: _curve);
        break;
      case 3:
        bool isRight = await _controller.checkDeviceWifi();
        if (isRight) {
          _controller.connection();
          //서버에 기기등록
          pageController.nextPage(duration: _duration, curve: _curve);
        } else {
          Get.snackbar('title', '와이파이 연결 확인');
        }
        break;
      case 4:
        pageController.nextPage(duration: _duration, curve: _curve);
        break;
      case 5:
        pageController.nextPage(duration: _duration, curve: _curve);
        _controller.successRegistrationDevice();
        break;
      case 6:
        pageController.nextPage(duration: _duration, curve: _curve);
        break;
      case 7:
        pageController.nextPage(duration: _duration, curve: _curve);
        break;
      case 8:
        pageController.nextPage(duration: _duration, curve: _curve);
        break;
      case 9:
        _controller.checkScaleInitialize();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalData.isResisterBowl = true;
    if (isReset) {
      _controller.pageIndex.value = 6;
      pageController = PageController(initialPage: 6);
    } else {
      _controller.pageIndex.value = 0;
      pageController = PageController(initialPage: 0);
    }

    _controller.bowlType = type;
    _controller.petID = GlobalData.mainPet.value.id;
    if (Platform.isAndroid) {
      //권한 요청
      _controller.requestLocationPermission(context);
    } else {
      _controller.requestIosLocationPermission(context);
    }
    _controller.initNetworkInfo(); //와이파이 정보 가져오기

    return baseWidget(
      context,
      type: 5,
      colorType: vfGradationColorType.Red,
      blur: 80 * sizeUnit,
      onWillPop: () {
        backFunc();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: vfAppBar(
          context,
          backFunc: () => backFunc(),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  _controller.pageChangeFunc(index);
                },
                children: [
                  page0(context),
                  page1(),
                  page2(),
                  page3(),
                  page4(),
                  page5(),
                  page6_0(),
                  page6_1(),
                  page6(),
                  page7(),
                ],
              ),
            ),
            Obx(() {
              String text = '';
              switch (_controller.pageIndex.value) {
                case 5:
                  text = '등록 완료';
                  break;
                case 7:
                  text = '다음';
                  break;
                case 9:
                  text = '완료';
                  break;
                default:
                  text = '다음';
                  break;
              }
              return vfGradationButton(
                text: text,
                colorType: vfGradationColorType.Red,
                isOk: _controller.isCanNext.value,
                onTap: () {
                  unFocus(context);
                  bottomButtonTap(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget page0(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unFocus(context);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20 * sizeUnit),
            Obx(() => Column(
                  children: [
                    Text.rich(
                      TextSpan(text: '', children: [
                        TextSpan(
                          text: 'Wi-Fi',
                          style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
                        ),
                        TextSpan(text: '에 연결해주세요.\n5G Wi-Fi는 사용할 수 없어요!'),
                      ]),
                      style: VfTextStyle.headline4(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60 * sizeUnit),
                    if (_controller.isManual.value) ...[
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 32 * sizeUnit),
                            child: Text('WiFi ID', style: VfTextStyle.subTitle4()),
                          ),
                        ],
                      ),
                      SizedBox(height: 7 * sizeUnit),
                      Container(
                        width: 312 * sizeUnit,
                        child: vfTextField(
                          textEditingController: _wifiIDEditingController,
                          hintText: 'WiFi ID 입력',
                          onChanged: (text) {
                            if (text.isEmpty)
                              _controller.isCanNext(false);
                            else
                              _controller.isCanNext(true);
                          },
                        ),
                      ),
                      SizedBox(height: 40 * sizeUnit),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 32 * sizeUnit),
                            child: Text('비밀번호', style: VfTextStyle.subTitle4()),
                          ),
                        ],
                      ),
                      SizedBox(height: 7 * sizeUnit),
                      Container(
                        width: 312 * sizeUnit,
                        child: vfTextField(
                          textEditingController: _passwordEditingController,
                          hintText: 'WiFi 비밀번호 입력',
                          obscureText: !_controller.showPw.value,
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14 * sizeUnit, vertical: 15 * sizeUnit),
                            child: GestureDetector(
                              onTap: () => _controller.showPw(!_controller.showPw.value),
                              child: SvgPicture.asset(
                                _controller.showPw.value ? 'assets/image/Login/openedEyeIcon.svg' : 'assets/image/Login/closedEyeIcon.svg',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else if (_controller.wifiName.value == '연결된 와이파이가 없습니다.') ...[
                      Text(
                        '현재 연결된 Wi-Fi가 없어요!',
                        style: VfTextStyle.subTitle1(),
                      ),
                    ] else ...[
                      Text(
                        '현재 연결된 Wi-Fi는',
                        style: VfTextStyle.subTitle1(),
                      ),
                      Text(
                        _controller.wifiName.value,
                        style: VfTextStyle.highlight3(),
                      ),
                      SizedBox(height: 40 * sizeUnit),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 32 * sizeUnit),
                            child: Text('비밀번호', style: VfTextStyle.subTitle4()),
                          ),
                        ],
                      ),
                      SizedBox(height: 7 * sizeUnit),
                      Container(
                        width: 312 * sizeUnit,
                        child: vfTextField(
                          textEditingController: _passwordEditingController,
                          hintText: 'WiFi 비밀번호 입력',
                          obscureText: !_controller.showPw.value,
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14 * sizeUnit, vertical: 15 * sizeUnit),
                            child: GestureDetector(
                              onTap: () => _controller.showPw(!_controller.showPw.value),
                              child: SvgPicture.asset(
                                _controller.showPw.value ? 'assets/image/Login/openedEyeIcon.svg' : 'assets/image/Login/closedEyeIcon.svg',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 40 * sizeUnit),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_controller.isManual.value) ...[
                          GestureDetector(
                            onTap: () {
                              AppSettings.openWIFISettings();
                              int i = 0;
                              void _checkWifi() {
                                Future.delayed(Duration(milliseconds: 500), () {
                                  _controller.initNetworkInfo();
                                  if (i < 100) {
                                    _checkWifi();
                                    i++;
                                  } else {
                                    i = 0;
                                  }
                                });
                              }

                              _checkWifi();
                            },
                            child: Container(
                              width: 69 * sizeUnit,
                              height: 30 * sizeUnit,
                              decoration: BoxDecoration(
                                color: vfColorOrange,
                                borderRadius: BorderRadius.circular(30 * sizeUnit),
                              ),
                              child: Center(
                                child: Text(
                                  _controller.wifiName.value == '연결된 와이파이가 없습니다.' ? 'WiFi 연결' : 'WiFi 변경',
                                  style: VfTextStyle.subTitle5().copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (_controller.wifiName.value == '연결된 와이파이가 없습니다.') ...[
                          SizedBox(width: 16 * sizeUnit),
                          GestureDetector(
                            onTap: () {
                              _controller.isManual.value = !_controller.isManual.value;
                              if (_wifiIDEditingController.text.isEmpty) {
                                _controller.isCanNext.value = false;
                              } else {
                                _controller.isCanNext.value = true;
                              }
                            },
                            child: Container(
                              width: 69 * sizeUnit,
                              height: 30 * sizeUnit,
                              decoration: BoxDecoration(
                                color: vfColorOrange,
                                borderRadius: BorderRadius.circular(30 * sizeUnit),
                              ),
                              child: Center(
                                child: Text(
                                  _controller.isManual.value ? '취소하기' : '수동 입력',
                                  style: VfTextStyle.subTitle5().copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 40 * sizeUnit),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              'Wi-Fi 연결 후 앱으로 다시 돌아와주세요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange)),
                            Text(
                              '5GHz인 경우, 우에 Wi-Fi 변경버튼을 눌러\n일반 Wi-Fi로 바꿔주세요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              '일반 Wi-Fi는 2.4GHz를 사용하는 Wi-Fi에요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              '집에서 사용하는 Wi-Fi를 사용해 주세요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40 * sizeUnit),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget page1() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#1 ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                text: '마이보울 아래에\n'
              ),
              TextSpan(
                text: '건전지',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: '를 넣어주세요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '전원이 들어오면, 불이 들어와요!',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottomDetail,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLight2(
                  onOffTime: [],
                  top: 57 * sizeUnit,
                  left: 64.5 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '불빛이 들어오면\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '불빛이 들어오지 않는 경우, 전원이 들어오지\n않은 상태입니다. 건전지 상태를 확인해 주세요!',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '여러대를 등록하는 경우, 한 기기 씩 진행해주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#2 ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '마이보울 아래에 설정버튼을\n한번만 '
              ),
              TextSpan(
                text: '\'딸깍\'',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: ' 눌러주세요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '불빛이 깜박이기 시작할거에요!',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottom,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLightBreath(
                  duration: 1000,
                  top: 58.3 * sizeUnit,
                  left: 66.3 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '불빛이 위와 같이 깜박인다면\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '버튼을 길게 5초간 누르는 경우, 초기화돼요!',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '불빛이 2번 깜박이고 1초 쉬는 경우라면,\n건전지가 부족해서 기기가 Wi-Fi를 켜지 못한 거에요.\n건전지를 교체하고 다시 시도해주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page3() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Obx(() => Column(
                children: [
                  if (_controller.wifiName.value != 'MyBowl') ...[
                    Text.rich(
                      TextSpan(text: '', children: [
                        TextSpan(
                          text: '#3 ',
                          style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
                        ),
                        TextSpan(
                            text: 'Wi-Fi 목록에서\n마이보울에 '
                        ),
                        TextSpan(
                          text: '연결',
                          style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
                        ),
                        TextSpan(text: '해주세요.'),
                      ]),
                      style: VfTextStyle.headline4(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    Text(
                      _controller.isManual.value ? '아래의 버튼을 눌러 \"MyBowl\"에\n연결한 후, 앱으로 다시 돌아와주세요.' : '\"MyBowl\"에 연결한 후\n앱으로 다시 돌아와주세요.',
                      style: VfTextStyle.body1(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * sizeUnit),
                    GestureDetector(
                      onTap: () {
                        AppSettings.openWIFISettings();
                        int i = 0;
                        void _checkWifi() {
                          Future.delayed(Duration(milliseconds: 500), () {
                            _controller.initNetworkInfo();
                            if (_controller.wifiName.value != 'MyBowl' && i < 100) {
                              _checkWifi();
                              i++;
                            } else {
                              _controller.isCanNext(true);
                              i = 0;
                            }
                          });
                        }

                        _checkWifi();
                      },
                      child: Container(
                        width: 94 * sizeUnit,
                        height: 30 * sizeUnit,
                        decoration: BoxDecoration(
                          color: vfColorOrange,
                          borderRadius: BorderRadius.circular(30 * sizeUnit),
                        ),
                        child: Center(
                          child: Text(
                            'MyBowl 연결',
                            style: VfTextStyle.subTitle5().copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 56 * sizeUnit),
                    Container(
                      width: 328 * sizeUnit,
                      height: 262 * sizeUnit,
                      child: Image.asset(
                        svgBowlWifiSelect,
                        width: 328 * sizeUnit,
                        height: 262 * sizeUnit,
                      ),
                    ),
                    SizedBox(height: 56 * sizeUnit),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              '\"MyBowl\"이 뜨지 않는 경우, 이전 과정을 다시 확인해주세요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        if (_controller.isManual.value) ...[
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '현재 Wi-Fi 환경이 바뀌면, 다시 설정해야해요.',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 60 * sizeUnit),
                  ] else ...[
                    SizedBox(height: Get.height * 0.25),
                    Text.rich(
                      TextSpan(text: '마이보울에 ', children: [
                        TextSpan(
                          text: '연결',
                          style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
                        ),
                        TextSpan(text: '되었어요!\n다음을 눌러주세요.'),
                      ]),
                      style: VfTextStyle.headline4(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * sizeUnit),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              '전 세계 어디에서든 마이보울 정보를 볼 수 있어요!',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * sizeUnit),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                            Text(
                              '현재 Wi-Fi 환경이 바뀌면, 다시 설정해야해요.',
                              style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              )),
        ],
      ),
    );
  }

  Widget page4() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#4 ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '마이보울 '
              ),
              TextSpan(
                text: '등록 중',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: '이에요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '아래와 같이 깜박이며, 등록중이에요.\n 최대 1분 정도 걸릴 수 있어요!',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottom,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLight2(
                  onOffTime: [200, 200],
                  top: 57 * sizeUnit,
                  left: 64.5 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '깜박임이 바뀌면, 등록완료!\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '설정 시간은 최대 1분 정도 소요될 수 있어요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '1분 넘게 깜박거린다면, 다음 단계에서\n재등록을 눌러 처음부터 다시 진행해 주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page5() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#5 ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '마이보울 '
              ),
              TextSpan(
                text: '등록 완료',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: '!'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '아래와 같이 깜박인다면, 등록 완료에요.',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottom,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLight2(
                  onOffTime: [50, 800],
                  top: 57 * sizeUnit,
                  left: 64.5 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '마이보울 설정을 위해\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '위와 깜박임이 다르다면, 설정에 실패한거에요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '아래의 재등록 버튼을 눌러 진행해 주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 24 * sizeUnit),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => ConnectFailPage())!.then((value) {
                if (value != null) {
                  if (value[0] == true) {
                    pageController.animateToPage(0, duration: _duration, curve: _curve);
                  }
                }
              });
            },
            child: Container(
              width: 52 * sizeUnit,
              height: 30 * sizeUnit,
              decoration: BoxDecoration(
                color: vfColorOrange,
                borderRadius: BorderRadius.circular(15 * sizeUnit),
              ),
              child: Center(
                child: Text(
                  '재등록',
                  style: VfTextStyle.subTitle5().copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page6_0() {
    if(isReset){
      _controller.stepNumber = '1';
    } else{
      _controller.stepNumber = '6';
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#' + _controller.stepNumber + ' ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '마이보울 아래 설정버튼을\n한번만 '
              ),
              TextSpan(
                text: '\'딸깍\'',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: ' 눌러주세요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '아래와 같이 깜박이면서\n상태를 체크하기 시작할거에요.',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottom,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLight2(
                  onOffTime: [50, 50],
                  top: 57 * sizeUnit,
                  left: 64.5 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '깜박임이 변하면,\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '상태 체크에 최대 1분 정도 소요될 수 있어요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    'LED가 갑자기 꺼졌다면 펌웨어 업데이트가 진행중이에요!\n 업데이트는 최대 1분정도 소요될 수 있어요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '업데이트 완료 후 다시 상태체크가 진행됩니다.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page6_1() {
    if(isReset){
      _controller.stepNumber = '2';
    } else{
      _controller.stepNumber = '7';
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#' + _controller.stepNumber + ' ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '마이보울 '
              ),
              TextSpan(
                text: '상태 체크 완료',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: '!'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '정상적으로 완료되었다면,\n아래와 같이 깜박여요.',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Container(
            width: 244 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                Image.asset(
                  svgBowlBottom,
                  width: 244 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
                TwinkleLight2(
                  onOffTime: [500, 500],
                  top: 57 * sizeUnit,
                  left: 64.5 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '위와 같이 깜박이면,\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '위와 같이 깜박이지 않는다면, Wi-Fi 확인이 필요해요!',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    'LED가 갑자기 꺼졌다면 펌웨어 업데이트가 진행중이에요!\n 업데이트는 최대 1분정도 소요될 수 있어요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '업데이트 완료 후 다시 상태체크가 진행됩니다.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
          GestureDetector(
            onTap: () {
              Get.to(() => ConnectFailPage(isScale: true))!.then((value) {
                if (value != null) {
                  if (value[0] == true) {
                    pageController.animateToPage(0, duration: _duration, curve: _curve);
                  }
                }
              });
            },
            child: Container(
              width: 52 * sizeUnit,
              height: 30 * sizeUnit,
              decoration: BoxDecoration(
                color: vfColorOrange,
                borderRadius: BorderRadius.circular(15 * sizeUnit),
              ),
              child: Center(
                child: Text(
                  '확인하기',
                  style: VfTextStyle.subTitle5().copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page6() {
    if(isReset){
      _controller.stepNumber = '3';
    } else{
      _controller.stepNumber = '8';
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#' + _controller.stepNumber + ' ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: '설정 버튼을 '
              ),
              TextSpan(
                text: '\'딸깍\'',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: ' 누른 후,\n평평한 곳에 놓아주세요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '정확한 무게측정을 위해\n영점 조절이 시작돼요.',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 56 * sizeUnit),
          Container(
            width: 250 * sizeUnit,
            height: 244 * sizeUnit,
            child: Stack(
              children: [
                TwinkleLight2(
                  onOffTime: [500, 500],
                  top: 140 * sizeUnit,
                  left: 28 * sizeUnit,
                  isFront: true,
                ),
                Image.asset(
                  svgBowlFront,
                  width: 250 * sizeUnit,
                  height: 244 * sizeUnit,
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '깜박임이 멈추면,\n다음을 눌러주세요.'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '정확한 영점 조절을 위해 평평한 곳에 올려주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '실제로 마이보울을 사용할 위치라면 더 좋아요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '10초 후에도 변하지 않는다면, 버튼을 다시 눌러주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }

  Widget page7() {
    if(isReset){
      _controller.stepNumber = '4';
    } else{
      _controller.stepNumber = '9';
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20 * sizeUnit),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                text: '#' + _controller.stepNumber + ' ',
                style: VfTextStyle.headline4().copyWith(color: vfColorDarkGray),
              ),
              TextSpan(
                  text: ''
              ),
              TextSpan(
                text: '빈 그릇',
                style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
              ),
              TextSpan(text: '을 올려주세요.'),
            ]),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 26 * sizeUnit),
          Text(
            '빈 그릇의 무게를 측정할거에요!',
            style: VfTextStyle.body1(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20 * sizeUnit),
          Container(
            width: 250 * sizeUnit,
            height: 308 * sizeUnit,
            child: Stack(
              children: [
                FlyingBowl(),
                TwinkleLight2(
                  onOffTime: [4000, 2000],
                  top: 204 * sizeUnit,
                  left: 28 * sizeUnit,
                  isFront: true,
                ),
                Positioned(
                  top: 64 * sizeUnit,
                  child: Image.asset(
                    svgBowlFront,
                    width: 250 * sizeUnit,
                    height: 244 * sizeUnit,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32 * sizeUnit),
          Text.rich(
            TextSpan(text: '불빛이 꺼지면,\n모든 설정이 완료에요!'),
            style: VfTextStyle.headline4(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32 * sizeUnit),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '정확한 측정을 위해 꼭! 빈그릇을 올려놔 주세요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '마이보울 전용 그릇만 사용이 가능해요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '저울이 잘 맞지 않는 것 같다면, 다시 설정 가능해요!',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
              SizedBox(height: 4 * sizeUnit),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                  Text(
                    '방법은 BOWL > 설정 > 영점 조절하기에서 확인 가능해요.',
                    style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24 * sizeUnit),
        ],
      ),
    );
  }
}

class ConnectFailPage extends StatelessWidget {
  final isScale;

  const ConnectFailPage({
    Key? key,
    this.isScale = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 5,
      colorType: vfGradationColorType.Red,
      blur: 80 * sizeUnit,
      child: Scaffold(
        appBar: vfAppBar(
          context,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20 * sizeUnit),
                    if (!isScale) ...[
                      //기기등록 과정 중 실패
                      Text.rich(
                        TextSpan(text: '마이보울 등록에\n', children: [
                          TextSpan(
                            text: '실패',
                            style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
                          ),
                          TextSpan(
                            text: '했어요',
                          ),
                        ]),
                        style: VfTextStyle.headline4(),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      //저울 영점조절 과정 중 실패
                      Text.rich(
                        TextSpan(text: '', children: [
                          TextSpan(
                            text: 'Wi-Fi 상태',
                            style: VfTextStyle.headline4().copyWith(color: vfColorOrange),
                          ),
                          TextSpan(
                            text: '를\n확인해 주세요.',
                          ),
                        ]),
                        style: VfTextStyle.headline4(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 64 * sizeUnit),
                    Container(
                      width: 250 * sizeUnit,
                      height: 244 * sizeUnit,
                      child: Stack(
                        children: [
                          Image.asset(
                            svgBowlBottom,
                            width: 244 * sizeUnit,
                            height: 244 * sizeUnit,
                          ),
                          TwinkleLight2(
                            onOffTime: [200, 200, 200, 200, 200, 1000],
                            top: 57 * sizeUnit,
                            left: 64.5 * sizeUnit,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 64 * sizeUnit),
                    Text(
                      isScale ? '아래와 같이 깜박인다면,\nWi-Fi 연결에 문제가 있어요.' : '아래와 같이 깜박인다면, 설정 실패!\n아래의 이유를 확인하고 다시 시도해주세요.',
                      style: VfTextStyle.body1(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * sizeUnit),
                    if (!isScale) ...[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '와이파이 비밀번호가 틀리지 않았나요?',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '혹시, 5GHz Wi-Fi에 연결하지 않았나요?',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange)),
                              Text(
                                '2.4GHz Wi-Fi에 연결해야 사용이 가능해요.',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '마이보울의 설정버튼을 5초간 꾸 눌러 초기화 후,        \n다시하기 버튼을 눌러주세요.',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange)),
                              Text(
                                '무선 공유기의 상태를 확인해주세요.\n(ex. 신호 약함, 전원 꺼짐 등)',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorOrange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '와이파이 이름 또는 비밀번호가 변경되었나요?',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * sizeUnit),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('・ ', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
                              Text(
                                '와이파이 정보가 변경되었다면, BOWL페이지 > 설정\n>기기해제하기 후 보울등록을 다시 진행해 주세요.',
                                style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 24 * sizeUnit),
                  ],
                ),
              ),
            ),
            vfGradationButton(
              text: '재설정하기',
              colorType: vfGradationColorType.Red,
              onTap: () {
                unFocus(context);
                Get.back(result: [true]);
              },
            )
          ],
        ),
      ),
    );
  }
}

class FlyingBowl extends StatefulWidget {
  const FlyingBowl({Key? key}) : super(key: key);

  @override
  State<FlyingBowl> createState() => _FlyingBowlState();
}

class _FlyingBowlState extends State<FlyingBowl> {
  double bowlHeight = 0;
  int duration = 1000;
  bool isOnPage = true;

  void startAnimation() {
    if (isOnPage) {
      setState(() {
        duration = 1000;
        bowlHeight = 100;
      });
      Future.delayed(Duration(milliseconds: 5000), () => resetAnimation());
    }
  }

  void resetAnimation() {
    if (isOnPage) {
      setState(() {
        duration = 0;
        bowlHeight = 0;
      });
      Future.delayed(Duration(milliseconds: 1000), () => startAnimation());
    }
  }

  @override
  void initState() {
    super.initState();
    bowlHeight = 0;
    duration = 1000;
    isOnPage = true;

    resetAnimation();
  }

  @override
  void dispose() {
    isOnPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250 * sizeUnit,
      height: 174 * sizeUnit,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: duration),
            width: 0,
            height: bowlHeight * sizeUnit,
          ),
          Image.asset(
            svgBowl,
            width: 232 * sizeUnit,
            height: 74 * sizeUnit,
          ),
        ],
      ),
    );
  }
}
