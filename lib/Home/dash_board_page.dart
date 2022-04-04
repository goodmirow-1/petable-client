import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myvef_app/Bowl/Controller/bowl_controller.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Bowl/Model/bowl.dart';
import 'package:myvef_app/Bowl/resister_bowl_page.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/GlobalWidget/drop_ball_animation_widget.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Config/GlobalWidget/wave_animation_widget.dart';
import 'package:myvef_app/Config/Painter/circle_paint_widget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Home/feed_diary_widget.dart';
import 'package:myvef_app/Home/health_score_widget.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Notification/notification_page.dart';
import 'package:myvef_app/edit/edit_pet_page.dart';
import 'package:myvef_app/edit/edit_user_page.dart';
import 'package:myvef_app/initiation/initiation_pet_page.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:badges/badges.dart';
import 'Model/advice.dart';
import 'main_page.dart';

class DashBoardPage extends StatelessWidget {
  GlobalKey<FormState> healthScoreKey = GlobalKey<FormState>(); // 건강점수 키

  final DashBoardController controller = Get.find<DashBoardController>();
  final NotificationController notificationController = Get.put(NotificationController());
  final BowlPageController bowlPageController = Get.find();
  final FoodBowlController foodBowlController = Get.find();
  final WaterBowlController waterBowlController = Get.find();

  final Duration graphDuration = Duration(milliseconds: 1000);
  final Duration waveDuration = Duration(milliseconds: 700);
  final int graphDurationInt = 1000;

  final BoxDecoration _boxDecoration = BoxDecoration(
    color: Color.fromRGBO(255, 255, 255, 0.8),
    boxShadow: vfBasicBoxShadow,
    borderRadius: BorderRadius.circular(20 * sizeUnit),
  );

  final String svgVfRowLogoAndText = 'assets/image/Global/vfRowLogoAndText.svg';
  final String svgAddIcon = 'assets/image/Global/addIcon.svg';
  final String svgVBellIcon = 'assets/image/dash_board/bellIcon.svg';
  final String svgExclamationInCircle = 'assets/image/dash_board/exclamationInCircle.svg';
  final String svgFeedDotGraph = 'assets/image/dash_board/feedDotGraph.svg';
  final String svgWaterDotGraph = 'assets/image/dash_board/waterDotGraph.svg';
  final String svgGenderIcon = 'assets/image/dash_board/genderIcon.svg';
  final String svgAgeIcon = 'assets/image/dash_board/ageIcon.svg';
  final String svgRankScaleIcon = 'assets/image/dash_board/rankScaleIcon.svg'; // 건강점수 저울 아이콘

