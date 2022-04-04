import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityReportController extends GetxController {
  static get to => Get.find<CommunityReportController>();

  int titleIdx = nullInt; // 신고 제목 인덱스
  RxString title = ''.obs; // 신고 제목
  RxString contents = ''.obs; // 신고 내용

  Future<void> submitReport({required int postType, required int targetID, Community? community, CommunityPostReply? communityPostReply, CommunityPostReplyReply? communityPostReplyReply}) async {
    var res = await ApiProvider().post(
      '/CommunityPost/Declare',
      jsonEncode({
        'postType': postType,
        'userID': GlobalData.loggedInUser.value.userID,
        'targetID': targetID,
        'contents': contents.value,
        'type': titleIdx,
      }),
    );

    // postType에 따라 신고 갯수 늘려주기
    if(res != null) {
      if(res[1]) {
        switch(postType){
          case COMMUNITY_POST_TYPE_POST:
            community!.declareLength++;
            community.isBlind = communityPostBlindCheck(declareLength: community.declareLength, likeLength: community.communityPostLikes.length);
            break;
          case COMMUNITY_POST_TYPE_REPLY:
            communityPostReply!.declareLength++;
            communityPostReply.isBlind = replyBlindCheck(communityPostReply.declareLength);
            break;
          case COMMUNITY_POST_TYPE_REPLY_REPLY:
            communityPostReplyReply!.declareLength++;
            communityPostReplyReply.isBlind = replyBlindCheck(communityPostReplyReply.declareLength);
            break;
        }

        Fluttertoast.showToast(
          msg: '신고되었습니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: '이미 신고한 글입니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );
      }
    }

    Get.back();
    Get.back();
  }
}
