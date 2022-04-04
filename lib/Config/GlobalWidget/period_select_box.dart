import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/detail_pet_info/detail_pet_info_selected_page.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'GlobalWidget.dart';

// ignore: must_be_immutable
class PeriodSelectBox extends StatelessWidget {
  PeriodSelectBox({required this.color, required this.itemScrollController});

  final Color color;
  final ItemScrollController itemScrollController;
  final GraphPageController controller = Get.find<GraphPageController>();
  final List<String> _listPeriod = ['일', '주', '월', '년'];


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96 * sizeUnit,
      height: 24 * sizeUnit,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * sizeUnit),
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), offset: Offset(0, 2 * sizeUnit), blurRadius: 2 * sizeUnit)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _listPeriod
            .asMap()
            .map((index, element) => MapEntry(
                index,
                GestureDetector(
                  onTap: (){
                    if(index != controller.periodIndex.value) {
                      controller.periodIndex(index);
                      if(itemScrollController.isAttached) itemScrollController.jumpTo(index: 0); // 스크롤 초기화
                      controller.stateUpdate(); // setState
                      if(Get.currentRoute == '/DetailPetInfoSelectedPage') DetailPetInfoController.to.stateUpdate(); // 반려동물 상세 정보 setState
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12*sizeUnit),
                    child: Container(
                      width: 24 * sizeUnit,
                      height: 24 * sizeUnit,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: 18 * sizeUnit,
                              height: 18 * sizeUnit,
                              decoration: BoxDecoration(
                                color: controller.periodIndex.value == index ? color : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2 * sizeUnit, sigmaY: 2 * sizeUnit),
                              child: Container(
                                width: 24*sizeUnit,
                                height: 24*sizeUnit,
                                color: Colors.black.withOpacity(0),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              element,
                              style: VfTextStyle.body2().copyWith(color: controller.periodIndex.value == index ? Colors.white : vfColorDarkGray, height: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )))
            .values
            .toList(),
      ),
    );
  }
}
