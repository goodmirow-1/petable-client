import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import 'package:myvef_app/Bowl/Model/bowl.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/animated_tap_bar.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/drop_ball_animation_widget.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Config/GlobalWidget/wave_animation_widget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'resister_bowl_page.dart';

class BowlPage extends StatefulWidget {
  const BowlPage({Key? key}) : super(key: key);

  @override
  _BowlPageState createState() => _BowlPageState();
}

class _BowlPageState extends State<BowlPage> {
  final BowlPageController controller = Get.put(BowlPageController());
  final NavigationController navController = Get.put(NavigationController());

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double animationContainerHeight = Get.height - 180 * sizeUnit - 30;

  bool canUpdate = true;

  @override
  void initState() {
    super.initState();
    canUpdate = true;

    //기기 바닥 여백만큼 높이 낮춤. safeArea 등의 영향
    animationContainerHeight -= devicePadding.bottom;
  }

  @override
  void dispose() {
    controller.barIndex(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: vfAppBar(
          context,
          title: '그릇',
          isBackButton: false,
          actions: [
            GestureDetector(
              onTap: () {
                mainPageScaffoldKey.currentState!.setState(() {});
                mainPageScaffoldKey.currentState!.openEndDrawer();
              },
              child: SvgPicture.asset(
                svgSettingIcon,
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
              ),
            ),
            SizedBox(width: 16 * sizeUnit),
          ],
        ),
        body: Column(
          children: [
            Obx(() => AnimatedTapBar(
                  barIndex: controller.barIndex.value,
                  pageController: controller.pageController,
                  listTabItemTitle: ['밥그릇', '물그릇'],
                )),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.barIndex(index);

                  if (index == BOWL_TYPE_FOOD) {
                    navController.changeNavColor(itemColor: vfColorOrange, petColors: navRedColorList); // 네비게이션 아이콘 색 바꾸기
                  } else {
                    navController.changeNavColor(itemColor: vfColorWaterBlue, petColors: navBlueColorList); // 네비게이션 아이콘 색 바꾸기
                  }
                },
                children: [
                  GetBuilder<BowlPageController>(builder: (_controller) {
                    return foodBowlPage(controller.isHaveFoodBowl.value);
                  }),
                  GetBuilder<BowlPageController>(builder: (_controller) {
                    return waterBowlPage(controller.isHaveWaterBowl.value);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget foodBowlPage(bool haveBowl) {
    Widget noBowlPage() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (GlobalData.mainPet.value.type == PET_TYPE_ECT) {
                showVfDialog(
                  title: '반려동물을 등록해주세요.',
                  description: '반려동물을 등록하고\n다양한 기능을 이용해 보세요!',
                  colorType: vfGradationColorType.Red,
                );
              } else {
                Get.to(() => ResisterBowlPage(type: BOWL_TYPE_FOOD));
              }
            },
            child: Container(
              width: 216 * sizeUnit,
              height: 216 * sizeUnit,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: vfColorOrange, width: 10 * sizeUnit), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  'TOUCH',
                  style: VfTextStyle.headline2(),
                ),
              ),
            ),
          ),
          Row(children: [SizedBox(height: Get.height * 0.05)]),
          Text(
            '원을 터치해',
            style: VfTextStyle.subTitle2(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              highlightText(
                text: '그릇을 등록',
                style: VfTextStyle.highlight2(),
                highlightColor: vfColorOrange,
                highlightSize: 124 * sizeUnit,
              ),
              Text(
                '해 주세요!',
                style: VfTextStyle.subTitle2(),
              ),
            ],
          )
        ],
      );
    }

    Widget foodBowl() {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 360 * sizeUnit,
              height: animationContainerHeight,
              child: DropCircleAnimationWidget(
                width: 360 * sizeUnit,
                height: animationContainerHeight,
                ratio: controller.foodRatio.value,
              ),
            ),
          ),
          if (GlobalData.mainPet.value.foodBowl != null) ...[
            //배터리 표시
            battery(GlobalData.mainPet.value.foodBowl!.battery, [Color.fromRGBO(255, 207, 139, 0.6), Color.fromRGBO(245, 69, 59, 0.6)]),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async{
                  updateTrue() {
                    canUpdate = true;
                  }

                  //사료량 업데이트 새로고침
                  if (canUpdate) {
                    canUpdate = false;
                    vfLoadingDialog(); // 로딩 인디케이터 시작
                    await controller.updateFoodData();
                    Timer(Duration(milliseconds: 300),(){
                      Get.back();
                    });
                    setState(() {});
                    Timer(Duration(seconds: 1), updateTrue);
                  }
                },
                child: Container(
                  width: 216 * sizeUnit,
                  height: 216 * sizeUnit,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Obx(() => Text(controller.foodWeightText.value, style: VfTextStyle.headline1()))),
                ),
              ),
              SizedBox(height: Get.height * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(controller.foodText1.value, style: VfTextStyle.subTitle2())),
                  SizedBox(width: 4 * sizeUnit),
                  Obx(() => highlightText(
                        text: controller.foodText2.value,
                        style: VfTextStyle.highlight2(),
                        highlightSize: controller.foodText2Width.value,
                        highlightColor: vfColorOrange,
                      )),
                  SizedBox(width: 4 * sizeUnit),
                  Obx(() => Text(controller.foodText3.value, style: VfTextStyle.subTitle2())),
                ],
              ),
            ],
          ),
        ],
      );
    }

    if (haveBowl) {
      return FutureBuilder<double>(
        future: controller.updateFoodData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return foodBowl();
          } else {
            return Center(child: GradientCircularProgressIndicator(gradientColors: loadingRedColorList));
          }
        },
      );
    } else {
      return noBowlPage();
    }
  }

  Widget waterBowlPage(bool haveBowl) {
    Widget noBowlPage() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (GlobalData.mainPet.value.type == PET_TYPE_ECT) {
                showVfDialog(
                  title: '반려동물을 등록해주세요.',
                  description: '반려동물을 등록하고\n다양한 기능을 이용해 보세요!',
                  colorType: vfGradationColorType.Blue,
                );
              } else {
                Get.to(() => ResisterBowlPage(type: BOWL_TYPE_WATER));
              }
            },
            child: Container(
              width: 216 * sizeUnit,
              height: 216 * sizeUnit,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: vfColorWaterBlue, width: 10 * sizeUnit), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  'TOUCH',
                  style: VfTextStyle.headline2(),
                ),
              ),
            ),
          ),
          Row(children: [SizedBox(height: Get.height * 0.05)]),
          Text(
            '원을 터치해',
            style: VfTextStyle.subTitle2(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              highlightText(
                text: '그릇을 등록',
                style: VfTextStyle.highlight2(),
                highlightColor: vfColorWaterBlue,
                highlightSize: 124 * sizeUnit,
              ),
              Text(
                '해 주세요!',
                style: VfTextStyle.subTitle2(),
              ),
            ],
          )
        ],
      );
    }

    Widget waterBowl() {
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15 * sizeUnit),
            child: Container(
              width: 360 * sizeUnit,
              height: animationContainerHeight,
              child: WaveAnimationWidget(
                width: 360 * sizeUnit,
                height: animationContainerHeight,
                numberOfPoint2: 11,
                numberOfPoint1: 9,
                ratio: controller.waterRatio.value * 0.95, //배터리 가려서 살짝 낮춤.
              ),
            ),
          ),
          if (GlobalData.mainPet.value.waterBowl != null) ...[
            //배터리 표시
            battery(GlobalData.mainPet.value.waterBowl!.battery, [Color.fromRGBO(116, 231, 238, 0.6), Color.fromRGBO(130, 217, 255, 0.6)]),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  updateTrue() {
                    canUpdate = true;
                  }

                  //물 양 업데이트 새로고침
                  if (canUpdate) {
                    canUpdate = false;
                    vfLoadingDialog(); // 로딩 인디케이터 시작
                    await controller.updateWaterData();
                    Timer(Duration(milliseconds: 300),(){
                      Get.back();
                    });
                    setState(() {});

                    Timer(Duration(seconds: 1), updateTrue);
                  }
                },
                child: Container(
                  width: 216 * sizeUnit,
                  height: 216 * sizeUnit,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Obx(() => Text(controller.waterVolumeText.value, style: VfTextStyle.headline1()))),
                ),
              ),
              SizedBox(height: Get.height * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(controller.waterText1.value, style: VfTextStyle.subTitle2())),
                  SizedBox(width: 4 * sizeUnit),
                  Obx(() => highlightText(
                        text: controller.waterText2.value,
                        style: VfTextStyle.highlight2(),
                        highlightSize: controller.waterText2Width.value,
                        highlightColor: vfColorWaterBlue,
                      )),
                  SizedBox(width: 4 * sizeUnit),
                  Obx(() => Text(controller.waterText3.value, style: VfTextStyle.subTitle2())),
                ],
              ),
            ],
          ),
        ],
      );
    }

    if (haveBowl) {
      return FutureBuilder<double>(
        future: controller.updateWaterData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return waterBowl();
          } else {
            return Center(child: GradientCircularProgressIndicator(gradientColors: loadingBlueColorList));
          }
        },
      );
    } else {
      return noBowlPage();
    }
  }

  Widget battery(int battery, List<Color> colorList) {
    Widget batteryBar() {
      return Container(
        width: 2.5 * sizeUnit,
        height: 10 * sizeUnit,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorList,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 9 * sizeUnit, right: 18 * sizeUnit),
      child: Align(
        alignment: Alignment.topRight,
        child: Stack(
          children: [
            if (battery <= 1) ...[
              SvgPicture.asset(
                svgRedBatteryIcon,
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
              ),
              SizedBox(
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
                child: Row(
                  children: [
                    if (battery >= 1) ...[
                      SizedBox(width: 2.75 * sizeUnit),
                      batteryBar(),
                    ],
                  ],
                ),
              ),
            ] else ...[
              SvgPicture.asset(
                svgGreyBatterIcon,
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
              ),
              SizedBox(
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
                child: Row(
                  children: [
                    if (battery >= 1) ...[
                      SizedBox(width: 2.75 * sizeUnit),
                      batteryBar(),
                    ],
                    if (battery >= 2) ...[
                      SizedBox(width: 0.5 * sizeUnit),
                      batteryBar(),
                    ],
                    if (battery >= 3) ...[
                      SizedBox(width: 0.5 * sizeUnit),
                      batteryBar(),
                    ],
                    if (battery >= 4) ...[
                      SizedBox(width: 0.5 * sizeUnit),
                      batteryBar(),
                    ],
                    if (battery >= 5) ...[
                      SizedBox(width: 0.5 * sizeUnit),
                      batteryBar(),
                    ],
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
