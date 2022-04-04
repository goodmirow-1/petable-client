import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/detail_pet_info/detail_pet_info_selected_page.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:reorderables/reorderables.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailPetInfoSelectingPage extends StatefulWidget {
  @override
  _DetailPetInfoSelectingPageState createState() => _DetailPetInfoSelectingPageState();

  final List<String> infoList = [
    '품종',
    '성별',
    '중성화',
    '생년월일',
    '음수량',
    '섭취량',
    '사료정보',
    '나이',
    '몸무게',
    '급여조절',
    '임신 • 수유',
    '질병',
    '알러지',
  ];
}

class _DetailPetInfoSelectingPageState extends State<DetailPetInfoSelectingPage> {
  final DetailPetInfoChoiceController controller = Get.put(DetailPetInfoChoiceController());

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      colorType: vfGradationColorType.Pink,
      type: 2,
      child: Scaffold(
        appBar: vfAppBar(context, title: '반려동물 상세 정보'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24 * sizeUnit),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('정보 선택', style: VfTextStyle.subTitle2()),
                            InkWell(
                              child: Row(
                                children: [
                                  Text('초기화', style: VfTextStyle.body3().copyWith(color: vfColorDarkGray)),
                                  SizedBox(width: 4 * sizeUnit),
                                  SvgPicture.asset(svgInitializationIcon),
                                ],
                              ),
                              onTap: () {
                                controller.isChecked = List.generate(widget.infoList.length, (index) => false).obs;
                                controller.selectedInfoList.clear();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * sizeUnit),
                        GridView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: widget.infoList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return whiteBlock(widget.infoList[index], index);
                          },
                        ),
                        if (controller.selectedInfoList.isNotEmpty) ...[
                          SizedBox(height: 40 * sizeUnit),
                          Text('순서 변경이 가능해요!', style: VfTextStyle.subTitle4()),
                          SizedBox(height: 16 * sizeUnit),
                          selectedInfo(),
                          SizedBox(height: 16 * sizeUnit),
                        ] else ...[
                          SizedBox(height: 28 * sizeUnit),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => vfGradationButton(
                text: '미리보기',
                colorType: vfGradationColorType.Violet,
                isOk: controller.selectedInfoList.isNotEmpty,
                onTap: () async {
                  // 섭취량 또는 음수량 포함시
                  if (controller.selectedInfoList.contains('섭취량') || controller.selectedInfoList.contains('음수량')) {
                    vfLoadingDialog(); // 로딩 시작

                    await GraphPageController.to.setGraph(); // 그래프 세팅

                    Get.back(); // 로딩 끝
                  }

                  Get.to(() => DetailPetInfoSelectedPage(controller.selectedInfoList.value));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectedInfo() {
    List<Widget> _list = List.generate(
      controller.selectedInfoList.length,
      (index) {
        String text = controller.selectedInfoList[index];

        return Padding(
          padding: EdgeInsets.only(right: 8 * sizeUnit, bottom: 8 * sizeUnit),
          child: vfFitContainer(
            padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 9 * sizeUnit),
            isChecked: true,
            fillColor: vfColorPink,
            child: Text(
              text,
              style: VfTextStyle.body2().copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    return ReorderableWrap(
      children: _list,
      buildDraggableFeedback: (context, boxConstraints, widget) {
        return Material(type: MaterialType.transparency, child: widget);
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(
          () {
            final element = _list.removeAt(oldIndex);
            _list.insert(newIndex, element);

            final infoElement = controller.selectedInfoList.removeAt(oldIndex);
            controller.selectedInfoList.insert(newIndex, infoElement);
          },
        );
      },
      needsLongPressDraggable: false,
    );
  }

  Widget whiteBlock(String text, int index) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(1 * sizeUnit),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0.2)],
          ),
        ),
        child: Container(
          width: 88 * sizeUnit,
          height: 88 * sizeUnit,
          decoration: BoxDecoration(
            color: (controller.isChecked[index] == true) ? vfColorPink : Color.fromRGBO(255, 255, 255, 0.8),
            boxShadow: vfBasicBoxShadow,
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            // border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.8))
          ),
          child: Center(
            child: Text(
              text,
              style: (controller.isChecked[index] == true) ? VfTextStyle.subTitle4().copyWith(color: Colors.white) : VfTextStyle.subTitle4(),
            ),
          ),
        ),
      ),
      onTap: () {
        if (text == '사료정보' && GlobalData.mainPet.value.feed!.feedID == 0) {
          Fluttertoast.showToast(
            msg: '사료를 등록해 주세요.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
            textColor: Colors.white,
          );

          return;
        }
        controller.isChecked[index] = !controller.isChecked[index];
        if (controller.isChecked[index] == true) {
          controller.selectedInfoList.add(text);
        } else {
          controller.selectedInfoList.remove(text);
        }
      },
    );
  }
}

class DetailPetInfoChoiceController extends GetxController {
  RxList<bool> isChecked = List.generate(DetailPetInfoSelectingPage().infoList.length, (index) => false).obs;
  RxList selectedInfoList = [].obs;
}
