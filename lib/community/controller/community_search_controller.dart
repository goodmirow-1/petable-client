import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum COMMUNITY_SEARCH_STATE { beforeSearch, loading, afterSearch } // 검색 상태 (검색 전, 로딩중, 검색 후)

class CommunitySearchController extends GetxController {
  COMMUNITY_SEARCH_STATE searchState = COMMUNITY_SEARCH_STATE.beforeSearch; // 검색 상태

  RxString keyword = ''.obs; // 검색어

  @override
  void onClose() {
    super.onClose();

    GlobalData.searchedCommunityList.clear(); // 검색 리스트 초기화
  }

  // 스테이트 업데이트 용도
  void stateUpdate() {
    update();
  }

  // 검색 함수
  Future<void> searchFunc() async {
    if (removeSpace(keyword.value).length < 2) {

      Fluttertoast.showToast(
        msg: '2자 이상 입력해주세요.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );

      return;
    }

    // 로딩 돌리기
    searchState = COMMUNITY_SEARCH_STATE.loading;
    update();

    GlobalData.searchedCommunityList.clear();

    var tmpCommunityList = await ApiProvider().post(
        '/CommunityPost/Search',
        jsonEncode({
          'keywords': keyword.value,
        }));

    if (tmpCommunityList != null) {
      tmpCommunityList.forEach((element) {
        GlobalData.searchedCommunityList.add(Community.fromJson(element));
      });
    }

    // 검색 완료 처리
    searchState = COMMUNITY_SEARCH_STATE.afterSearch;
    update();
  }
}
