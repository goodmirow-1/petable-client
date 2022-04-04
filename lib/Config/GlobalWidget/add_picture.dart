import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvef_app/Config/GlobalWidget/edit_image_page.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:extended_image/extended_image.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:reorderables/reorderables.dart';
import '../GlobalFunction.dart';

// Obx 를 사용하기 때문에 controller에서 imageList를 선언한 뒤 사용해야 함
class AddPicture extends StatefulWidget {
  AddPicture({required this.imageList, required this.isModify, this.isUser = false, this.color = ADD_PICTURE_RED});

  final List imageList;
  final bool isModify;
  final bool isUser;
  final int color;

  @override
  _AddPictureState createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  int imageIdx = 0;
  late final int IMAGE_MAX_NUM;

  @override
  void initState() {
    super.initState();

    if (widget.isUser)
      IMAGE_MAX_NUM = 1;
    else
      IMAGE_MAX_NUM = 5;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.imageList.isEmpty) ...[
                defaultImage(),
              ] else ...[
                if (widget.isUser == false) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      smallImages(),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: 76 * sizeUnit),
                ],
                image(), // 큰 사진
              ],
              getImage(),
              SizedBox(height: 40 * sizeUnit)
            ],
          ),
        ),
      ),
    );
  }

  // 사진 없을 때 기본 이미지
  Widget defaultImage() {
    return Padding(
      padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit, bottom: 40 * sizeUnit, top: (widget.isModify) ? 76 * sizeUnit : 112 * sizeUnit),
      child: GestureDetector(
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: [4 * sizeUnit, 4 * sizeUnit],
          strokeWidth: 2 * sizeUnit,
          radius: Radius.circular(24 * sizeUnit),
          color: vfColorGrey,
          child: Container(
            width: 280 * sizeUnit,
            height: 292 * sizeUnit,
            constraints: BoxConstraints(maxHeight: Get.height * 0.55),
            //세로길이 짧은 폰을 위해
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.all(Radius.circular(24 * sizeUnit)),
              boxShadow: vfBasicBoxShadow,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 53 * sizeUnit, right: 53 * sizeUnit),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  vfPramBodyGoodStateWidget(),
                  SizedBox(
                    height: 24 * sizeUnit,
                  ),
                  Text(
                    (widget.isUser) ? '본인 사진은\n1개만 등록 가능해요.' : '사진은 최대 5개까지\n등록 가능해요.',
                    textAlign: TextAlign.center,
                    style: VfTextStyle.body1(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 위에 작은 사진 다섯개
  Widget smallImages() {
    List<Widget> _list = List<Widget>.generate(
      widget.imageList.length,
      (idx) {
        return Padding(
          padding: EdgeInsets.only(left: 8 * sizeUnit, right: 8 * sizeUnit),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44 * sizeUnit,
                height: 44 * sizeUnit,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: (widget.color == ADD_PICTURE_RED) ? [vfGradationRed2, vfGradationRed1] : [vfGradationViolet2, vfGradationViolet1],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: 40 * sizeUnit,
                  height: 40 * sizeUnit,
                  decoration: (widget.imageList[idx] is File)
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          image: widget.imageList.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(widget.imageList[idx]),
                                  fit: BoxFit.fill,
                                )
                              : null,
                        )
                      : null,
                  child: (widget.imageList[idx] is PetPhotos)
                      ? ClipRRect(
                          borderRadius: new BorderRadius.circular(50 * sizeUnit),
                          child: GetExtendedImage(
                            url: widget.imageList[idx].imageUrl,
                            boxFit: BoxFit.fill,
                          ),
                        )
                      : null,
                ),
                onTap: () {
                  setState(() {
                    imageIdx = idx;
                  });
                },
              ),
            ],
          ),
        );
      },
    );

    return Padding(
      padding: EdgeInsets.only(left: 28 * sizeUnit, bottom: 16 * sizeUnit, top: (widget.isModify) ? 16 * sizeUnit : 52 * sizeUnit),
      child: ReorderableWrap(
        children: _list,
        buildDraggableFeedback: (context, boxConstraints, widget) {
          return Material(type: MaterialType.transparency, child: widget);
        },
        onReorderStarted: (int index) {
          if (widget.imageList[index] is File) {
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
          if (widget.imageList[oldIndex] is PetPhotos) {
            setState(() {
              final element = _list.removeAt(oldIndex);
              _list.insert(newIndex, element);

              final imageElement = widget.imageList.removeAt(oldIndex);
              widget.imageList.insert(newIndex, imageElement);

              imageIdx = newIndex;
            });
          }
        },
        needsLongPressDraggable: false,
      ),
    );
  }

  // 큰 사진
  Widget image() {
    return Padding(
      padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit, bottom: 40 * sizeUnit),
      child: Stack(
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: [4 * sizeUnit, 4 * sizeUnit],
            strokeWidth: 2 * sizeUnit,
            radius: Radius.circular(24 * sizeUnit),
            color: vfColorGrey,
            child: Container(
              width: 280 * sizeUnit,
              height: 292 * sizeUnit,
              constraints: BoxConstraints(maxHeight: Get.height * 0.55),
              //세로길이 짧은 폰을 위해
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(24 * sizeUnit)),
                boxShadow: vfBasicBoxShadow,
                image: (widget.imageList.isNotEmpty && widget.imageList[imageIdx] is File)
                    ? DecorationImage(
                        image: FileImage(widget.imageList[imageIdx]),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              child: widget.imageList[imageIdx] is! File
                  ? ClipRRect(
                      borderRadius: new BorderRadius.circular(24 * sizeUnit),
                      child: GetExtendedImage(
                        url: (widget.isUser == true) ? widget.imageList[imageIdx] : widget.imageList[imageIdx].imageUrl,
                        boxFit: BoxFit.contain,
                      ),
                    )
                  : null,
            ),
          ),
          // 취소버튼
          Positioned(
            child: GestureDetector(
              child: Container(
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: (widget.color == ADD_PICTURE_RED) ? [vfGradationRed2, vfGradationRed1] : [vfGradationViolet2, vfGradationViolet1],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7.05),
                    child: SvgPicture.asset(svgWhiteCancelIcon),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  widget.imageList.removeAt(imageIdx);
                  if (imageIdx != 0) imageIdx -= 1;
                });
              },
            ),
            top: 10 * sizeUnit,
            right: 10 * sizeUnit,
          ),
        ],
      ),
    );
  }

  // 사진찍기, 사진선택 버튼
  Widget getImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Container(
            width: 136 * sizeUnit,
            height: 48 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '사진찍기',
                  style: VfTextStyle.subTitle2(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 8 * sizeUnit),
                SvgPicture.asset(svgCameraIcon),
              ],
            ),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28 * sizeUnit), boxShadow: vfBasicBoxShadow),
          ),
          onTap: () async {
            uploadImage(ImageSource.camera);

            setState(() {});
          },
        ),
        SizedBox(
          width: 8 * sizeUnit,
        ),
        GestureDetector(
          child: Container(
            width: 136 * sizeUnit,
            height: 48 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '사진선택',
                  style: VfTextStyle.subTitle2(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 8 * sizeUnit),
                SvgPicture.asset(svgPictureIcon),
              ],
            ),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28 * sizeUnit), boxShadow: vfBasicBoxShadow),
          ),
          onTap: () async {
            setState(() {
              uploadImage(ImageSource.gallery);
            });
          },
        ),
      ],
    );
  }

  // 사진 등록
  Future<void> uploadImage(ImageSource source) async {
    if (widget.imageList.length < IMAGE_MAX_NUM) {
      vfLoadingDialog(); // 로딩 인디케이터 시작
      PickedFile? pickedFile = await ImagePicker.platform.pickImage(source: source);

      Get.back();// 로딩 인디케이터 끄기
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        if (await isBigFile(image) == false) {
          Get.to(() => EditImagePage(imageFile: image))!.then((value) {
            if (value != null) {
              widget.imageList.add(value);
              imageIdx = widget.imageList.length - 1;
            }
          });
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: '사진을 지우고 다시 시도해 주세요.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );
    }
  }
}
