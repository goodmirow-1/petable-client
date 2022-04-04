import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/community_report_page.dart';
import 'package:myvef_app/community/community_write_or_modify_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/community/detail_profile_page.dart';
import 'package:myvef_app/community/image_detail_page.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class CommunityPostCard extends StatelessWidget {
  CommunityPostCard({Key? key, required this.community, required this.onTap, required this.callSetState, this.limitContents = true}) : super(key: key);

  final Community community;
  final GestureTapCallback onTap;
  final GestureTapCallback callSetState;
  final bool limitContents; // 댓글 페이지에서는 다 보여야 하기 때문에 false

  final CommunityController controller = Get.find<CommunityController>();
  final FilterController filterController = Get.find<FilterController>();
  final PageController pageController = PageController();
  final String svgFillHeartIcon = 'assets/image/community/fillHeartIcon.svg'; // 애니메이션 하트 아이콘
  final double animationLikeSize = 85 * sizeUnit; // 좋아요 아이콘 사이즈
  final TextStyle contentsTextStyle = VfTextStyle.body2().copyWith(color: vfColorDarkGray, height: 18 / 12); // 콘텐츠 텍스트 스타일

  RxBool isLike = false.obs; // 좋아요 여부
  RxBool isReply = false.obs; // 댓글 여부
  RxBool likeAnimation = false.obs; // 좋아요 애니메이션
  RxBool isOverMaxLine = false.obs; // 콘텐츠 맥스라인 초과 여부

  @override
  Widget build(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: community.contents, style: contentsTextStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: Get.width - (32 * sizeUnit)); // 양 옆 패딩 계산

    isOverMaxLine(tp.didExceedMaxLines); // maxLine 넘었는지 여부 체크
    isLike(controller.likeCheck(community)); // 좋아요 체크
    isReply(controller.replyCheck(community)); // 댓글 체크

    return Container(
      color: Colors.white,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                buildProfileAndCategory(), // 프로필 정보, 카테고리, 옵션 버튼
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () {
                    // 필터가 내려와 있지 않을 때 더블탭 좋아요
                    if (!FilterController.to.activeFilter.value) controller.likeFunc(community, isLike, likeAnimation: likeAnimation);
                  },
                  child: Column(
                    children: [
                      buildContents(), // 제목, 내용
                      buildImg(), // 이미지
                    ],
                  ),
                ),
                buildLikeAndReply(), // 좋아요, 댓글
              ],
            ),
            buildPostOptions(), // 공유하기, 수정하기 등 옵션
            buildLikeAnimationWidget(), // 좋아요 애니메이션 위젯
          ],
        ),
      ),
    );
  }

  // 좋아요 애니메이션 위젯
  Obx buildLikeAnimationWidget() {
    return Obx(() => AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          transform: (Matrix4.identity()
            ..scale(likeAnimation.value ? 1.0 : 0.5, likeAnimation.value ? 1.0 : 0.5)
            ..translate(likeAnimation.value ? 0.0 : animationLikeSize / 2, likeAnimation.value ? 0.0 : animationLikeSize / 2)),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: likeAnimation.value ? 1 : 0,
            child: SvgPicture.asset(
              svgFillHeartIcon,
              width: animationLikeSize,
              height: animationLikeSize,
            ),
          ),
        ));
  }

  Obx buildPostOptions() {
    return Obx(
      () => controller.showPostOptions.value && controller.selectedPostID.value == community.id
          ? Positioned(
              top: 48 * sizeUnit,
              right: 16 * sizeUnit,
              child: Column(
                children: [
                  buildOptionButton(
                    text: '공유하기',
                    onTap: () async {
                      vfLoadingDialog(); // 로딩 시작

                      FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
                      final DynamicLinkParameters parameters = DynamicLinkParameters(
                        // The Dynamic Link URI domain. You can view created URIs on your Firebase console
                        uriPrefix: 'https://myvefapp.page.link',
                        // The deep Link passed to your application which you can use to affect change
                        link: Uri.parse('https://myvefapp.page.link/community?id=${community.id}'),
                        // Android application details needed for opening correct app on device/Play Store
                        androidParameters: const AndroidParameters(
                          packageName: 'kr.co.myvef.myvef_app',
                          minimumVersion: 1,
                        ),
                        // iOS application details needed for opening correct app on device/App Store
                        iosParameters: const IOSParameters(
                          bundleId: 'com.myvef.bowlsApp',
                          minimumVersion: '2',
                        ),
                      );

                      final ShortDynamicLink shortDynamicLink = await dynamicLinks.buildShortLink(parameters);
                      final Uri uri = shortDynamicLink.shortUrl;
                      Get.back(); //로딩 끄기
                      Share.share('마이베프 - 반려동물 필수 앱\n커뮤니티 글보기 - ${community.title}\n$uri');
                    },
                  ),
                  if (community.userId == GlobalData.loggedInUser.value.userID) ...[
                    buildOptionButton(
                      text: '수정하기',
                      onTap: () {
                        controller.offActive(); // 각종 액티브 끄기 (옵션, 필터, 플로팅 버튼 등)
                        Get.to(() => CommunityWriteOrModifyPage(isWrite: false, community: community))!.then((value) {
                          if (pageController.hasClients) pageController.jumpTo(0); // 사진 페이지 첫 번째로
                          callSetState();
                        });
                      },
                    ),
                    buildOptionButton(
                      text: '삭제하기',
                      textColor: vfColorRed,
                      onTap: () {
                        controller.offOptions(); // 옵션끄기

                        showVfDialog(
                          title: '삭제 하시겠어요?',
                          colorType: vfGradationColorType.Violet,
                          description: '삭제된 글은 복구되지 않습니다.',
                          isCancelButton: true,
                          okFunc: () {
                            Get.back(); // 다이어로그 끄기
                            controller.communityDeleteFunc(community.id).then((value) => callSetState());
                          },
                          cancelText: '취소',
                          cancelFunc: () => Get.back(),
                        );
                      },
                    ),
                  ] else ...[
                    buildOptionButton(
                      text: '신고하기',
                      textColor: vfColorRed,
                      onTap: () {
                        controller.offOptions(); // 옵션끄기

                        Get.to(
                          () => CommunityReportPage(
                            postType: COMMUNITY_POST_TYPE_POST,
                            postID: community.id,
                            community: community,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            )
          : SizedBox(),
    );
  }

  Widget buildOptionButton({required String text, required GestureTapCallback onTap, Color textColor = vfColorBlack}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(8 * sizeUnit),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16 * sizeUnit), boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Color.fromRGBO(0, 0, 0, 0.1),
              )
            ]),
            child: Text(text, style: VfTextStyle.body2().copyWith(color: textColor)),
          ),
        ),
        SizedBox(height: 6 * sizeUnit),
      ],
    );
  }

  Padding buildLikeAndReply() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
      child: Row(
        children: [
          Obx(
            () => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // 필터 내려와 있지 않을 때 좋아요
                if (!filterController.activeFilter.value) controller.likeFunc(community, isLike);
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    svgHeartIcon,
                    width: 20 * sizeUnit,
                    height: 20 * sizeUnit,
                    color: isLike.value ? vfColorPink : vfColorDarkGray,
                  ),
                  SizedBox(width: 4 * sizeUnit),
                  Text(
                    community.communityPostLikes.length > 99 ? '99+' : community.communityPostLikes.length.toString(),
                    style: VfTextStyle.bWriteDate().copyWith(color: isLike.value ? vfColorPink : vfColorDarkGray),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12 * sizeUnit),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => goToReplyPage(),
            child: Row(
              children: [
                SvgPicture.asset(
                  svgReplyIcon,
                  width: 20 * sizeUnit,
                  height: 20 * sizeUnit,
                  color: isReply.value ? vfColorPink : vfColorDarkGray,
                ),
                SizedBox(width: 4 * sizeUnit),
                Text(
                  community.communityPostReplies.length > 99 ? '99+' : community.communityPostReplies.length.toString(),
                  style: VfTextStyle.bWriteDate().copyWith(color: isReply.value ? vfColorPink : vfColorDarkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImg() {
    RxInt imgIndex = 0.obs; // 이미지 인덱스

    return community.imgUrlList.isNotEmpty
        ? Column(
            children: [
              SizedBox(height: 20 * sizeUnit),
              GestureDetector(
                onTap: filterController.activeFilter.value
                    ? null
                    : () {
                        Get.to(() => ImageDetailPage(imgUrlList: community.imgUrlList));
                      },
                child: SizedBox(
                  width: double.infinity,
                  height: 280 * sizeUnit,
                  child: Stack(
                    children: [
                      Obx(() => PageView.builder(
                          controller: pageController,
                          physics: filterController.activeFilter.value ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                          onPageChanged: (index) => imgIndex(index),
                          itemCount: community.imgUrlList.length,
                          itemBuilder: (context, index) {
                            // 새로고침 했을 때 사진 첫번째로
                            if (controller.refreshInt.value != controller.preRefreshInt) {
                              controller.preRefreshInt++;

                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                if (pageController.hasClients) {
                                  pageController.jumpToPage(0);
                                }
                              });
                            }

                            return GetExtendedImage(
                              url: community.imgUrlList[index],
                              boxFit: BoxFit.cover,
                              scale: 0.7,
                            );
                          })),
                      Positioned(
                        bottom: 4 * sizeUnit,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            community.imgUrlList.length,
                            (index) => Obx(
                              () => AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.only(right: 4 * sizeUnit),
                                width: imgIndex.value == index ? 12 * sizeUnit : 4 * sizeUnit,
                                height: 4 * sizeUnit,
                                decoration: BoxDecoration(
                                  color: imgIndex.value == index ? Colors.white : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4 * sizeUnit),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : SizedBox(height: 12 * sizeUnit);
  }

  Widget buildContents() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: filterController.activeFilter.value || Get.currentRoute == '/CommunityReplyPage' ? null : () => goToReplyPage(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24 * sizeUnit),
            Text(community.title, style: VfTextStyle.body1()),
            SizedBox(height: 8 * sizeUnit),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (limitContents) ...[
                  Expanded(
                    child: Obx(() => Text(
                          community.contents,
                          style: contentsTextStyle,
                          maxLines: controller.moreContentsIDList.contains(community.id) ? 100 : 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  Obx(() => limitContents && isOverMaxLine.value && !controller.moreContentsIDList.contains(community.id)
                      ? GestureDetector(
                          onTap: () => controller.moreContentsIDList.add(community.id),
                          child: Column(
                            children: [
                              Text('더 보기', style: VfTextStyle.body3()),
                              SizedBox(height: 3 * sizeUnit),
                            ],
                          ),
                        )
                      : SizedBox()),
                ] else ...[
                  Expanded(
                    child: Text(
                      community.contents,
                      style: contentsTextStyle,
                      maxLines: 100,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildProfileAndCategory() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [vfColorPink20, vfColorPink.withOpacity(0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16 * sizeUnit),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: Get.currentRoute == '/DetailProfilePage' || filterController.activeFilter.value
                      ? null
                      : () async {
                          UserData user = UserData(); // 유저 정보 담을 변수
                          List<Pet> petList = []; // 펫 정보 담을 변수
                          vfLoadingDialog(); // 로딩

                          await controller.getDetailProfileData(userID: community.userId, user: user, petList: petList);

                          Get.back(); // 로딩 끝
                          Get.to(() => DetailProfilePage(user: user, petList: petList))!.then((value) => callSetState());
                        },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: community.profileURL.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16 * sizeUnit),
                                child: GetExtendedImage(
                                  url: community.profileURL,
                                  boxFit: BoxFit.cover,
                                  showDescription: false,
                                  indicatorRadius: 8 * sizeUnit,
                                  indicatorStrokeWidth: 2.6 * sizeUnit,
                                  errorWidget: vfBetiHeadBadStateWidget(scale: 0.4),
                                ),
                              )
                            : vfGradationIconWidget(iconPath: svgVfUserDefaultImg, size: 32),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(community.nickName, style: VfTextStyle.subTitle4()),
                            SizedBox(height: 4 * sizeUnit),
                            Row(
                              children: [
                                Text(abbreviateForLocation(community.location), style: VfTextStyle.subTitle5()),
                                SizedBox(width: 8 * sizeUnit),
                                GestureDetector(
                                  onTap: () {}, // 프로필 페이지 못넘어가게 막는 용
                                  child: Text(timeCheck(replaceDate(community.createdAt)), style: VfTextStyle.bWriteDate()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12 * sizeUnit),
                  onTap: () {
                    if (!filterController.activeFilter.value) controller.toggleOptions(community.id);
                  },
                  child: SvgPicture.asset(
                    svgVerticalThreeDot,
                    width: 24 * sizeUnit,
                    height: 24 * sizeUnit,
                    color: vfColorDarkGray,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * sizeUnit),
          Wrap(
            spacing: 4 * sizeUnit,
            runSpacing: 4 * sizeUnit,
            children: List.generate(
              community.kind.split(' | ').length + 1,
              (index) => Container(
                padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit, vertical: 1 * sizeUnit),
                height: 14 * sizeUnit,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.circular(10 * sizeUnit),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 2 * sizeUnit,
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                    ),
                  ],
                ),
                child: Text(index == 0 ? community.category : community.kind.split(' | ')[index - 1], style: VfTextStyle.body3()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> goToReplyPage() async {
    if (Get.currentRoute != '/CommunityReplyPage' && !filterController.activeFilter.value) {
      vfLoadingDialog(); // 로딩 시작
      bool isDeleted = await controller.setCommunityDetailData(community.id); // 커뮤니티 디테일 데이터 세팅

      // 삭제된 글이면
      if (isDeleted) {
        syncCommunityDelete(community.id); // 커뮤니티 리스트에서 삭제
        Get.back(); // 로딩 끄기

        Fluttertoast.showToast(
          msg: '삭제된 게시글입니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );

        callSetState(); // 스테이트 업데이트
        return;
      }

      bool isSubscribe = await controller.subscribeCheck(community.id); // 구독 체크
      controller.offActive(); // 액티브 끄기
      controller.detailCommunity = community;
      Get.back(); // 로딩 끄기
      Get.to(() => CommunityReplyPage(isSubscribe: isSubscribe))!.then((value) {
        if (pageController.hasClients) pageController.jumpTo(0); // 사진 페이지 첫 번째로
        if (controller.showPostOptions.value) controller.showPostOptions(false); // 옵션버튼 끄기
        callSetState();
      });
    }
  }
}
