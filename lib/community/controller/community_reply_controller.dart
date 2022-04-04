import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum COMMUNITY_REPLY_WRITE_MODE { reply, replyReply } // 커뮤니티 댓글쓰기 모드

class CommunityReplyController extends GetxController {
  static get to => Get.find<CommunityReplyController>();

  COMMUNITY_REPLY_WRITE_MODE communityReplyWriteMode = COMMUNITY_REPLY_WRITE_MODE.reply; // 댓글 모드

  RxBool isSubscribe = false.obs; // 알림 받기 여부
  RxList<int> replyListForShowReplyReply = <int>[].obs; // 답글 보여줄 리스트
  RxInt showOptionReply = nullInt.obs; // 옵션 보여줄 댓글
  RxInt showOptionReplyReply = nullInt.obs; // 옵션 보여줄 답글
  RxString contents = ''.obs;

  CommunityPostReply selectedCommunityReply = CommunityPostReply(); // 선택된 댓글
  String selectedReplyUserNickName = ''; // 선택된 댓글의 유저 닉네임

  // 벨 토글 이벤트
  void bellToggle(int communityID) async{
    var res = await ApiProvider().post(
        '/CommunityPost/Update/Subscribe',
        jsonEncode({
          'postID': communityID,
          'userID': GlobalData.loggedInUser.value.userID,
        }));

    isSubscribe(res['created']);
  }

  // 답글 보기 이벤트
  void showReplyReplyEvent(int replyID) {
    replyListForShowReplyReply.add(replyID);
  }

  // 답글쓰기 눌렀을 때
  void pressWriteReplyReply({required FocusNode focusNode, required CommunityPostReply reply}) {
    UserData replyUser = GlobalData.simpleUserList.singleWhere((element) => element.userID == reply.userId); // 유저 정보

    communityReplyWriteMode = COMMUNITY_REPLY_WRITE_MODE.replyReply; // 댓글 모드 변경
    debugPrint('답글 쓰기 모드로 변경');
    selectedCommunityReply = reply; // 선택된 댓글
    selectedReplyUserNickName = replyUser.nickName; // 선택된 댓글의 유저 닉네임
    focusNode.requestFocus();
  }

  // 옵션 끄기
  void offOption() {
    showOptionReply(nullInt);
    showOptionReplyReply(nullInt);
  }

  // 옵션 토글
  void showOptionToggle({required int replyID, required bool isReply}) {
    if (isReply) {
      showOptionReplyReply(nullInt); // 답글 옵션 끄기

      if (showOptionReply.value == replyID)
        showOptionReply(nullInt);
      else
        showOptionReply(replyID);
    } else {
      showOptionReply(nullInt); // 댓글 옵션 끄기

      if (showOptionReplyReply.value == replyID)
        showOptionReplyReply(nullInt);
      else
        showOptionReplyReply(replyID);
    }
  }

  // 댓글 쓰기 이벤트
  Future<void> writeReply(int communityID) async {
    var res = await ApiProvider().post(
        '/CommunityPost/Insert/Reply',
        jsonEncode({
          'postID': communityID,
          'userID': GlobalData.loggedInUser.value.userID,
          'contents': contents.value,
        }));

    if (res != null) {
      CommunityPostReply reply = CommunityPostReply.fromJson(res);
      reply.isShow = 1;

      syncAddCommunityReply(communityID, reply); // 댓글 추가 동기화
      addSimpleUserData(); // 유저 데이터 넣어주기
    }
  }

  // 답글 쓰기 이벤트
  Future<void> writeReplyReply() async {
    var res = await ApiProvider().post(
        '/CommunityPost/Insert/ReplyReply',
        jsonEncode({
          'replyID': selectedCommunityReply.id,
          'userID': GlobalData.loggedInUser.value.userID,
          'contents': contents.value,
        }));

    if (res != null) {
      CommunityPostReplyReply replyReply = CommunityPostReplyReply.fromJson(res);
      replyReply.isShow = 1;

      selectedCommunityReply.communityReplyReplies.add(replyReply); // 답글 추가
      addSimpleUserData(); // 유저 데이터 넣어주기
    }
  }

  // 유저 데이터 넣어주기
  void addSimpleUserData(){
    for(int i = 0; i < GlobalData.simpleUserList.length; i++){
      if(GlobalData.simpleUserList[i].userID == GlobalData.loggedInUser.value.userID) {
        return;
      }
    }

    UserData simpleUser = UserData.setData(
      oldUser: UserData(),
      newUser: UserData(
        userID: GlobalData.loggedInUser.value.userID,
        nickName: GlobalData.loggedInUser.value.nickName,
        profileURL: GlobalData.loggedInUser.value.profileURL,
        location: GlobalData.loggedInUser.value.location,
      ),
    );
    GlobalData.simpleUserList.add(simpleUser);
  }

  // 댓글, 답글 삭제 함수
  Future<void> deleteFunc({required int communityID, required int id, required int postType, CommunityPostReplyReply? communityPostReplyReply}) async {
    var res = await ApiProvider().post(
        '/CommunityPost/Delete',
        jsonEncode({
          'postType': postType,
          'id': id,
        }));

    if (res != null && res) {
      // 삭제 동기화
      switch (postType) {
        case COMMUNITY_POST_TYPE_REPLY:
          syncCommunityReplyDelete(communityID, id); // 댓글 삭제 동기화
          break;
        case COMMUNITY_POST_TYPE_REPLY_REPLY:
          communityPostReplyReply!.isShow = 0;
          break;
      }

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
}
