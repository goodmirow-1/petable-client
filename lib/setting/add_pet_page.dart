import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart' hide FormData;
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/intake/controller/feed_database.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/initiation/initiation_pet_page.dart';
import 'package:extended_image/extended_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/intake/controller/snack_intake_database.dart';
import 'package:reorderables/reorderables.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({Key? key}) : super(key: key);

  @override
  _AddPetPageState createState() => _AddPetPageState();
}

typedef DragTargetBuilder<T> = Widget Function(BuildContext context, List<T> candidateData, List<dynamic> rejectedData, List<Offset> candidateOffsets);

class _AddPetPageState extends State<AddPetPage> {
  final AddPetController controller = Get.put(AddPetController());

  List<Widget> _list = [];
  List<int> removeIdList = [];
  static const int MAX_PET_COUNT = 99;

  @override
  void initState() {
    for (int i = 0; i < GlobalData.petList.length; i++) {
      controller.isCheckButtonClicked.add(false);
      controller.tmpPetList.add(GlobalData.petList[i]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '반려동물',
          backFunc: () {
            if (controller.isEditButtonClicked.isTrue) {
              showVfDialog(
                  title: '저장하지 않고\n나가시겠어요?',
                  colorType: vfGradationColorType.Violet,
                  isCancelButton: true,
                  okFunc: () {
                    Get.back();
                    Get.back();
                  });
            } else {
              Get.back();
            }
          },
          actions: [
            TextButton(
              onPressed: () async {
                controller.isEditButtonClicked(!controller.isEditButtonClicked.value);

                // 완료를 눌렀을 때
                if (controller.isEditButtonClicked.isFalse) {
                  List<int> petIdList = [];
                  List<int> petIndexList = [];

                  for (int i = 0; i < controller.tmpPetList.length; i++) {
                    petIdList.add(controller.tmpPetList[i].id);
                    petIndexList.add(i);
                    controller.isCheckButtonClicked[i] = false;
                  }

                  FormData formData = FormData.fromMap({
                    'userID': GlobalData.loggedInUser.value.userID,
                    'petidlist': petIdList,
                    'petindexlist': petIndexList,
                  });

                  try {
                    Dio dio = new Dio();
                    await dio.post(ApiProvider().getUrl + '/Pet/Index/Reorder', data: formData);
                  } on DioError catch (e) {
                    Fluttertoast.showToast(
                      msg: '수정에 실패했습니다. 다시 시도해주세요.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                      textColor: Colors.white,
                    );
                    throw (e.message);
                  }

                  // 삭제
                  bool isCheck = true;
                  for (int i = 0; i < removeIdList.length; i++) {
                    var delRes = await ApiProvider().post(
                        '/Pet/Delete',
                        jsonEncode({
                          'petID': removeIdList[i],
                          'userID': GlobalData.loggedInUser.value.userID,
                        }));

                    if (delRes) {
                      // 삭제할 때 사료 디비도 지우기
                      await FeedDBHelper().deleteData(removeIdList[i]);
                      await SnackDBHelper().deleteByPetID(removeIdList[i]);

                      // 펫 리스트 동기화
                      final prefs = await SharedPreferences.getInstance();

                      String removedPetKind = GlobalData.petList.singleWhere((element) => element.id == removeIdList[i]).kind; // 삭제된 펫의 품종
                      int kindCount = 0; // 펫리스트에 삭제되는 품종이 갯수

                      // 펫리스트에 삭제되는 품종이랑 같은 품종이 있는지 확인
                      GlobalData.petList.forEach((element) {
                        if(element.kind == removedPetKind) kindCount++;
                      });

                      // 같은 품종이 없으면
                      if(kindCount < 2) {
                        // 필터 세팅
                        for (int i = 0; i < GlobalData.communityPetKinds.length; i++) {
                          if (GlobalData.communityPetKinds[i] == removedPetKind) {
                            GlobalData.communityPetKinds.removeAt(i);
                            FilterController.to.communityPetKindCheckList.removeAt(i); // boolList 세팅
                            break;
                          }
                        }

                        GlobalData.myPetKinds.removeWhere((element) => element == removedPetKind); // 펫 품종 리스트 세팅
                        prefs.setStringList('communityPetKindList', GlobalData.communityPetKinds); //  로컬 db 세팅
                      }
                    } else {
                      isCheck = false;
                    }
                  }

                  if (isCheck == false) {
                    Fluttertoast.showToast(
                      msg: '수정에 실패했습니다. 다시 시도해주세요.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                      textColor: Colors.white,
                    );
                  }

                  // 초기화
                  removeIdList.clear();
                  GlobalData.petList(controller.tmpPetList);

                  if (controller.tmpPetList.isEmpty) {
                    GlobalData.mainPet = Pet().obs;
                    DashBoardController.to.stateUpdate();
                  } else {
                    await NavigationController.to.changePet(controller.tmpPetList[0]);
                  }

                  if (controller.tmpPetList.isNotEmpty)
                    Fluttertoast.showToast(
                      msg: '수정을 완료했습니다.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                      textColor: Colors.white,
                    );
                }
              },
              child: Obx(
                () => (controller.isEditButtonClicked.isFalse)
                    ? Text(
                        '편집',
                        style: VfTextStyle.subTitle4().copyWith(color: vfColorGrey),
                      )
                    : Text(
                        '완료',
                        style: VfTextStyle.subTitle4().copyWith(color: vfColorPink),
                      ),
              ),
            ),
          ],
        ),
        body: Obx(
          () => (controller.isEditButtonClicked.isFalse)
              ? (controller.tmpPetList.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '반려동물을\n추가해 주세요',
                            style: VfTextStyle.headline3(),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24 * sizeUnit),
                          addPetContainer(),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          petList(),
                          if (controller.tmpPetList.length < MAX_PET_COUNT) ...[
                            Padding(
                              padding: EdgeInsets.only(left: 24 * sizeUnit, top: 16 * sizeUnit, bottom: 24 * sizeUnit),
                              child: addPetContainer(),
                            ),
                          ],
                        ],
                      ),
                    )
              : Column(
                  children: [
                    petEditList(),
                    removeButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget petList() {
    return Column(
      children: [
        for (int i = 0; i < controller.tmpPetList.length; i++) ...[
          Padding(
            padding: EdgeInsets.only(left: 24 * sizeUnit, top: 16 * sizeUnit),
            child: Container(
              height: 48 * sizeUnit,
              child: Row(
                children: [
                  Container(
                    height: 48 * sizeUnit,
                    width: 48 * sizeUnit,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(60 * sizeUnit),
                      child: FittedBox(
                        child: (controller.tmpPetList[i].petPhotos.isEmpty) ? vfGradationIconWidget(iconPath: svgFootIcon) : ExtendedImage.network(controller.tmpPetList[i].petPhotos[0].imageUrl),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12 * sizeUnit, 4 * sizeUnit, 0 * sizeUnit, 6 * sizeUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.tmpPetList[i].name, style: VfTextStyle.subTitle3()),
                        SizedBox(height: 5 * sizeUnit),
                        Row(
                          children: [
                            miniContainer(controller.tmpPetList[i].kind),
                            SizedBox(width: 4 * sizeUnit),
                            miniContainer(controller.tmpPetList[i].birthday),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget petEditList() {
    _list = [
      for (int i = 0; i < controller.tmpPetList.length; i++) ...[
        SizedBox(
          key: ValueKey(i),
          width: 360 * sizeUnit,
          child: Padding(
            padding: EdgeInsets.only(left: 24 * sizeUnit, top: 16 * sizeUnit, right: 40 * sizeUnit),
            child: Container(
              height: 48 * sizeUnit,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8 * sizeUnit),
                    child: Obx(
                      () => InkWell(
                          onTap: () {
                            controller.isCheckButtonClicked[i] = !controller.isCheckButtonClicked[i];
                          },
                          child: (controller.isCheckButtonClicked[i] == false) ? SvgPicture.asset(svgCircleUncheck) : SvgPicture.asset(svgCircleCheck)),
                    ),
                  ),
                  Container(
                    height: 48 * sizeUnit,
                    width: 48 * sizeUnit,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(60 * sizeUnit),
                      child: FittedBox(
                        child: (controller.tmpPetList[i].petPhotos.isEmpty) ? vfGradationIconWidget(iconPath: svgFootIcon) : ExtendedImage.network(controller.tmpPetList[i].petPhotos[0].imageUrl),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12 * sizeUnit, 4 * sizeUnit, 0 * sizeUnit, 6 * sizeUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.tmpPetList[i].name, style: VfTextStyle.subTitle3()),
                        SizedBox(height: 5 * sizeUnit),
                        Row(
                          children: [
                            miniContainer(controller.tmpPetList[i].kind),
                            SizedBox(width: 4 * sizeUnit),
                            miniContainer(controller.tmpPetList[i].birthday),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SvgPicture.asset(
                    svgReorderIcon,
                    height: 24 * sizeUnit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
    ];

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 16 * sizeUnit),
        child: ReorderableColumn(
          children: _list,
          buildDraggableFeedback: (context, boxConstraints, widget) {
            return Material(type: MaterialType.transparency, child: widget);
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final element = _list.removeAt(oldIndex);
              _list.insert(newIndex, element);

              final petElement = controller.tmpPetList.removeAt(oldIndex);
              controller.tmpPetList.insert(newIndex, petElement);

              final checkElement = controller.isCheckButtonClicked.removeAt(oldIndex);
              controller.isCheckButtonClicked.insert(newIndex, checkElement);
            });
          },
          needsLongPressDraggable: false,
        ),
      ),
    );
  }

  Widget miniContainer(String text) {
    return Container(
      height: 14 * sizeUnit,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        borderRadius: BorderRadius.circular(10 * sizeUnit),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4 * sizeUnit, 1 * sizeUnit, 4 * sizeUnit, 1 * sizeUnit),
        child: Text(
          text,
          style: VfTextStyle.subTitle5(),
        ),
      ),
    );
  }

  Widget addPetContainer() {
    return GestureDetector(
      child: Container(
        height: 48 * sizeUnit,
        width: 48 * sizeUnit,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: BorderRadius.circular(24 * sizeUnit),
          boxShadow: vfBasicBoxShadow,
        ),
        child: DottedBorder(
          borderType: BorderType.Circle,
          dashPattern: [4 * sizeUnit, 4 * sizeUnit],
          strokeWidth: 2 * sizeUnit,
          color: vfColorGrey,
          child: Center(
            child: SvgPicture.asset(
              svgPetAddIcon,
              height: 18 * sizeUnit,
              width: 18 * sizeUnit,
            ),
          ),
        ),
      ),
      onTap: () {
        if (controller.tmpPetList.length < MAX_PET_COUNT) Get.to(() => InitiationPetPage(isAdd: true));
      },
    );
  }

  Widget removeButton() {
    return vfGradationButton(
      text: '삭제하기',
      colorType: vfGradationColorType.Violet,
      onTap: () {
        showVfDialog(
          title: '프로필을\n삭제하시겠어요?',
          colorType: vfGradationColorType.Violet,
          description: '확인 후에는 해당 반려동물에 관한\n모든 기록이 삭제됩니다.',
          isCancelButton: true,
          okFunc: () {
            for (int i = controller.tmpPetList.length - 1; i >= 0; i--) {
              if (controller.isCheckButtonClicked[i] == true) {
                removeIdList.add(controller.tmpPetList[i].id);
                _list.removeAt(i);
                controller.tmpPetList.removeAt(i);
                controller.isCheckButtonClicked.removeAt(i);
              }
            }

            Get.back();
          },
        );
      },
    );
  }
}

class AddPetController extends GetxController {
  RxList<Pet> tmpPetList = <Pet>[].obs;

  RxBool isEditButtonClicked = false.obs;

  RxList isCheckButtonClicked = [].obs;
}
