import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:myvef_app/graph/graph_widget.dart';

import '../Config/GlobalWidget/GlobalWidget.dart';
import '../Config/GlobalWidget/animated_tap_bar.dart';
import 'controller/graph_page_controller.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final GraphPageController controller = Get.find<GraphPageController>();
  final NavigationController navController = Get.find<NavigationController>();

  vfGradationColorType colorType = vfGradationColorType.Red;

  @override
  void initState() {
    // 그래프 세팅
    if (!GlobalData.backLoading.value && GlobalData.petList.isNotEmpty) {
      controller.now = DateTime.now();

      Future.microtask(() async {
        controller.isLoading = true;
        controller.stateUpdate();

        await controller.setGraph();

        controller.isLoading = false;
        controller.stateUpdate();
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    controller.barIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 3,
      colorType: colorType,
      child: Scaffold(
        appBar: vfAppBar(context, title: '그래프', isBackButton: false),
        body: Column(
          children: [
            Obx(() {
              return AnimatedTapBar(
                barIndex: controller.barIndex.value,
                pageController: controller.pageController,
                listTabItemTitle: ['섭취량', '음수량'],
              );
            }),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  controller.barIndex.value = index;

                  if (controller.barIndex.value == GRAPH_TYPE_FEED) {
                    colorType = vfGradationColorType.Red;
                    navController.changeNavColor(itemColor: vfColorOrange, petColors: navRedColorList); // 네비게이션 아이콘 색 바꾸기
                  } else {
                    colorType = vfGradationColorType.Blue;
                    navController.changeNavColor(itemColor: vfColorWaterBlue, petColors: navBlueColorList); // 네비게이션 아이콘 색 바꾸기
                  }

                  setState(() {});
                },
                children: [
                  buildGraph(), // 사료 그래프
                  buildGraph(), // 물 그래프
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGraph() {
    return Obx(() => GlobalData.backLoading.value
        ? Center(
            child: GradientCircularProgressIndicator(
            gradientColors: controller.barIndex.value == GRAPH_TYPE_FEED ? loadingRedColorList : loadingBlueColorList,
          ))
        : Column(
            children: [
              Expanded(
                child: GetBuilder<GraphPageController>(
                  builder: (_) {
                    if (controller.isLoading)
                      return Center(
                          child: GradientCircularProgressIndicator(
                        gradientColors: controller.barIndex.value == GRAPH_TYPE_FEED ? loadingRedColorList : loadingBlueColorList,
                      ));
                    else
                      return GraphWidget();
                  },
                ),
              ),
              SizedBox(height: controller.isShortPhone ? 10 * sizeUnit : 20 * sizeUnit),
            ],
          ));
  }
}
