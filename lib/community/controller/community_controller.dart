import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityController extends GetxController {
  static get to => Get.find<CommunityController>();

  final int likeProhibitionCount = 20; // 좋아요 연속 탭 금지 갯수

  final PageController pageController = PageController(); // 페이지 컨트롤러
  ScrollController currentScrollController = ScrollController(); // 현재 스크롤 컨트롤러 (전체, 인기)

  RxInt pageIndex = 0.obs; // 전체, 인기 bar index
  RxInt selectedPostID = 0.obs; // 선택된 커뮤니티 글 ID
  RxInt refreshInt = 0.obs; // 새로고침 확인용
  int preRefreshInt = 0; // 새로고침 확인용

  RxBool onPage = false.obs;
  RxBool showPostOptions = false.obs; // 커뮤니티 글 옵션 보여주는지 여부
  RxBool activeFloating = false.obs; // 플로팅 버튼 활성화 여부
  RxBool activeNewPost = false.obs; //새 게시글 버튼 활성화 여부

  bool isCanTapLike = true; // 좋아요 반복 호출 금지
  bool likeProhibitionState = false; // 좋아요 금지 상태

  RxList<int> moreContentsIDList = <int>[].obs; // 더 보기 한 커뮤니티 id 리스트

  Community detailCommunity = Community(); // 댓글 페이지에서 보여줄 커뮤니티

  @override
  void onClose() {
    super.onClose();

    pageController.dispose();
  }

  void stateUpdate() {
    update();
  }

  // 새로고침
  Future<void> onRefresh() async {
    // 사진 페이지 새로고침 용도
    refreshInt(2);
    preRefreshInt = 0;

    if (FilterController.to.isFiltered.value) {
      await FilterController.to.getFilterData(pageIndex.value, isRefresh: true);
    } else {
      if(pageIndex.value == COMMUNITY_TYPE_NORMAL){
        await getCommunityData(isRefresh: true);
      } else {
        await getPopularCommunityData(isRefresh: true);
      }
    }

    scrollJumpToTop(); // 스크롤 상단으로
    stateUpdate();
  }

  // 스크롤 상단으로
  void scrollJumpToTop() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (currentScrollController.hasClients && currentScrollController.position.pixels != 0) {
        currentScrollController.jumpTo(0.1);
      }
    });
  }

  // 페이지 이동 시 각종 액티브들 끄기 함수
  void offActive() {
    if (activeFloating.value) activeFloating(false); // 플로팅 버튼 끄기
    if (showPostOptions.value) showPostOptions(false); // 옵션 버튼 끄기
    FilterController.to.disposeFilter(); // 필터 끄기, 적용된 필터로 변경
  }

  // 플로팅 버튼 토글
  void toggleFloating() {
    activeFloating(!activeFloating.value);
  }

  // 커뮤니티 글 옵션 토글
  void toggleOptions(int id) {
    if (selectedPostID.value == id)
      showPostOptions(!showPostOptions.value);
    else
      showPostOptions(true);

    selectedPostID(id);
  }

  // 커뮤니티 글 옵션 끄기
  void offOptions() {
    if (showPostOptions.value) showPostOptions(false);
  }

  // 좋아요 여부 체크
  bool likeCheck(Community community) {
    bool isLike = false;

    for (int i = 0; i < community.communityPostLikes.length; i++) {
      if (community.communityPostLikes[i].userId == GlobalData.loggedInUser.value.userID) {
        isLike = true;
        break;
      }
    }

    return isLike;
  }

  // 댓글 썼는지 체크
  bool replyCheck(Community community) {
    bool isReply = false;

    for (int i = 0; i < community.communityPostReplies.length; i++) {
      if (community.communityPostReplies[i].userId == GlobalData.loggedInUser.value.userID) {
        isReply = true;
        break;
      }
    }

    return isReply;
  }

  // 좋아요 금지 다이어로그
  void showLikeProhibitionDialog() {
    showVfDialog(title: '좋아요 금지!', colorType: vfGradationColorType.Pink, description: '정상적인 서비스 운영을 위해\n3분 후 시도해주세요.');
  }

  // 좋아요 함수
  Future<void> likeFunc(Community community, RxBool isLike, {RxBool? likeAnimation}) async {
    // 좋아요 금지 상태 확인
    if (likeProhibitionState)
      return showLikeProhibitionDialog();
    else {
      // 좋아요 누른 횟수가 기준치 넘으면
      if (community.likePressingCount >= likeProhibitionCount) {
        likeProhibitionState = true; // 좋아요 금지 시작

        Timer(Duration(minutes: 3), () {
          community.likePressingCount = 0; // 좋아요 카운트 초기화
          likeProhibitionState = false; // 좋아요 금지 풀기
        });

        return showLikeProhibitionDialog();
      }
    }

    if (isCanTapLike) {
      // 더블 탭으로 좋아요 취소 못하게
      if (likeAnimation != null && isLike.value == true) {
        likeAnimation(true);
        Timer(Duration(milliseconds: 1000), () {
          likeAnimation(false);
        });
        return;
      }

      isCanTapLike = false;
      community.likePressingCount++; // 좋아요 누른 갯수 추가

      // 첫 좋아요 기준 3분 뒤 좋아요 카운트 초기화
      if (community.likePressingCount == 1) {
        Timer(Duration(minutes: 3), () {
          community.likePressingCount = 0; // 좋아요 카운트 초기화
        });
      }

      var res = await ApiProvider().post(
          '/CommunityPost/InsertLike',
          jsonEncode({
            'userID': GlobalData.loggedInUser.value.userID,
            'postID': community.id,
          }));

      if (res != null) {
        if (res['created']) {
          // 좋아요
          CommunityPostLike tmpLike = CommunityPostLike.fromJson(res['item']);
          syncLikeOnInsert(community.id, tmpLike);
        } else {
          // 좋아요 취소
          syncLikeOnRemove(community.id);
        }

        isLike(res['created']); // 좋아요 bool 처리

        // 더블 탭했을 때 애니메이션
        if (likeAnimation != null) {
          likeAnimation(true);
          Timer(Duration(milliseconds: 1000), () {
            likeAnimation(false);
          });
        }
      }

      // 연속 호출 방지
      Timer(Duration(milliseconds: 500), () {
        isCanTapLike = true;
      });
    }
  }

  // 커뮤니티 id로 디테일 데이터 세팅
  Future<void> setCommunityDetailDataByID(int communityID) async {
    await GlobalData().getFutureCommunity(communityID); // 커뮤니티 정보 세팅
    await setCommunityDetailData(communityID); // 커뮤니티 댓글 정보 세팅

    detailCommunity = GlobalData.communityList.singleWhere((element) => element.id == communityID); // 디테일 커뮤니티에 데이터 세팅

    bool isSubscribe = await subscribeCheck(communityID); // 구독 체크|
    Get.to(() => CommunityReplyPage(isSubscribe: isSubscribe)); // 댓글 페이지로 이동
  }

  // 디테일 정보 세팅 (댓글, 답글, 유저 정보)
  Future<bool> setCommunityDetailData(int communityID) async {
    bool isDeleted = true; // 삭제 된 글인지

    var res = await ApiProvider().post(
        '/CommunityPost/Select/Detail',
        jsonEncode({
          'id': communityID,
        }));

    if (res != null) {
      isDeleted = false;
      List<CommunityPostReply> replyList = []; // 댓글 담을 리스트

      for (int i = 0; i < res.length; i++) {
        CommunityPostReply reply = CommunityPostReply.fromJson(res[i]);

        // 댓글 유저 정보 가져오기
        await GlobalData().getFutureSimpleUser(reply.userId);

        // 답글 유저 정보 가져오기
        for (int j = 0; j < reply.communityReplyReplies.length; j++) {
          await GlobalData().getFutureSimpleUser(reply.communityReplyReplies[j].userId);
        }

        replyList.add(reply);
      }

      syncCommunityReplyData(communityID, replyList); // 커뮤니티 댓글 데이터 동기화
    }

    return isDeleted;
  }

  // 구독 체크
  Future<bool> subscribeCheck(int communityID) async {
    bool isSubscribe = false;

    var res = await ApiProvider().post(
        '/CommunityPost/Select/Subscribe',
        jsonEncode({
          'postID': communityID,
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    if (res != null) {
      isSubscribe = true;
    } else {
      isSubscribe = false;
    }

    return isSubscribe;
  }

  // 커뮤니티글 삭제하기
  Future<void> communityDeleteFunc(int communityID) async {
    var res = await ApiProvider().post(
        '/CommunityPost/Delete',
        jsonEncode({
          'postType': COMMUNITY_POST_TYPE_POST,
          'id': communityID,
        }));

    if (res != null && res) {
      syncCommunityDelete(communityID); // 커뮤니티 삭제 리스트 동기화
      if (Get.currentRoute == '/CommunityReplyPage') Get.back(); // 댓글 페이지면 뒤로가기

      Fluttertoast.showToast(
        msg: '삭제 되었습니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: '다시 시도해주세요.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );
    }
  }

  // 커뮤니티 데이터 가져오기
  Future<void> getCommunityData({isRefresh = false}) async {
    var tmpCommunity = await ApiProvider().post(
        '/CommunityPost/Select',
        jsonEncode({
          'index': isRefresh ? 0 : GlobalData.communityList.length,
        }));

    if (isRefresh) GlobalData.communityList.clear();

    if (tmpCommunity != null) {
      for (int i = 0; i < tmpCommunity.length; i++) {
        GlobalData.communityList.add(Community.fromJson(tmpCommunity[i]));
      }
    }
  }

  // 인기 게시글 데이터 가져오기
  Future<void> getPopularCommunityData({isRefresh = false}) async {
    var tmpPopularCommunity = await ApiProvider().post(
        '/CommunityPost/Select/Popular',
        jsonEncode({
          'index': isRefresh ? 0 : GlobalData.popularCommunityList.length,
        }));

    if (isRefresh) GlobalData.popularCommunityList.clear();

    if (tmpPopularCommunity != null) {
      for (int i = 0; i < tmpPopularCommunity.length; i++) {
        GlobalData.popularCommunityList.add(Community.fromJson(tmpPopularCommunity[i]));
      }
    }
  }

  // 내 게시글 데이터 가져오기
  Future<void> getMyCommunityData() async {
    GlobalData.myCommunityList.clear();

    var tmpCommunityList = await ApiProvider().post(
        '/CommunityPost/Select/ByUserID',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    if (tmpCommunityList != null) {
      for (int i = 0; i < tmpCommunityList.length; i++) {
        GlobalData.myCommunityList.add(Community.fromJson(tmpCommunityList[i]));
      }
    }
  }

  // 댓글 단 게시글 데이터 가져오기
  Future<void> getWroteReplyCommunityData() async {
    GlobalData.myCommunityList.clear();

    var tmpCommunityList = await ApiProvider().post(
        '/CommunityPost/Select/ReplyByUserID',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    if (tmpCommunityList != null && tmpCommunityList != false) {
      for (int i = 0; i < tmpCommunityList.length; i++) {
        GlobalData.myCommunityList.add(Community.fromJson(tmpCommunityList[i]));
      }
    }
  }

  // 좋아요한 게시글
  Future<void> getLikeCommunityData() async {
    GlobalData.myCommunityList.clear();

    var tmpCommunityList = await ApiProvider().post(
        '/CommunityPost/Select/LikeByUserID',
        jsonEncode({
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    if (tmpCommunityList != null) {
      for (int i = 0; i < tmpCommunityList.length; i++) {
        GlobalData.myCommunityList.add(Community.fromJson(tmpCommunityList[i]));
      }
    }
  }

  // 프로필 상세 정보
  Future<void> getDetailProfileData({required int userID, required UserData user, required List<Pet> petList}) async {
    GlobalData.profileCommunityList.clear();

    var res = await ApiProvider().post(
        '/User/Select/WithCommunity',
        jsonEncode({
          'userID': userID,
        }));

    if (res != null) {
      // 유저 데이터
      user.userID = res['userID'] ?? nullInt;
      user.nickName = res['nickName'] ?? '';
      user.profileURL = res['profileURL'] == null || res['profileURL'] == '' ? "" : ApiProvider().getImgUrl + '/ProfilePhotos/' + user.userID.toString() + '/' + res['profileURL'];
      user.location = res['location'] ?? '';

      // 펫 데이터
      res['petList'].forEach((element) {
        petList.add(Pet.fromJson(element));
      });

      // 커뮤니티 데이터
      if (res['communityList'] != null) {
        for (int i = 0; i < res['communityList'].length; i++) {
          GlobalData.profileCommunityList.add(Community.fromJson(res['communityList'][i]));
          GlobalData.profileCommunityList[i].nickName = user.nickName;
          GlobalData.profileCommunityList[i].profileURL = user.profileURL;
        }
      }
    }
  }
}
