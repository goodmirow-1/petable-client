import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/period_select_box.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/graph/snack_direct_input_page.dart';
import 'package:myvef_app/graph/graph_components.dart';
import 'package:myvef_app/graph/model/graph_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class GraphWidget extends StatelessWidget {
  GraphWidget({Key? key, this.detailInfo = ''}) : super(key: key);

  final String detailInfo;

  final GraphPageController controller = Get.find<GraphPageController>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final String svgGraduation = 'assets/image/graph/graduationIcon.svg';

  List<GraphData> intakeList = []; // 먹은 양 리스트
  String preHighlight = '총';
  String unitOfTime = '시';
  String graphUnit = 'kcal'; // 단위
  Color mainColor = vfColorOrange;
  bool isFeed = true; // 사료인지 물인지
  RxInt selectedIndex = 0.obs; // 선택된 index
  RxInt maxIntake = 10000.obs; // intake 최대 값

  @override
  Widget build(BuildContext context) {
    if (detailInfo.isEmpty) {
      isFeed = controller.barIndex.value == GRAPH_TYPE_FEED; // 그래프 페이지일 때
    } else {
      isFeed = detailInfo == '섭취량'; // 반려동물 상세 정보 페이지일 때
    }

    if (isFeed) {
      mainColor = vfColorOrange;
      graphUnit = 'kcal';
    } else {
      mainColor = vfColorWaterBlue;
      graphUnit = 'ml';
    }

    switch (controller.periodIndex.value) {
      case GRAPH_PERIOD_DAY:
        intakeList = isFeed ? controller.feedIntakeListForDay : controller.waterIntakeListForDay; // 그래프 데이터 리스트(일)
        preHighlight = '총';
        unitOfTime = '시';
        break;
      case GRAPH_PERIOD_WEEK:
        intakeList = isFeed ? controller.feedIntakeListForWeek : controller.waterIntakeListForWeek; // 그래프 데이터 리스트(주)
        preHighlight = '일일 평균';
        unitOfTime = '';
        break;
      case GRAPH_PERIOD_MONTH:
        intakeList = isFeed ? controller.feedIntakeListForWeek : controller.waterIntakeListForWeek; // 그래프 데이터 리스트(월)
        preHighlight = '일일 평균';
        unitOfTime = '';
        break;
      case GRAPH_PERIOD_YEAR:
        intakeList = isFeed ? controller.feedIntakeListForYear : controller.waterIntakeListForYear; // 그래프 데이터 리스트(년)
        preHighlight = '일일 평균';
        unitOfTime = '';
        break;
    }

    if (intakeList.isEmpty) maxIntake(350); // 데이터 리스트가 비었으면 intake 최대 값 임의로 세팅

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4 * sizeUnit),
                    child: Text(preHighlight, style: VfTextStyle.body1().copyWith(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 6 * sizeUnit),
                  indexPositionsView(isTotalIntake: true), // 먹은양
                  SizedBox(width: 6 * sizeUnit),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4 * sizeUnit),
                    child: Text(isFeed ? '먹었어요!' : '마셨어요!', style: VfTextStyle.body1().copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 16 * sizeUnit),
              indexPositionsView(isTotalIntake: false), // 시간
            ],
          ),
        ),
        SizedBox(height: controller.isShortPhone ? 20 * sizeUnit : 56 * sizeUnit),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GraphComponent().backgroundWidget(isGraduation: true, maxIntake: maxIntake), // 배경 눈금
              if (intakeList.isEmpty) ...[
                SizedBox.shrink(),
              ] else ...[
                // 각 그래프마다 따로 처리
                if (controller.periodIndex.value == GRAPH_PERIOD_DAY) ...[
                  dailyGraph(),
                ] else if (controller.periodIndex.value == GRAPH_PERIOD_WEEK) ...[
                  weekGraph(),
                ] else if (controller.periodIndex.value == GRAPH_PERIOD_MONTH) ...[
                  monthGraph(),
                ] else if (controller.periodIndex.value == GRAPH_PERIOD_YEAR) ...[
                  yearGraph(),
                ],
              ],
              inputButtonAndPeriod(), // 직접입력, 기간 (gramBubble 겹쳐지는 경우가 있어서)
              GraphComponent().backgroundWidget(isGraduation: false, maxIntake: maxIntake), // y축 gram 수
            ],
          ), // 그래프 영역
        ),
        // SizedBox(height: 20 * sizeUnit),
      ],
    );
  }

  // 직접입력, 기간
  Row inputButtonAndPeriod() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detailInfo.isEmpty) ...[
          SizedBox(width: 16 * sizeUnit),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Get.to(() => SnackDirectInputPage()),
            child: Container(
              width: 70 * sizeUnit,
              height: 24 * sizeUnit,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * sizeUnit),
                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), offset: Offset(0, 2 * sizeUnit), blurRadius: 2 * sizeUnit)],
              ),
              child: Text('직접입력', style: VfTextStyle.subTitle4().copyWith(color: vfColorDarkGray)),
            ),
          ),
        ],
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PeriodSelectBox(
              color: mainColor.withOpacity(0.8),
              itemScrollController: itemScrollController,
            ),
            SizedBox(height: 12 * sizeUnit),
            Text('단위: $graphUnit', style: VfTextStyle.bWriteDate()),
          ],
        ),
        SizedBox(width: 16 * sizeUnit),
      ],
    );
  }

  // 화면에 보여지는 index stream widget
  Widget indexPositionsView({required bool isTotalIntake}) {
    String startTime = '';
    String endTime = '';

    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        Map<String, dynamic> res = {}; // 결과 값 담을 변수
        int start = 0; // 시작 index
        int end = 0; // 끝 index
        int intake = 0; // 섭취량
        int maxIntake2 = 0; // intake 최대값
        int selectedIdx = 0; // 선택된 index

        if (positions.isNotEmpty) {
          start = positions
              .where((ItemPosition position) => position.itemTrailingEdge > 0)
              .reduce((ItemPosition min, ItemPosition position) => position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
              .index;

          end = positions
              .where((ItemPosition position) => position.itemLeadingEdge < 1)
              .reduce((ItemPosition max, ItemPosition position) => position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
              .index;

          // 각 그래프마다 따로 처리
          switch (controller.periodIndex.value) {
            case GRAPH_PERIOD_DAY:
              res = controller.listenableFuncForDay(start: start, end: end, intakeList: intakeList);
              break;
            case GRAPH_PERIOD_WEEK:
              res = controller.listenableFuncForWeek(start: start, end: end, intakeList: intakeList);
              break;
            case GRAPH_PERIOD_MONTH:
              res = controller.listenableFuncForMonth(start: start, end: end, intakeList: intakeList);
              break;
            case GRAPH_PERIOD_YEAR:
              res = controller.listenableFuncForYear(start: start, end: end, intakeList: intakeList);
              break;
          }

          // 계산한거 세팅
          startTime = res['startTime'];
          endTime = res['endTime'];
          intake = res['intake'];
          maxIntake2 = res['maxIntake'];
          selectedIdx = res['selectedIndex'];

          // gramBubble
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            selectedIndex(selectedIdx); // 선택된 index

            maxIntake(maxIntake2); // 섭최량 최대 값
          });
        }

        // 데이터 없을 때 기간 예외 처리
        if (intakeList.isEmpty) {
          switch (controller.periodIndex.value) {
            case GRAPH_PERIOD_DAY:
              startTime = DateTime(controller.now.year, controller.now.month, controller.now.day, 0).toString().substring(0, 13).replaceAll('-', '.');
              endTime = DateTime(controller.now.year, controller.now.month, controller.now.day, 23).toString().substring(0, 13).replaceAll('-', '.');
              break;
            case GRAPH_PERIOD_WEEK:
              startTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 10).replaceAll('-', '.');
              endTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 10).replaceAll('-', '.');
              break;
            case GRAPH_PERIOD_MONTH:
              startTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 10).replaceAll('-', '.');
              endTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 10).replaceAll('-', '.');
              break;
            case GRAPH_PERIOD_YEAR:
              startTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 7).replaceAll('-', '.');
              endTime = DateTime(controller.now.year, controller.now.month, controller.now.day).toString().substring(0, 7).replaceAll('-', '.');
              break;
          }
        }

        // 시간
        if (isTotalIntake) {
          return GraphComponent().graphHighlightText(intake, mainColor, graphUnit, isFeed);
        } else {
          return Text(
            '$startTime$unitOfTime ~ $endTime$unitOfTime',
            style: VfTextStyle.body2().copyWith(color: vfColorDarkGray),
          );
        }
      },
    );
  }

  // 일 그래프
  Widget dailyGraph() {
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.horizontal,
      reverse: true,
      physics: ClampingScrollPhysics(),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemCount: intakeList.length + 4,
      itemBuilder: (context, index) {
        GraphData intake = GraphData(); // 먹은 양
        int hour = index; // 시
        bool showHour = false; // 시간 보여주기 여부
        int day = (index - 4) ~/ 24; // 오늘로부터 몇 일 지났는지

        if (index < 4) return GraphComponent().buildFallGraduation();

        if ((index - 3) % 24 != 0) {
          hour = (day + 1) * 24 - (index - 3); // 23시를 만들어야 하기 때문에 -3
        } else {
          hour = 0;
        }

        if (intakeList.isNotEmpty) intake = intakeList[index - 4];

        // 시간 보여주기 여부
        if (hour == 0 || hour == 6 || hour == 12 || hour == 18 || hour == 23 || intake.total > 0) {
          showHour = true;
        } else {
          showHour = false;
        }

        return Padding(
          padding: EdgeInsets.only(left: index - 3 == intakeList.length ? Get.width - (60 * sizeUnit) : 0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => GraphComponent().graphBar(
                      onTap: () => selectedIndex(index),
                      intake: intake,
                      index: index,
                      isFeed: isFeed,
                      selectedIndex: selectedIndex,
                      maxIntake: maxIntake,
                    ),
                  ),
                  if (showHour) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
                      child: Obx(() => GraphComponent().xAxisText(
                            text: hour.toString(),
                            index: index,
                            selectedIndex: selectedIndex,
                            isFeed: isFeed,
                          )),
                    ),
                  ] else ...[
                    SvgPicture.asset(svgGraduation, height: 12 * sizeUnit, width: 12 * sizeUnit),
                  ]
                ],
              ),
              if (intake.total != 0) ...[
                Obx(() => GraphComponent().gramBubble(
                      intakeAmount: intake.total,
                      index: index,
                      left: -6 * sizeUnit - intake.total.toString().length,
                      mainColor: mainColor,
                      selectedIndex: selectedIndex,
                      maxIntake: maxIntake,
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  // 주 그래프
  Widget weekGraph() {
    return SizedBox(
      child: ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        physics: ClampingScrollPhysics(),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: intakeList.length + 1,
        itemBuilder: (context, index) {
          GraphData intake = GraphData();
          String dayOfTheWeek = ''; // 요일

          // 첫 번째는 내일 요일
          if (index == 0) return GraphComponent().buildTomorrow();

          // 먹은 양 계산
          if (intakeList.isNotEmpty) intake = intakeList[index - 1];

          // 요일 계산
          dayOfTheWeek = DateFormat('EEEE').format(controller.now.subtract(Duration(days: index - 1))).substring(0, 3);

          return Padding(
            padding: EdgeInsets.only(left: index == intakeList.length ? Get.width - (60 * sizeUnit) : 0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(() => GraphComponent().graphBar(
                            onTap: () => selectedIndex(index),
                            intake: intake,
                            index: index,
                            isFeed: isFeed,
                            selectedIndex: selectedIndex,
                            maxIntake: maxIntake,
                          )),
                      Obx(() => GraphComponent().xAxisText(
                            text: dayOfTheWeek,
                            index: index,
                            selectedIndex: selectedIndex,
                            isFeed: isFeed,
                          )),
                    ],
                  ),
                ),
                // 먹은 양 말풍선 위젯
                if (intake.total != 0) ...[
                  Obx(() => GraphComponent().gramBubble(
                        intakeAmount: intake.total,
                        index: index,
                        mainColor: mainColor,
                        left: 4 * sizeUnit - intake.total.toString().length,
                        selectedIndex: selectedIndex,
                        maxIntake: maxIntake,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // 월 그래프
  Widget monthGraph() {
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.horizontal,
      reverse: true,
      physics: ClampingScrollPhysics(),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemCount: intakeList.length + 4,
      itemBuilder: (context, index) {
        GraphData intake = GraphData(); // 먹은 양
        int day = index; // 일
        bool showDay = false; // 시간 보여주기 여부

        if (index < 4) return GraphComponent().buildFallGraduation(); // // 데이터 시작전 보여지는 눈금

        // 일 계산
        DateTime dateTime = controller.now.subtract(Duration(days: index - 4));
        day = dateTime.day;

        // 먹은 양
        if (intakeList.isNotEmpty) intake = intakeList[index - 4];

        // 일수 보여주기 여부
        if (day == 1 || day == 5 || day == 10 || day == 15 || day == 20 || day == 25 || index == 4 || day == DateTime(dateTime.year, dateTime.month + 1, 0).day || intake.total > 0)
          showDay = true;
        else
          showDay = false;

        return Padding(
          padding: EdgeInsets.only(left: index - 3 == intakeList.length ? Get.width - (60 * sizeUnit) : 0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => GraphComponent().graphBar(
                        onTap: () => selectedIndex(index),
                        intake: intake,
                        index: index,
                        isFeed: isFeed,
                        selectedIndex: selectedIndex,
                        maxIntake: maxIntake,
                      )),
                  if (showDay) ...[
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (dateTime.day == 1) ...[
                          Positioned(
                            bottom: 16 * sizeUnit,
                            child: Text(DateFormat.MMMM().format(dateTime).substring(0, 3), style: VfTextStyle.bWriteDate()),
                          ),
                        ],
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
                          child: Obx(() => GraphComponent().xAxisText(
                                text: day.toString(),
                                index: index,
                                selectedIndex: selectedIndex,
                                isFeed: isFeed,
                              )),
                        ),
                      ],
                    ),
                  ] else ...[
                    SvgPicture.asset(
                      svgGraduation,
                      height: 12 * sizeUnit,
                      width: 12 * sizeUnit,
                    ),
                  ],
                ],
              ),
              if (intake.total != 0) ...[
                Obx(() => GraphComponent().gramBubble(
                      intakeAmount: intake.total,
                      index: index,
                      left: -7 * sizeUnit - intake.total.toString().length,
                      mainColor: mainColor,
                      selectedIndex: selectedIndex,
                      maxIntake: maxIntake,
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  // 년 그래프
  Widget yearGraph() {
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.horizontal,
      reverse: true,
      physics: ClampingScrollPhysics(),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemCount: intakeList.length + 1,
      itemBuilder: (context, index) {
        GraphData intake = GraphData();
        String month = ''; // 월
        DateTime dateTime = DateTime(controller.now.year, controller.now.month - (index - 1), controller.now.day); // 월 계산용 dateTime

        // 첫 번째는 다음 달
        if (index == 0) return GraphComponent().buildNextMont();

        // 먹은 양 계산
        if (intakeList.isNotEmpty) intake = intakeList[index - 1];

        // 달 계산
        month = DateFormat.MMMM().format(dateTime).substring(0, 3);

        return Padding(
          padding: EdgeInsets.only(left: index == intakeList.length ? Get.width - (50 * sizeUnit) : 0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5 * sizeUnit),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => GraphComponent().graphBar(
                          onTap: () => selectedIndex(index),
                          intake: intake,
                          index: index,
                          isFeed: isFeed,
                          selectedIndex: selectedIndex,
                          maxIntake: maxIntake,
                        )),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (dateTime.month == 1) ...[
                          Positioned(
                            bottom: 16 * sizeUnit,
                            child: Text(dateTime.year.toString(), style: VfTextStyle.bWriteDate()),
                          ),
                        ],
                        Obx(() => GraphComponent().xAxisText(
                              text: month,
                              index: index,
                              selectedIndex: selectedIndex,
                              isFeed: isFeed,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              // 먹은 양 말풍선 위젯
              if (intake.total != 0) ...[
                Obx(() => GraphComponent().gramBubble(
                      intakeAmount: intake.total,
                      index: index,
                      left: -2 * sizeUnit - intake.total.toString().length,
                      mainColor: mainColor,
                      selectedIndex: selectedIndex,
                      maxIntake: maxIntake,
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}
