import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/community/community_add_picture_page.dart';
import 'package:myvef_app/community/controller/community_write_or_modify_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myvef_app/community/pet_kind_selection_page.dart';

class CommunityWriteOrModifyPage extends StatefulWidget {
  const CommunityWriteOrModifyPage({Key? key, required this.isWrite, this.community}) : super(key: key);

  final bool isWrite; // 글쓰기인지 수정인지
  final Community? community; // 수정인 경우만 들어옴

  @override
  State<CommunityWriteOrModifyPage> createState() => _CommunityWriteOrModifyPageState();
}

class _CommunityWriteOrModifyPageState extends State<CommunityWriteOrModifyPage> {
  final CommunityWriteOrModifyController controller = Get.put(CommunityWriteOrModifyController());
  final TextEditingController titleTextController = TextEditingController(); // 제목 컨트롤러
  final TextEditingController contentsTextController = TextEditingController(); // 내용 컨트롤러

  final String svgAddIcon = 'assets/image/community/floatingAddIcon.svg'; // add 아이콘

  Community community = Community();

  @override
  void initState() {
    if (widget.isWrite) {
      controller.setCategoryList(); // 주제 세팅
    } else {
      community = widget.community!;

      titleTextController.text = community.title; // 제목
      contentsTextController.text = community.contents; // 내용
      controller.title(community.title); // 제목
      controller.contents(community.contents); // 내용
      controller.imageList.addAll(community.imgUrlList); // 이미지
    }

    super.initState();
  }

  @override
  void dispose() {
    titleTextController.dispose();
    contentsTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          appBar: vfAppBar(
            context,
            title: widget.isWrite ? '글쓰기' : '수정하기',
            actions: [
              submitButton(
                isOk: widget.isWrite ? controller.isOkForWrite : controller.isOkForModify,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24 * sizeUnit),
                if (widget.isWrite) ...[
                  buildCategories(), // 주제
                  SizedBox(height: 24 * sizeUnit),
                  buildPetKinds(), // 품종
                  SizedBox(height: 24 * sizeUnit),
                  buildArea(), // 지역
                  SizedBox(height: 24 * sizeUnit),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                    child: Text('*주제, 품종, 지역은 수정이 불가능해요', style: VfTextStyle.body2()),
                  ),
                  SizedBox(height: 24 * sizeUnit),
                ],
                buildTitle(), // 제목
                SizedBox(height: 24 * sizeUnit),
                buildContents(), // 내용
                SizedBox(height: 24 * sizeUnit),
                buildPhotos(), // 사진
                if (widget.isWrite) SizedBox(height: 20 * sizeUnit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Center submitButton({required RxBool isOk}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: 16 * sizeUnit),
        child: GestureDetector(
          onTap: () {
            unFocus(context);

            if (isOk.value) {
              controller.communityWriteOrModify(isWrite: widget.isWrite, community: community);
            } else {
              controller.notOkToast(widget.isWrite);
            }
          },
          child: Obx(
            () => Text(
              '완료',
              style: VfTextStyle.subTitle4().copyWith(color: isOk.value ? vfColorPink : vfColorGrey),
            ),
          ),
        ),
      ),
    );
  }

