import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/community/controller/community_write_or_modify_controller.dart';
import 'package:reorderables/reorderables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityAddPicturePage extends StatefulWidget {
  CommunityAddPicturePage({Key? key, required this.isWrite}) : super(key: key);

  final bool isWrite;

  @override
  State<CommunityAddPicturePage> createState() => _CommunityAddPicturePageState();
}

class _CommunityAddPicturePageState extends State<CommunityAddPicturePage> {
  final CommunityWriteOrModifyController controller = Get.put(CommunityWriteOrModifyController());

  @override
  void dispose() {
    super.dispose();

    controller.tmpImageList.clear();
    controller.selectedImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(context, title: widget.isWrite ? '글쓰기' : '수정하기'),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
                    child: Column(
                      children: [
                        buildCircleImageList(),
                        SizedBox(height: 18 * sizeUnit),
                        buildImageContainer(),
                        SizedBox(height: 40 * sizeUnit),
                        buildButtonsArea(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            vfGradationButton(
              text: '선택 완료',
              colorType: vfGradationColorType.Violet,
              onTap: () => controller.imageSelectionComplete(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircleImageList() {
    List<Widget> _list = List.generate(controller.tmpImageList.length, (index) => buildCircleImageItem(index));

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ReorderableWrap(
            children: _list,
            buildDraggableFeedback: (context, boxConstraints, widget) {
              return Material(type: MaterialType.transparency, child: widget);
            },
            onReorderStarted: (int index) {
              if (controller.tmpImageList[index] is XFile) {
                Fluttertoast.showToast(
                  msg: '지금 추가한 사진은 순서를 변경할 수 없어요.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                  textColor: Colors.white,
                );
              }
            },
            onReorder: (int oldIndex, int newIndex) {
              if (controller.tmpImageList[oldIndex] is String) {
                setState(() {
                  final element = _list.removeAt(oldIndex);
                  _list.insert(newIndex, element);

                  final imageElement = controller.tmpImageList.removeAt(oldIndex);
                  controller.tmpImageList.insert(newIndex, imageElement);
                });
              }
            },
            needsLongPressDraggable: false,
          )),
    );
  }

  Widget buildCircleImageItem(int index) {
    return GestureDetector(
      onTap: () {
        controller.selectedImage = controller.tmpImageList[index];
        setState(() {});
      },
      child: Container(
        width: 40 * sizeUnit,
        height: 40 * sizeUnit,
        padding: EdgeInsets.all(2 * sizeUnit),
        margin: EdgeInsets.only(right: 20 * sizeUnit),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: navVioletColorList,
            stops: [0.5, 1.6], //그라데이션 위치 보정값
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          child: controller.tmpImageList[index] is XFile
              ? Image(
                  image: FileImage(File(controller.tmpImageList[index].path)),
                  fit: BoxFit.cover,
                )
              : ExtendedImage.network(
                  controller.tmpImageList[index],
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Row buildButtonsArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildChoiceButton(
          text: '사진찍기',
          iconPath: svgCameraIcon,
          onTap: () => controller.getImageEvent(isCamera: true).then((value) => setState(() {})),
        ),
        SizedBox(width: 8 * sizeUnit),
        buildChoiceButton(
          text: '사진선택',
          iconPath: svgPictureIcon,
          onTap: () => controller.getImageEvent(isCamera: false).then((value) => setState(() {})),
        ),
      ],
    );
  }

  GestureDetector buildChoiceButton({required String text, required String iconPath, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 136 * sizeUnit,
        height: 48 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: vfBasicBoxShadow,
          borderRadius: BorderRadius.circular(28 * sizeUnit),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: VfTextStyle.body1(),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8 * sizeUnit),
            SvgPicture.asset(
              iconPath,
              width: 24 * sizeUnit,
              height: 24 * sizeUnit,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageContainer() {
    return Stack(
      children: [
        Container(
          width: 280 * sizeUnit,
          height: 292 * sizeUnit,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
            image: controller.selectedImage != null && controller.selectedImage is XFile
                ? DecorationImage(
                    image: FileImage(File(controller.selectedImage!.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: [4 * sizeUnit, 4 * sizeUnit],
            strokeWidth: 2 * sizeUnit,
            radius: Radius.circular(24 * sizeUnit),
            color: vfColorGrey,
            child: Center(
              child: controller.selectedImage != null
                  ? controller.selectedImage is XFile
                      ? null
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24 * sizeUnit),
                          child: ExtendedImage.network(
                            controller.selectedImage,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        vfPramBodyGoodStateWidget(),
                        SizedBox(height: 24 * sizeUnit),
                        Text(
                          '사진은 최대 3개 까지\n등록 가능해요.',
                          style: VfTextStyle.body1(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (controller.selectedImage != null) ...[
          Positioned(
            top: 10 * sizeUnit,
            right: 10 * sizeUnit,
            child: GestureDetector(
              onTap: () {
                controller.cancelSelectedImage();
                setState(() {});
              },
              child: Container(
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [vfColorViolet60, vfColorPink60],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7.05),
                    child: SvgPicture.asset(svgWhiteCancelIcon),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