  // 펫 성별 체크
  String petGenderCheck(int sex) {
    String result = '';

    switch (sex) {
      case MALE:
        result = '남';
        break;
      case FEMALE:
        result = '여';
        break;
      case NEUTERING_MALE:
        result = '남';
        break;
      case NEUTERING_FEMALE:
        result = '여';
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {

    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: dashBoardAppBar(),
        body: SingleChildScrollView(
          child: GetBuilder<DashBoardController>(
            builder: (_) {
              return Column(
                children: [
                  SizedBox(height: 16 * sizeUnit),
                  buildPetNameAndProfile(), // 펫 이름, 프로필
                  SizedBox(height: 16 * sizeUnit),
                  buildPetInfoWidget(), // 성별, 몸무게, 나이
                  SizedBox(height: 16 * sizeUnit),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                      child: backLoadingGraph(
                        child: Row(
                          children: [
                            buildGraphWidget(true), // 사료 그래프
                            SizedBox(width: 8 * sizeUnit),
                            buildGraphWidget(false), // 물 그래프
                          ],
                        ),
                      )),
                  SizedBox(height: 16 * sizeUnit),
                  backLoadingGraph(child: HealthScoreWidget()), // 건강점수
                  SizedBox(height: 16 * sizeUnit),
                  FeedDiaryWidget(), // 냠냠일지
                  SizedBox(height: 16 * sizeUnit),
                  //PetKindInfoWidget(), // 품종정보
                  //SizedBox(height: 16 * sizeUnit),
                  buildDoctorSays(), // 오늘의 한마디
                  SizedBox(height: 16 * sizeUnit),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Obx backLoadingGraph({required Widget child}) {
    return Obx(
      () => Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (GlobalData.backLoading.value) ...[
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                alignment: Alignment.center,
                child: GradientCircularProgressIndicator(),
              ),
            )
          ] else ...[
            SizedBox.shrink()
          ]
        ],
      ),
    );
  }

  // 그래프 위젯
  Widget buildGraphWidget(bool isFeed) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isFeed ? bowlPageController.isHaveFoodBowl.value : bowlPageController.isHaveWaterBowl.value) {
            controller.changeGraphStatus();
          } else {
            if (GlobalData.mainPet.value.type == PET_TYPE_ECT) {
              showVfDialog(
                title: '반려동물을 등록해주세요.',
                description: '반려동물을 등록하고\n다양한 기능을 이용해 보세요!',
                colorType: vfGradationColorType.Violet,
              );
            } else {
              Get.to(() => ResisterBowlPage(type: isFeed ? BOWL_TYPE_FOOD : BOWL_TYPE_WATER));
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(14 * sizeUnit),
          height: 156 * sizeUnit,
          width: 156 * sizeUnit,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            boxShadow: vfBasicBoxShadow,
            borderRadius: BorderRadius.circular(20 * sizeUnit),
          ),
          child: Obx(() => isFeed
              ? bowlPageController.isHaveFoodBowl.value
                  ? Obx(() => buildFeedGraph())
                  : buildAddBowlWidget(isFeed)
              : bowlPageController.isHaveWaterBowl.value
                  ? Obx(() => buildWaterGraph())
                  : buildAddBowlWidget(isFeed)),
        ),
      ),
    );
  }

  // 사료 그래프
  Widget buildFeedGraph() {
    double recommendedIntake = calRecommendedDaily(GlobalData.mainPet.value); // 하루 권장 섭취량 (kcal)

    switch (controller.graphStatus.value) {
      case GRAPH_STATUS.ACHIEVEMENT_RATE: // 섭취달성 (하루 권장량 대비 먹은양)
        return circularPercentGraph(
          amount: controller.todayKcalIntake.value,
          recommendedIntake: recommendedIntake,
        );
      case GRAPH_STATUS.CURRENT_INTAKE: // 현재 섭취량 (kcal)
        return feedAnimationGraph(
          amount: controller.todayKcalIntake.value,
          recommendedIntake: recommendedIntake,
        );
      case GRAPH_STATUS.INTAKE_COUNT: // 현재 섭취 횟수
        return circularDotGraph(
          intakeCount: controller.todayFeedIntakeCount,
          graphImgPath: svgFeedDotGraph,
        );
    }
  }

  // 물 그래프
  Widget buildWaterGraph() {
    switch (controller.graphStatus.value) {
      case GRAPH_STATUS.ACHIEVEMENT_RATE: // 섭취달성 (하루 권장량 대비 먹은양)
        return circularPercentGraph(
          amount: controller.todayWaterIntake.value,
          recommendedIntake: GlobalData.mainPet.value.waterRecommendedIntake,
          backGroundColor: vfColorSkyBlue20,
          progressColor: vfColorSkyBlue,
          overProgressColor: vfColorViolet,
          title: '음수달성',
        );
      case GRAPH_STATUS.CURRENT_INTAKE: // 현재 음수량 (ml)
        return waveAnimationGraph(amount: controller.todayWaterIntake.value);
      case GRAPH_STATUS.INTAKE_COUNT: // 현재 섭취 횟수
        return circularDotGraph(
          intakeCount: controller.todayWaterIntakeCount,
          graphImgPath: svgWaterDotGraph,
          graphColor: vfColorSkyBlue,
        );
    }
  }

  // 그릇 등록 위젯
  Widget buildAddBowlWidget(bool isFeed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit, vertical: 2 * sizeUnit),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Center(
            child: SvgPicture.asset(
              svgAddIcon,
              width: 48 * sizeUnit,
              height: 48 * sizeUnit,
              color: isFeed ? vfColorOrange : vfColorSkyBlue,
            ),
          ),
          SizedBox(height: 10 * sizeUnit),
          highlightText(
            text: isFeed ? '밥 그릇' : '물 그릇',
            style: VfTextStyle.headline3(),
            highlightColor: isFeed ? vfColorOrange : vfColorSkyBlue,
            highlightSize: 78 * sizeUnit,
          ),
          SizedBox(height: 4 * sizeUnit),
          Text('을 등록해 주세요!', style: VfTextStyle.body1()),
        ],
      ),
    );
  }

  // 사료 애니메이션 그래프
  Widget feedAnimationGraph({required double amount, required double recommendedIntake}) {
    double ratio = recommendedIntake == nullDouble ? 0.5 : amount / recommendedIntake; // 먹은양 / 사료 하루 권장 섭취량 (kcal)

    if (ratio > 1)
      ratio = 1; // 먹은양 넘으면 1로
    else if (ratio < 0.0) ratio = 0.0; // 먹은양 음수면 0으로

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120 * sizeUnit,
          height: 120 * sizeUnit,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: vfBasicBoxShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60 * sizeUnit),
            child: DropCircleAnimationWidget(
              width: 120 * sizeUnit,
              height: 120 * sizeUnit,
              ratio: ratio,
              ballDiameter: 14 * sizeUnit,
              showFloorGradient: false,
            ),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: amount),
          duration: graphDuration,
          builder: (context, double value, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('현재\n섭취량', style: VfTextStyle.subTitle4(), textAlign: TextAlign.center),
              SizedBox(height: 5 * sizeUnit),
              Text(value < 0.0 ? '0kcal' : value.round().toString() + 'kcal', style: VfTextStyle.headline3()),
            ],
          ),
        ),
      ],
    );
  }

  // 웨이브 애니메이션 그래프
  Widget waveAnimationGraph({required double amount}) {
    double spaceRatio = amount == 0 ? 130 * sizeUnit : ((1 - (amount / GlobalData.mainPet.value.waterRecommendedIntake)) * 120); // 빈 공간을 차지하는 percent

    if (spaceRatio < 0) spaceRatio = 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120 * sizeUnit,
          height: 120 * sizeUnit,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: vfBasicBoxShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60 * sizeUnit),
            child: TweenAnimationBuilder(
              duration: waveDuration,
              tween: Tween<double>(begin: 120, end: spaceRatio),
              builder: (context, double value, child) => AnimatedContainer(
                duration: waveDuration,
                curve: Curves.decelerate,
                transform: Matrix4.translationValues(0, value * sizeUnit, 0),
                child: WaveAnimationWidget(
                  height: 120 * sizeUnit,
                  width: 120 * sizeUnit,
                  ratio: 1,
                  numberOfPoint1: 6,
                  numberOfPoint2: 12,
                ),
              ),
            ),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: amount),
          duration: graphDuration,
          builder: (context, double value, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('현재\n음수량', style: VfTextStyle.subTitle4(), textAlign: TextAlign.center),
              SizedBox(height: 5 * sizeUnit),
              Text(value < 0.0 ? '0ml' : value.round().toString() + 'ml', style: VfTextStyle.headline3()),
            ],
          ),
        ),
      ],
    );
  }

  // 점 원그래프
  Widget circularDotGraph({required int intakeCount, required String graphImgPath, Color graphColor = vfColorOrange}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: intakeCount / 24),
      duration: graphDuration,
      builder: (context, double value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return SweepGradient(
                    stops: [value, value],
                    colors: [graphColor, Colors.white],
                    transform: GradientRotation(-math.pi / 24), // 각도 조정
                  ).createShader(rect);
                },
                child: SvgPicture.asset(
                  graphImgPath,
                  width: 120 * sizeUnit,
                  height: 120 * sizeUnit,
                ),
              ),
            ),
            Center(
              child: Container(
                width: 90 * sizeUnit,
                height: 90 * sizeUnit,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('현재 섭취 횟수', style: VfTextStyle.subTitle4()),
                    SizedBox(height: 4 * sizeUnit),
                    Text((value * 24).toInt().toString() + '회', style: VfTextStyle.headline3()),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 퍼센트 원그래프
  Widget circularPercentGraph({
    required double amount,
    required double recommendedIntake,
    Color backGroundColor = vfColorOrange20,
    Color progressColor = vfColorOrange,
    Color overProgressColor = vfColorRed,
    String title = '섭취달성',
  }) {
    double ratio = recommendedIntake == nullDouble
        ? 0.0
        : amount == 0.0 || recommendedIntake == 0.0
            ? 0.0
            : amount / recommendedIntake; // 하루 권장량 대비 먹은양

    if (ratio < 0.0) ratio = 0.0; // 음수면 0으로

    double overRatio = 0.0;

    return Stack(
      children: [
        CircularPercentIndicator(
          radius: 128 * sizeUnit,
          lineWidth: 16 * sizeUnit,
          percent: ratio > 1 ? 1 : ratio,
          animation: true,
          animationDuration: graphDurationInt,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: backGroundColor,
          progressColor: progressColor,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: VfTextStyle.subTitle4()),
              SizedBox(height: 4 * sizeUnit),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: ratio),
                duration: ratio > 1 ? graphDuration + graphDuration - Duration(milliseconds: 300) : graphDuration,
                builder: (context, double value, child) => Text((value * 100).round().toString() + '%', style: VfTextStyle.headline3()),
              ),
            ],
          ),
        ),
        if (ratio > 1) ...[
          FutureBuilder(
            future: Future.delayed(graphDuration, () => overRatio = ratio - 1),
            builder: (context, snapshot) => CircularPercentIndicator(
              radius: 128 * sizeUnit,
              lineWidth: 16 * sizeUnit,
              percent: overRatio > 1 ? 1 : overRatio,
              animation: true,
              animationDuration: graphDurationInt - 300,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: backGroundColor,
              progressColor: overProgressColor,
            ),
          ),
        ],
      ],
    );
  }

  // 오늘의 한마디
  Container buildDoctorSays() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 24 * sizeUnit, 16 * sizeUnit, 16 * sizeUnit),
      width: double.infinity,
      decoration: _boxDecoration,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 한마디', style: VfTextStyle.highlight3()),
                SizedBox(height: 4 * sizeUnit),
                Text(
                  '빵 굽는 수의사의 한마디',
                  style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * sizeUnit),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 14 * sizeUnit),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: vfColorPink20,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              GlobalData.mainPet.value.advice == '' ? checkToken(globalAdviceList[0].contents) : GlobalData.mainPet.value.advice,
              style: VfTextStyle.subTitle4().copyWith(height: 16 / 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Container circleInIconWidget(Color color, Widget iconWidget) {
    return Container(
      alignment: Alignment.center,
      width: 32 * sizeUnit,
      height: 32 * sizeUnit,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: iconWidget,
    );
  }

  // 성별, 몸무게, 나이
  Container buildPetInfoWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      width: double.infinity,
      height: 52 * sizeUnit,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        boxShadow: vfBasicBoxShadow,
        borderRadius: BorderRadius.circular(20 * sizeUnit),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              circleInIconWidget(
                vfColorSkyBlue20,
                SvgPicture.asset(
                  svgGenderIcon,
                  width: 24 * sizeUnit,
                  height: 24 * sizeUnit,
                ),
              ),
              SizedBox(width: 12 * sizeUnit),
              Text(
                petGenderCheck(GlobalData.mainPet.value.sex).isEmpty ? '-' : petGenderCheck(GlobalData.mainPet.value.sex),
                style: VfTextStyle.subTitle2(),
              ),
            ],
          ),
          Row(
            children: [
              circleInIconWidget(
                vfColorOrange20,
                SvgPicture.asset(
                  svgRankScaleIcon,
                  width: 12 * sizeUnit,
                  height: 13 * sizeUnit,
                  color: vfColorOrange,
                ),
              ),
              SizedBox(width: 12 * sizeUnit),
              Text(
                GlobalData.mainPet.value.weight == nullDouble ? '-' : GlobalData.mainPet.value.weight.toString() + 'kg',
                style: VfTextStyle.subTitle2(),
              ),
            ],
          ),
          Row(
            children: [
              circleInIconWidget(
                vfColorPink20,
                SvgPicture.asset(
                  svgAgeIcon,
                  width: 24 * sizeUnit,
                  height: 24 * sizeUnit,
                ),
              ),
              SizedBox(width: 12 * sizeUnit),
              Text(
                petAgeCheck(GlobalData.mainPet.value.birthday).isEmpty ? '-' : petAgeCheck(GlobalData.mainPet.value.birthday),
                style: VfTextStyle.subTitle2(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 펫 이름, 프로필
  Padding buildPetNameAndProfile() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GlobalData.mainPet.value.name.isNotEmpty ? GlobalData.mainPet.value.name : '예비 마이베프',
            style: VfTextStyle.headline2(),
          ),
          SizedBox(height: 8 * sizeUnit),
          Wrap(
            spacing: 8 * sizeUnit,
            runSpacing: 8 * sizeUnit,
            children: [
              if (GlobalData.mainPet.value.kind.isNotEmpty) petTagItem(GlobalData.mainPet.value.kind),
              if (GlobalData.mainPet.value.birthday.isNotEmpty) petTagItem(GlobalData.mainPet.value.birthday),
              petTagItem(abbreviateForLocation(GlobalData.loggedInUser.value.location)),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          buildProfileImg()
        ],
      ),
    );
  }

  // 프로필 이미지
  Widget buildProfileImg() {
    return Container(
      width: double.infinity,
      height: 342 * sizeUnit,
      decoration: BoxDecoration(
        boxShadow: GlobalData.mainPet.value.petPhotos.isEmpty ? vfBasicBoxShadow : vfImgBoxShadow,
      ),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: GlobalData.mainPet.value.petPhotos.isEmpty ? 1 : GlobalData.mainPet.value.petPhotos.length,
            onPageChanged: (index) => controller.profileIndex(index),
            itemBuilder: (context, index) {
              if (GlobalData.mainPet.value.petPhotos.isEmpty) {
                return GestureDetector(
                  onTap: () {
                    if (GlobalData.mainPet.value.name.isNotEmpty) {
                      Get.to(() => EditPetPage(
                            pageIndex: 2,
                          ));
                    } else {
                      Get.to(() => InitiationPetPage(isAdd: true));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20 * sizeUnit),
                    ),
                    child: CirclePaintWidget(
                      color: vfColorPink,
                      diameter: 204 * sizeUnit,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          vfPramBodyGoodStateWidget(),
                          SizedBox(height: 24 * sizeUnit),
                          Text(GlobalData.mainPet.value.name.isNotEmpty ? '사진을 등록해 주세요' : '펫을 등록해 주세요', style: VfTextStyle.body1()),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20 * sizeUnit),
                  child: GetExtendedImage(
                    url: GlobalData.mainPet.value.petPhotos[index].imageUrl,
                    boxFit: BoxFit.fill,
                  ),
                );
              }
            },
          ),
          Positioned(
            right: 16 * sizeUnit,
            bottom: 16 * sizeUnit,
            child: GestureDetector(
              onTap: () {
                Get.to(() => EditUserPage());
              },
              child: Container(
                width: 72 * sizeUnit,
                height: 72 * sizeUnit,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GlobalData.loggedInUser.value.profileURL.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(36 * sizeUnit),
                        child: GetExtendedImage(
                          url: GlobalData.loggedInUser.value.profileURL,
                          boxFit: BoxFit.cover,
                          showDescription: false,
                          indicatorRadius: 22,
                          errorWidget: CirclePaintWidget(color: vfColorPink, diameter: 204 * sizeUnit, child: Center(child: vfBetiHeadBadStateWidget())),
                        ),
                      )
                    : vfGradationIconWidget(iconPath: svgVfUserDefaultImg, size: 72),
              ),
            ),
          ),
          Positioned(
            left: 16 * sizeUnit,
            bottom: 16 * sizeUnit,
            child: Row(
              children: List.generate(GlobalData.mainPet.value.petPhotos.length, (index) {
                return Obx(() => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: 4 * sizeUnit),
                      width: index == controller.profileIndex.value ? 12 * sizeUnit : 4 * sizeUnit,
                      height: 4 * sizeUnit,
                      decoration: BoxDecoration(
                        color: index == controller.profileIndex.value ? Colors.white : Color.fromRGBO(255, 255, 255, 0.4),
                        borderRadius: BorderRadius.circular(4 * sizeUnit),
                      ),
                    ));
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 펫 정보 컨테이너
  Container petTagItem(String text) {
    return Container(
      height: 26 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 6 * sizeUnit),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 163, 183, 0.2),
        borderRadius: BorderRadius.circular(12 * sizeUnit),
      ),
      child: Text(text, style: VfTextStyle.subTitle4()),
    );
  }

  // 앱바
  AppBar dashBoardAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 56 * sizeUnit,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      leading: Container(
        padding: EdgeInsets.only(left: 16 * sizeUnit),
        child: SvgPicture.asset(
          svgVfRowLogoAndText,
          width: 112 * sizeUnit,
          height: 18 * sizeUnit,
        ),
      ),
      leadingWidth: 128 * sizeUnit,
      actions: [
        GestureDetector(
            child: Obx(
              () => Badge(
                showBadge: notificationController.showRedDot.value,
                position: BadgePosition.topEnd(top: 2 * sizeUnit, end: -4 * sizeUnit),
                badgeColor: vfColorRed,
                elevation: 0,
                toAnimate: false,
                badgeContent: Text(''),
                child: SvgPicture.asset(
                  svgVBellIcon,
                  width: 24 * sizeUnit,
                  height: 24 * sizeUnit,
                ),
              ),
            ),
            onTap: () async {
              await notificationController.loadNotificationFutureData();

              Get.to(() => TotalNotificationPage());
            }),
        SizedBox(width: 24 * sizeUnit),
        GestureDetector(
          child: SvgPicture.asset(svgSettingIcon, width: 24 * sizeUnit, height: 24 * sizeUnit),
          onTap: () {
            mainPageScaffoldKey.currentState!.openEndDrawer();
          },
        ),
        SizedBox(width: 16 * sizeUnit),
      ],
    );
  }
}