  Column buildPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleAndInfo(title: '사진', info: '사진은 최대 3개까지 가능해요'),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
          child: Obx(
            () => Wrap(
              spacing: 10 * sizeUnit,
              runSpacing: 10 * sizeUnit,
              children: List.generate(controller.imageList.length + 1, (index) {
                if (controller.imageList.length == index) return addImgContainer();
                return imgContainer(controller.imageList[index], index);
              }),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 추가 버튼
  Widget imgContainer(image, int index) {
    return Stack(
      children: [
        Container(
          width: 96 * sizeUnit,
          height: 96 * sizeUnit,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.circular(16 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
            image: (image is XFile)
                ? DecorationImage(
                    image: FileImage(File(image.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (image is XFile)
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16 * sizeUnit),
                  child: ExtendedImage.network(image, fit: BoxFit.cover),
                ),
        ),
        Positioned(
          top: 6 * sizeUnit,
          right: 6 * sizeUnit,
          child: GestureDetector(
            onTap: () {
              controller.imageList.remove(image);
              if (!widget.isWrite && image is String) controller.setRemoveList(community, image);
            },
            child: Container(
              width: 16 * sizeUnit,
              height: 16 * sizeUnit,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: vfColorDarkGray,
              ),
              child: SvgPicture.asset(
                svgWhiteCancelIcon,
                width: 8 * sizeUnit,
                height: 8 * sizeUnit,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 추가 버튼
  GestureDetector addImgContainer() {
    return GestureDetector(
      onTap: () {
        unFocus(context);
        if (controller.imageList.isNotEmpty) {
          controller.tmpImageList = [...controller.imageList].obs;
          controller.selectedImage = controller.tmpImageList.last;
        }
        Get.to(() => CommunityAddPicturePage(isWrite: widget.isWrite));
      },
      child: Container(
        width: 96 * sizeUnit,
        height: 96 * sizeUnit,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: BorderRadius.circular(16 * sizeUnit),
          boxShadow: vfBasicBoxShadow,
        ),
        child: SvgPicture.asset(
          svgAddIcon,
          width: 24 * sizeUnit,
          height: 24 * sizeUnit,
          color: vfColorGrey,
        ),
      ),
    );
  }

  Column buildContents() {
    return Column(
      children: [
        buildTitleAndLength(
          title: '내용',
          referenceString: controller.contents,
          maxLength: controller.contentsMaxLength,
        ),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
          child: Obx(() => vfTextField(
                textEditingController: contentsTextController,
                hintText: '${controller.CONTENTS_MIN_NUM}자 이상',
                textStyle: VfTextStyle.body2(),
                hintStyle: VfTextStyle.body2().copyWith(color: vfColorDarkGray),
                contentPadding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 17 * sizeUnit),
                errorText: controller.contents.value.isNotEmpty && controller.contents.value.length < controller.CONTENTS_MIN_NUM ? '${controller.CONTENTS_MIN_NUM}자 이상 입력해 주세요.' : null,
                borderColor: vfColorPink,
                maxLength: controller.contentsMaxLength,
                maxLines: 6,
                onChanged: (value) {
                  controller.contents(value);
                  controller.okCheck(widget.isWrite);
                },
              )),
        ),
      ],
    );
  }

  Column buildTitle() {
    return Column(
      children: [
        buildTitleAndLength(
          title: '제목',
          referenceString: controller.title,
          maxLength: controller.titleMaxLength,
        ),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
          child: Obx(() => vfTextField(
                textEditingController: titleTextController,
                hintText: '2자 이상',
                textStyle: VfTextStyle.body2(),
                hintStyle: VfTextStyle.body2().copyWith(color: vfColorDarkGray),
                contentPadding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 17 * sizeUnit),
                errorText: controller.title.value.isNotEmpty && controller.title.value.length < controller.TITLE_MIN_NUM ? '2자 이상 입력해 주세요.' : null,
                borderColor: vfColorPink,
                maxLength: controller.titleMaxLength,
                onChanged: (value) {
                  controller.title(value);
                  controller.okCheck(widget.isWrite);
                },
              )),
        ),
      ],
    );
  }

  // 제목과 최대 글자수
  Widget buildTitleAndLength({required String title, required int maxLength, required RxString referenceString}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: VfTextStyle.subTitle4()),
          Obx(() => Text('${referenceString.value.length}/$maxLength', style: VfTextStyle.bWriteDate())),
        ],
      ),
    );
  }

  Widget buildArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleAndInfo(title: '지역', info: '지역은 변경이 불가능해요'),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
          child: vfFitContainer(
            padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 9 * sizeUnit),
            isChecked: true,
            fillColor: vfColorGrey,
            child: Text(
              abbreviateForLocation(GlobalData.loggedInUser.value.location),
              style: VfTextStyle.body2().copyWith(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleAndInfo(title: '주제'),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.only(left: 32 * sizeUnit, right: 24 * sizeUnit),
          child: Wrap(
            children: List.generate(
              controller.categoryList.length,
              (index) {
                String text = controller.categoryList[index];

                return Obx(() => wrapItem(
                      text: text,
                      isChecked: controller.category.value == text,
                      index: index,
                      onTap: () {
                        controller.toggleCategory(text);
                        controller.okCheck(widget.isWrite);
                      },
                    ));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPetKinds() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleAndInfo(title: '품종', info: '최대 3개까지 선택 가능해요'),
        SizedBox(height: 8 * sizeUnit),
        Padding(
          padding: EdgeInsets.only(left: 32 * sizeUnit, right: 24 * sizeUnit),
          child: Obx(() => Wrap(
                children: List.generate(
                  GlobalData.communityPetKinds.length + 1,
                  (index) {
                    String text = '';
                    if (index != GlobalData.communityPetKinds.length) text = GlobalData.communityPetKinds[index];

                    if (text == '고양이 전체' || text == '강아지 전체') return SizedBox();

                    if (index == GlobalData.communityPetKinds.length)
                      return wrapItem(
                        index: index,
                        isAddButton: true,
                        onTap: () => Get.to(() => PetKindSelectionPage())!.then((value) {
                          if (value != null) {
                            FilterController.to.addPetKind(value); // 품종 추가
                            controller.selectedPetKindList.add(value); // 선택된 펫에 추가
                            controller.okCheck(widget.isWrite);
                          }
                        }),
                      );

                    return Obx(() => wrapItem(
                          text: text,
                          isChecked: controller.selectedPetKindList.contains(text),
                          index: index,
                          haveCancel: true,
                          onTap: () {
                            controller.togglePetKind(value: GlobalData.communityPetKinds[index], limit: 3);
                            controller.okCheck(widget.isWrite);
                          },
                        ));
                  },
                ),
              )),
        ),
      ],
    );
  }

  Widget wrapItem({String text = '', required int index, bool isChecked = false, bool isAddButton = false, required GestureTapCallback onTap, bool haveCancel = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8 * sizeUnit, bottom: 8 * sizeUnit),
        padding: EdgeInsets.all(1 * sizeUnit),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * sizeUnit),
          gradient: isChecked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color.fromRGBO(255, 255, 255, 0)],
                )
              : null,
        ),
        child: Container(
          height: 32 * sizeUnit,
          padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: isAddButton ? 6 * sizeUnit : 9 * sizeUnit),
          decoration: BoxDecoration(
            color: isChecked ? vfColorPink : Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.circular(16 * sizeUnit),
            boxShadow: vfBasicBoxShadow,
          ),
          child: isAddButton
              ? SvgPicture.asset(
                  svgFilterAddIcon,
                  width: 20 * sizeUnit,
                  height: 20 * sizeUnit,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(text, style: VfTextStyle.body2().copyWith(color: isChecked ? Colors.white : vfColorBlack)),
                    if (haveCancel && isChecked && !GlobalData.myPetKinds.contains(text)) ...[
                      SizedBox(width: 10 * sizeUnit),
                      GestureDetector(
                        onTap: () {
                          FilterController.to.removePetKind(index, callback: () => controller.selectedPetKindList.remove(text));
                          controller.selectedPetKindList.remove(text);
                          controller.okCheck(widget.isWrite);
                        },
                        child: Container(
                          width: 14 * sizeUnit,
                          height: 14 * sizeUnit,
                          padding: EdgeInsets.all(3 * sizeUnit),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            svgWhiteCancelIcon,
                            color: vfColorPink,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildTitleAndInfo({required String title, String? info}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
      child: Row(
        children: [
          Text(title, style: VfTextStyle.subTitle4()),
          if (info != null) ...[
            SizedBox(width: 4 * sizeUnit),
            Text(info, style: VfTextStyle.bWriteDate()),
          ],
        ],
      ),
    );
  }
}
