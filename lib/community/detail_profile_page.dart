import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/community_post_card.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:myvef_app/Config/Painter/circle_paint_widget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/detail_profile_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/community/image_detail_page.dart';
import 'package:myvef_app/community/model/community.dart';

class DetailProfilePage extends StatelessWidget {
  DetailProfilePage({Key? key, required this.user, required this.petList}) : super(key: key);

  final UserData user;
  final List<Pet> petList;

  final DetailProfileController controller = Get.put(DetailProfileController());
  final CommunityController communityController = Get.find<CommunityController>();
  final String svgCheckIcon = 'assets/image/community/checkIcon.svg';

  @override
  Widget build(BuildContext context) {
    if(petList.isNotEmpty) controller.initPet(petList[0]); // 메인 펫 세팅

    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: vfAppBar(context, title: '프로필 상세 정보'),
        body: SingleChildScrollView(
          child: GetBuilder<DetailProfileController>(
            builder: (_) => Column(
              children: [
                buildUserAndPetInfo(), // 유저, 펫 정보
                buildCommunityListView(), // 커뮤니티 리스트 뷰
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 커뮤니티 리스트 뷰
  ListView buildCommunityListView() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: GlobalData.profileCommunityList.length,
      itemBuilder: (context, index) {
        Community community = GlobalData.profileCommunityList[index];

        if (community.isShow == 0) return SizedBox.shrink();
        return CommunityPostCard(
          community: community,
          onTap: () {},
          callSetState: () => controller.stateUpdate(),
        );
      },
    );
  }

  // 유저, 펫 정보
  Column buildUserAndPetInfo() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            buildPetBackImages(), // 펫 백그라운드 이미지
            buildUserProfileImg(), // 유저 프로필 이미지
            buildImgIndexDots(), // 이미지 인덱스 dots
            if(controller.selectedPet.id != nullInt) buildPetInfo(), // 펫 정보 버튼 (품종, 생년월일)
          ],
        ),
        SizedBox(height: 64 * sizeUnit),
        Text(user.nickName, style: VfTextStyle.headline4()),
        SizedBox(height: 8 * sizeUnit),
        Text(user.location, style: VfTextStyle.body1()),
        SizedBox(height: 14 * sizeUnit),
        buildPetProfileList(), // 펫 프로필 리스트
        SizedBox(height: 52 * sizeUnit),
        Row(
          children: [
            SizedBox(width: 16 * sizeUnit),
            Text('게시글 보기', style: VfTextStyle.body1()),
          ],
        ),
        SizedBox(height: 14 * sizeUnit),
      ],
    );
  }

  // 펫 백그라운드 이미지 인덱스 dots
  Positioned buildImgIndexDots() {
    return Positioned(
      bottom: 14 * sizeUnit,
      right: 16 * sizeUnit,
      child: Row(
        children: List.generate(
          controller.selectedPet.petPhotos.length,
          (index) => Obx(
            () => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 4 * sizeUnit),
              width: controller.currentImgIndex.value == index ? 12 * sizeUnit : 4 * sizeUnit,
              height: 4 * sizeUnit,
              decoration: BoxDecoration(
                color: controller.currentImgIndex.value == index ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4 * sizeUnit),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 펫 프로필 리스트
  SingleChildScrollView buildPetProfileList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(petList.length, (index) {
          return Row(
            children: [
              SizedBox(width: 22 * sizeUnit),
              buildPetProfileImg(petList[index]),
              if (index == petList.length - 1) SizedBox(width: 22 * sizeUnit),
            ],
          );
        }),
      ),
    );
  }

  // 펫 프로필 이미지
  Widget buildPetProfileImg(Pet pet) {
    return GestureDetector(
      onTap: () => controller.togglePet(pet, petList),
      child: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: 52 * sizeUnit,
                    height: 52 * sizeUnit,
                    padding: EdgeInsets.all(2 * sizeUnit),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [vfColorViolet60, vfColorPink60]),
                    ),
                    child: pet.petPhotos.isEmpty
                        ? vfGradationIconWidget(iconPath: svgFootIcon, isBorder: false, size: 48)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24 * sizeUnit),
                            child: ExtendedImage.network(
                              pet.petPhotos[0].imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ],
              ),
              controller.selectedPetList.contains(pet)
                  ? Container(
                      width: 52 * sizeUnit,
                      height: 52 * sizeUnit,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [vfColorViolet60, vfColorPink60]),
                      ),
                      child: SvgPicture.asset(
                        svgCheckIcon,
                        width: 20 * sizeUnit,
                        height: 14 * sizeUnit,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Text(
            pet.name,
            style: VfTextStyle.body2(),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  // 유저 이미지
  Positioned buildUserProfileImg() {
    return Positioned(
      bottom: -48 * sizeUnit,
      left: 0,
      right: 0,
      child: Container(
        width: 112 * sizeUnit,
        height: 112 * sizeUnit,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 96 * sizeUnit,
          height: 96 * sizeUnit,
          child: user.profileURL.isEmpty
              ? vfGradationIconWidget(iconPath: svgVfUserDefaultImg, size: 96)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(48 * sizeUnit),
                  child: GetExtendedImage(
                    url: user.profileURL,
                    boxFit: BoxFit.cover,
                    showDescription: false,
                    errorWidget: vfBetiBodyBadStateWidget()
                  ),
                ),
        ),
      ),
    );
  }

  // 품종, 생년월일
  Positioned buildPetInfo() {
    return Positioned(
      left: 16 * sizeUnit,
      bottom: 14 * sizeUnit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPetInfoBtn(controller.selectedPet.kind),
          SizedBox(height: 6 * sizeUnit),
          buildPetInfoBtn(controller.selectedPet.birthday),
        ],
      ),
    );
  }

  // 펫 정보 버튼
  Container buildPetInfoBtn(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit, vertical: 6 * sizeUnit),
      height: 26 * sizeUnit,
      decoration: BoxDecoration(
        color: vfColorPink,
        borderRadius: BorderRadius.circular(12 * sizeUnit),
      ),
      child: Text(text, style: VfTextStyle.body2().copyWith(color: Colors.white)),
    );
  }

  // 백그라운드 펫 이미지
  Container buildPetBackImages() {
    return Container(
      width: double.infinity,
      height: 240 * sizeUnit,
      child: controller.selectedPet.petPhotos.isEmpty
          ? SizedBox(
              width: 140 * sizeUnit,
              child: Center(
                child: CirclePaintWidget(
                  color: vfColorPink,
                  diameter: 140 * sizeUnit,
                  child: Center(
                      child: vfPramBodyGoodStateWidget(),
                  ),
                ),
              ),
            )
          : PageView.builder(
              itemCount: controller.selectedPet.petPhotos.length,
              onPageChanged: (value) => controller.currentImgIndex(value),
              itemBuilder: (context, index) {
                String imageUrl = controller.selectedPet.petPhotos[index].imageUrl;

                return GestureDetector(
                  onTap: () {
                    List<String> _imgUrlList = [];

                    controller.selectedPet.petPhotos.forEach((element) {
                      _imgUrlList.add(element.imageUrl);
                    });

                    Get.to(() => ImageDetailPage(imgUrlList: _imgUrlList));
                  },
                  child: ExtendedImage.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
