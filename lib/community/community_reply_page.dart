import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/GlobalWidget/community_post_card.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/community/community_report_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/community_reply_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/community/detail_profile_page.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityReplyPage extends StatefulWidget {
  const CommunityReplyPage({Key? key, required this.isSubscribe}) : super(key: key);

  final bool isSubscribe;

  @override
  State<CommunityReplyPage> createState() => _CommunityReplyPageState();
}

class _CommunityReplyPageState extends State<CommunityReplyPage> {
  final CommunityReplyController controller = Get.put(CommunityReplyController());
  final CommunityController communityController = Get.find<CommunityController>();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final String svgBellIcon = 'assets/image/dash_board/bellIcon.svg';
  final String svgCancelBellIcon = 'assets/image/community/cancelBellIcon.svg';
  final String svgArrowUpIcon = 'assets/image/community/arrowUpIcon.svg';

  @override
  void initState() {
    super.initState();

    controller.isSubscribe(widget.isSubscribe); // 알람 세팅
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Violet,
      child: Scaffold(
        appBar: buildAppBar(context),
        body: GestureDetector(
          onTap: () => unFocus(context),
          child: Column(
            children: [
              Expanded(
                child: vfCustomRefreshIndicator(
                  onRefresh: () async {
                    // 사진 페이지 새로고침 용도
                    communityController.refreshInt(1);
                    communityController.preRefreshInt = 0;

                    bool isDeleted = await communityController.setCommunityDetailData(communityController.detailCommunity.id); // 커뮤니티 디테일 데이터 세팅

                    // 삭제된 글이면
                    if(isDeleted) {
                      syncCommunityDelete(communityController.detailCommunity.id); // 커뮤니티 리스트에서 삭제

                      Get.back(); // 댓글 페이지 나가기
                      Fluttertoast.showToast(
                        msg: '삭제된 게시글입니다.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
                        textColor: Colors.white,
                      );
                      return;
                    } else {
                      setState(() {});
                    }
                  },
                  child: ListView(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      CommunityPostCard(
                        community: communityController.detailCommunity,
                        onTap: () {
                          focusNode.unfocus();
                          communityController.offOptions();
                        },
                        callSetState: () {
                          setState(() {}); // 댓글 페이지 스테이트 돌리기
                          communityController.stateUpdate(); // 커뮤니티 페이지 스테이트 돌리기
                        },
                        limitContents: false,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                        color: vfColorGrey,
                        width: double.infinity,
                        height: 1 * sizeUnit,
                      ),
                      SizedBox(height: 16 * sizeUnit),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                        child: Column(
                          children: List.generate(communityController.detailCommunity.communityPostReplies.length, (index) {
                            CommunityPostReply reply = communityController.detailCommunity.communityPostReplies[index];

                            return buildReply(reply: reply, communityReplyReplies: reply.communityReplyReplies);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              buildTextFiled(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReply({required CommunityPostReply reply, required List<CommunityPostReplyReply> communityReplyReplies}) {
    return Column(
      children: [
        replyItem(
          reply: reply,
          declareFunc: () {
            controller.offOption(); // 옵션끄기

            Get.to(
                  () => CommunityReportPage(
                postType: COMMUNITY_POST_TYPE_REPLY,
                postID: reply.id,
                communityPostReply: reply,
              ),
            )!
                .then((value) => setState(() {}));
          },
          deleteFunc: () {
            controller.offOption(); // 옵션끄기

            showVfDialog(
              title: '삭제 하시겠어요?',
              colorType: vfGradationColorType.Violet,
              description: '삭제된 글은 복구되지 않습니다.',
              isCancelButton: true,
              okFunc: () {
                Get.back(); // 다이어로그 끄기

                controller
                    .deleteFunc(
                  communityID: communityController.detailCommunity.id,
                  id: reply.id,
                  postType: COMMUNITY_POST_TYPE_REPLY,
                )
                    .then((value) => setState(() {}));
              },
              cancelText: '취소',
              cancelFunc: () => Get.back(),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
          child: Row(
            children: [
              Container(
                color: vfColorDarkGray,
                width: 24 * sizeUnit,
                height: 1 * sizeUnit,
              ),
              SizedBox(width: 6 * sizeUnit),
              if (communityReplyReplies.isEmpty) ...[
                GestureDetector(
                  onTap: () {
                    if (!controller.replyListForShowReplyReply.contains(reply.id)) controller.replyListForShowReplyReply.add(reply.id); // 답글 펼쳐주기
                    controller.pressWriteReplyReply(focusNode: focusNode, reply: reply); // 답글 쓰기 눌렀을 때
                    setState(() {});
                  },
                  child: Text('답글쓰기', style: VfTextStyle.bWriteDate()),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () {
                    if (controller.replyListForShowReplyReply.contains(reply.id)) {
                      controller.replyListForShowReplyReply.remove(reply.id); // 답글 접기
                    } else {
                      controller.showReplyReplyEvent(reply.id); // 답글 보기
                      // 답글 펼치면 스크롤 내려주기
                      scrollController.animateTo(
                        scrollController.offset + (reply.communityReplyReplies.length * 74 * sizeUnit),
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Obx(() => Text(
                    controller.replyListForShowReplyReply.contains(reply.id) ? '답글접기' : '답글 ${communityReplyReplies.length}개',
                    style: VfTextStyle.bWriteDate(),
                  )),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16 * sizeUnit),
        Obx(() => controller.replyListForShowReplyReply.contains(reply.id) ? buildReplyReply(communityReplyReplies, reply) : SizedBox()) // 답글 빌드
      ],
    );
  }

  Padding buildReplyReply(List<CommunityPostReplyReply> communityReplyReplies, CommunityPostReply reply) {
    return Padding(
      padding: EdgeInsets.only(left: 28 * sizeUnit),
      child: Column(
        children: List.generate(communityReplyReplies.length, (index) {
          CommunityPostReplyReply replyReply = communityReplyReplies[index];

          return Column(
            children: [
              replyItem(
                replyReply: replyReply,
                isReply: false,
                declareFunc: () {
                  controller.offOption(); // 옵션끄기

                  Get.to(
                        () => CommunityReportPage(
                      postType: COMMUNITY_POST_TYPE_REPLY_REPLY,
                      postID: replyReply.id,
                      communityPostReplyReply: replyReply,
                    ),
                  )!
                      .then((value) => setState(() {}));
                },
                deleteFunc: () {
                  controller.offOption(); // 옵션끄기

                  showVfDialog(
                    title: '삭제 하시겠어요?',
                    colorType: vfGradationColorType.Violet,
                    description: '삭제된 글은 복구되지 않습니다.',
                    isCancelButton: true,
                    okFunc: () {
                      Get.back(); // 다이어로그 끄기

                      controller
                          .deleteFunc(
                        communityID: communityController.detailCommunity.id,
                        id: replyReply.id,
                        postType: COMMUNITY_POST_TYPE_REPLY_REPLY,
                        communityPostReplyReply: replyReply,
                      )
                          .then((value) => setState(() {}));
                    },
                    cancelText: '취소',
                    cancelFunc: () => Get.back(),
                  );
                },
              ),
              if (index == communityReplyReplies.length - 1) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
                  child: Row(
                    children: [
                      Container(
                        color: vfColorDarkGray,
                        width: 24 * sizeUnit,
                        height: 1 * sizeUnit,
                      ),
                      SizedBox(width: 6 * sizeUnit),
                      GestureDetector(
                        onTap: () {
                          controller.pressWriteReplyReply(focusNode: focusNode, reply: reply); // 답글 쓰기 눌렀을 때
                          setState(() {});
                        },
                        child: Text('답글쓰기', style: VfTextStyle.bWriteDate()),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * sizeUnit),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget replyItem({
    CommunityPostReply? reply,
    CommunityPostReplyReply? replyReply,
    bool isReply = true,
    required GestureTapCallback declareFunc,
    required GestureTapCallback deleteFunc,
  }) {
    int replyID = isReply ? reply!.id : replyReply!.id; // id
    int userID = isReply ? reply!.userId : replyReply!.userId; // userID
    String contents = isReply ? reply!.contents : replyReply!.contents; // contents
    String updatedAt = isReply ? reply!.updatedAt : replyReply!.updatedAt; // updateAt
    int isShow = isReply ? reply!.isShow : replyReply!.isShow; // isShow
    bool isBlind = isReply ? reply!.isBlind : replyReply!.isBlind; // isBlind
    UserData replyUser = GlobalData.simpleUserList.singleWhere((element) => element.userID == userID); // 유저 정보

    Future<void> goToDetailProfilePage() async {
      UserData user = UserData(); // 유저 정보 담을 변수
      List<Pet> petList = []; // 펫 정보 담을 변수
      vfLoadingDialog(); // 로딩

      await communityController.getDetailProfileData(userID: userID, user: user, petList: petList);

      Get.back(); // 로딩 끝
      Get.to(() => DetailProfilePage(user: user, petList: petList))!.then((value) => setState(() {}));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        focusNode.unfocus();
        controller.offOption();
      },
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => goToDetailProfilePage(),
                    child: replyUser.profileURL.isNotEmpty ? SizedBox(
                        width: 32 * sizeUnit,
                        height: 32 * sizeUnit,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16 * sizeUnit),
                          child: GetExtendedImage(
                              url: replyUser.profileURL,
                              boxFit: BoxFit.cover,
                              showDescription: false,
                              indicatorRadius: 8 * sizeUnit,
                              indicatorStrokeWidth: 2.6 * sizeUnit,
                              errorWidget: vfBetiBodyBadStateWidget()
                          ),
                        )) : vfGradationIconWidget(iconPath: svgVfUserDefaultImg, size: 32),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => goToDetailProfilePage(),
                          child: Text(replyUser.nickName, style: VfTextStyle.subTitle4()),
                        ),
                        SizedBox(height: 6 * sizeUnit),
                        if (isShow == 0) ...[
                          RichText(
                            text: TextSpan(
                              style: VfTextStyle.body2(),
                              children: [
                                TextSpan(text: '삭제', style: TextStyle(color: vfColorRed)),
                                TextSpan(text: '된 글 입니다.'),
                              ],
                            ),
                          ),
                        ] else if (isBlind) ...[
                          RichText(
                            text: TextSpan(
                              style: VfTextStyle.body2(),
                              children: [
                                TextSpan(text: '신고 누적으로 블라인드', style: TextStyle(color: vfColorRed)),
                                TextSpan(text: '된 글 입니다.'),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(contents, style: VfTextStyle.body2()),
                        ],
                        SizedBox(height: 6 * sizeUnit),
                        RichText(
                          text: TextSpan(
                            style: VfTextStyle.bWriteDate(),
                            children: [
                              TextSpan(text: replyUser.location),
                              TextSpan(text: ' | '),
                              TextSpan(text: timeCheck(replaceDate(updatedAt))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12 * sizeUnit),
                      onTap: () {
                        if (isShow == 1 && !isBlind) controller.showOptionToggle(replyID: replyID, isReply: isReply);
                      },
                      child: SvgPicture.asset(
                        svgHorizontalThreeDot,
                        width: 24 * sizeUnit,
                        height: 24 * sizeUnit,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * sizeUnit),
            ],
          ),
          Positioned(
            top: 24 * sizeUnit,
            right: 0 * sizeUnit,
            child: Obx(() => isReply
                ? controller.showOptionReply.value == replyID
                ? changeOptionButton(userID: userID, declareFunc: declareFunc, deleteFunc: deleteFunc)
                : SizedBox()
                : controller.showOptionReplyReply.value == replyID
                ? changeOptionButton(userID: userID, declareFunc: declareFunc, deleteFunc: deleteFunc)
                : SizedBox()),
          ),
        ],
      ),
    );
  }

  Widget changeOptionButton({required int userID, required GestureTapCallback declareFunc, required GestureTapCallback deleteFunc}) {
    Widget optionButton;

    if (userID == GlobalData.loggedInUser.value.userID) {
      optionButton = buildOptionButton(
        text: '삭제하기',
        textColor: vfColorRed,
        onTap: deleteFunc,
      );
    } else {
      optionButton = buildOptionButton(
        text: '신고하기',
        onTap: declareFunc,
      );
    }

    return optionButton;
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

  Container buildTextFiled() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (focusNode.hasFocus && controller.communityReplyWriteMode == COMMUNITY_REPLY_WRITE_MODE.replyReply) ...[
            RichText(
              text: TextSpan(
                style: VfTextStyle.body3(),
                children: [
                  TextSpan(text: controller.selectedReplyUserNickName, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '님의 글에 답글 다는 중...'),
                ],
              ),
            )
          ],
          SizedBox(height: 8 * sizeUnit),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: vfColorGrey),
              borderRadius: BorderRadius.circular(18 * sizeUnit),
            ),
            width: double.infinity,
            height: 34 * sizeUnit,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: () {
                      if (!focusNode.hasFocus) {
                        controller.communityReplyWriteMode = COMMUNITY_REPLY_WRITE_MODE.reply;
                        debugPrint('댓글 쓰기 모드로 변경');
                      }
                    },
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: VfTextStyle.body2(),
                    decoration: InputDecoration(
                      hintText: '댓글 내용을 입력해주세요.',
                      hintStyle: VfTextStyle.body2().copyWith(color: vfColorGrey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) => controller.contents(value),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (controller.contents.value.isNotEmpty) {
                      switch (controller.communityReplyWriteMode) {
                        case COMMUNITY_REPLY_WRITE_MODE.reply:
                          await controller.writeReply(communityController.detailCommunity.id);

                          // 스크롤 아래로
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);
                          });
                          break;
                        case COMMUNITY_REPLY_WRITE_MODE.replyReply:
                          await controller.writeReplyReply();

                          // 스크롤 아래로
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.pixels + 86 * sizeUnit);
                          });
                          break;
                      }

                      textEditingController.text = '';
                      controller.contents('');
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                      } else {
                        setState(() {});
                      }
                    }
                  },
                  child: Obx(() => Container(
                    width: 22 * sizeUnit,
                    height: 22 * sizeUnit,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.contents.value.isNotEmpty ? vfColorPink : vfColorGrey,
                    ),
                    child: SvgPicture.asset(svgArrowUpIcon),
                  )),
                ),
                SizedBox(width: 8 * sizeUnit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return vfAppBar(
      context,
      title: '댓글',
      actions: [
        GestureDetector(
          onTap: () => controller.bellToggle(communityController.detailCommunity.id),
          child: Obx(
                () => SvgPicture.asset(
              controller.isSubscribe.value ? svgBellIcon : svgCancelBellIcon,
              width: 24 * sizeUnit,
              height: 24 * sizeUnit,
            ),
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
      ],
    );
  }
}
