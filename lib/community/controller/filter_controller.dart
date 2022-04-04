import 'dart:convert';

import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FilterController extends GetxController {
  static get to => Get.find<FilterController>();

  final List<String> areaList = List.generate(areaCategory.length, (index) => abbreviateForLocation(areaCategory[index])); // 약어화한 지명 리스트

  RxList<bool> communityCategoryCheckList = <bool>[].obs; // 주제 리스트
  List<bool> tempCommunityCategoryCheckList = <bool>[]; // 임시 주제 리스트

  RxList<bool> communityPetKindCheckList = <bool>[].obs; // 품종 리스트
  List<bool> tempCommunityPetKindCheckList = <bool>[]; // 임시 품종 리스트

  RxList<bool> communityLocationCheckList = <bool>[].obs; // 지역 리스트
  List<bool> tempCommunityLocationCheckList = <bool>[]; // 임시 지역 리스트

  RxBool activeFilter = false.obs; // 필터박스가 열렸는지
  RxBool isFiltered = false.obs; // 필터 적용 여부
  RxInt kindFilterCheckInt = 0.obs; // 필터 바뀌었는지 체크
  RxBool isFilterLoading = false.obs; // 필터 로딩중인지

  // 필터 단어
  String categoryForFilter = '';
  String kindForFilter = '';
  String locationForFilter = '';

  // 필터 카테고리별 체크 여부
  int categoryCheckAll = 1;
  int kindCheckAll = 1;
  int locationCheckAll = 1;

  // 품종 삭제
  void removePetKind(int index, {Function? callback}) async {
    final prefs = await SharedPreferences.getInstance();

    GlobalData.communityPetKinds.removeAt(index);
    communityPetKindCheckList.removeAt(index);
    kindFilterCheckInt++; // 필터 obx 돌려주기

    if (callback != null) callback;

    prefs.setStringList('communityPetKindList', GlobalData.communityPetKinds);
  }

  // 품종 추가
  void addPetKind(String value) async {
    // 이미 추가된 품종인지 체크
    if (GlobalData.communityPetKinds.contains(value)) {
      Fluttertoast.showToast(msg: "이미 추가된 품종입니다.", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    GlobalData.communityPetKinds.add(value);
    communityPetKindCheckList.add(false);
    kindFilterCheckInt++; // 필터 obx 돌려주기

    prefs.setStringList('communityPetKindList', GlobalData.communityPetKinds);
  }

  // 페이지 종료시 필터 관리
  void disposeFilter() {
    if (activeFilter.value) activeFilter(false); // 필터 박스 올리기

    if (isFiltered.value)
      overWriteFilterLists(); // 필터가 켜져있으면 적용 된 필터로 덮어쓰기
    else
      resetFilterBoolList(); // 필터가 꺼져있으면 필터 다 끄기
  }

  // 적용된 필티 임시 리스트에 저장
  void saveFilterContents() {
    tempCommunityCategoryCheckList = [...communityCategoryCheckList];
    tempCommunityPetKindCheckList = [...communityPetKindCheckList];
    tempCommunityLocationCheckList = [...communityLocationCheckList];
  }

  // 저장한 임시 리스트 데이터를 정식 리스트로
  void overWriteFilterLists() {
    communityCategoryCheckList = [...tempCommunityCategoryCheckList].obs;
    communityPetKindCheckList = [...tempCommunityPetKindCheckList].obs;
    communityLocationCheckList = [...tempCommunityLocationCheckList].obs;
  }

  // 필터 bool 리스트 세팅
  void resetFilterBoolList() {
    communityCategoryCheckList = List.generate(communityCategories.length, (index) => false).obs;
    communityPetKindCheckList = List.generate(GlobalData.communityPetKinds.length, (index) => false).obs;
    communityLocationCheckList = List.generate(areaCategory.length, (index) => false).obs;
  }

  // 필터 버튼 토글
  void toggleFilterButton(int index, List<bool> boolList) {
    boolList[index] = !boolList[index];
  }

  // 필터 토글
  void toggleFilter() async {
    activeFilter(!activeFilter.value);
  }

  // 필터 이벤트
  Future<void> filterEvent() async {
    bool preIsFiltered = isFiltered.value; // 이전 필터 적용 여부

    categoryForFilter = makeFilterWord(boolList: communityCategoryCheckList, filterCategoryList: communityCategories);

    if (categoryForFilter.isNotEmpty)
      categoryCheckAll = 0;
    else
      categoryCheckAll = 1;

    kindForFilter = makeFilterWord(boolList: communityPetKindCheckList, filterCategoryList: GlobalData.communityPetKinds, isKind: true);

    locationForFilter = makeFilterWord(boolList: communityLocationCheckList, filterCategoryList: areaCategory);
    if (locationForFilter.isNotEmpty)
      locationCheckAll = 0;
    else
      locationCheckAll = 1;

    if (categoryCheckAll == 0 || communityPetKindCheckList.contains(true) || locationCheckAll == 0) {
      await getFilterData(COMMUNITY_TYPE_NORMAL, isRefresh: true);
      await getFilterData(COMMUNITY_TYPE_POPULAR, isRefresh: true);

      saveFilterContents(); // 적용된 필터 임시 리스트에 저장

      isFiltered(true); // 필터 켜기
    } else {
      GlobalData.filteredCommunityList.clear(); // 필터 커뮤니티 리스트 초기화
      GlobalData.filteredPopularCommunityList.clear(); // 필터 인기 커뮤니티 리스트 초기화

      isFiltered(false); // 필터 끄기
    }

    if (isFiltered.value)
      CommunityController.to.scrollJumpToTop(); // 필터 적용 시 스크롤 상단이동
    else if (!isFiltered.value && preIsFiltered) CommunityController.to.scrollJumpToTop(); // 필터 적용 -> 비적용으로 갔을 떄 스크롤 상단이동
  }

  // 필터 검색어 조합
  String makeFilterWord({required List<bool> boolList, required List<String> filterCategoryList, bool isKind = false}) {
    String result = '';

    // 품종 아무것도 선택하지 않았으면 -1 리턴
    if (isKind && !boolList.contains(true)) return '-1';

    for (int i = 0; i < boolList.length; i++) {
      String value = filterCategoryList[i];

      // 체크 되어을 때
      if (boolList[i]) {
        if (!isKind) {
          // 품종이 아닐 때
          if (result.isEmpty) {
            result = value;
          } else {
            result += '|^' + value;
          }
        } else {
          // 품종이라면
          if (value == '강아지 전체') {
            value = '1';
          } else if (value == '고양이 전체') {
            value = '2';
          }

          if (result.isEmpty) {
            result = value;
          } else {
            result += '|' + value;
          }
        }
      }
    }
    return result;
  }

  // 필터 데이터 가져오기
  Future<void> getFilterData(int type, {bool isRefresh = false}) async {
    int index = 0;

    // 타입에 따라 index 정하기
    if (type == COMMUNITY_TYPE_NORMAL) {
      index = isRefresh ? 0 : GlobalData.filteredCommunityList.length;
    } else if (type == COMMUNITY_TYPE_POPULAR) {
      index = isRefresh ? 0 : GlobalData.filteredPopularCommunityList.length;
    }

    var filterResult = await ApiProvider().post(
        '/CommunityPost/Filter',
        jsonEncode({
          'category': categoryForFilter,
          'kind': kindForFilter,
          'location': locationForFilter,
          'categoryCheckAll': categoryCheckAll,
          'locationCheckAll': locationCheckAll,
          'type': type,
          'index': index,
        }));

    // 리프레시면 clear 하기
    if (isRefresh) {
      if (type == COMMUNITY_TYPE_NORMAL) {
        GlobalData.filteredCommunityList.clear();
      } else if (type == COMMUNITY_TYPE_POPULAR) {
        GlobalData.filteredPopularCommunityList.clear();
      }
    }

    if (filterResult != null && filterResult.isNotEmpty) {

      for (int i = 0; i < filterResult.length; i++) {
        Community tmpCommunity = Community.fromJson(filterResult[i]);

        if (type == COMMUNITY_TYPE_NORMAL) {
          GlobalData.filteredCommunityList.add(tmpCommunity); // 전체
        } else if (type == COMMUNITY_TYPE_POPULAR) {
          GlobalData.filteredPopularCommunityList.add(tmpCommunity); // 인기
        }
      }
    }
  }

  // 글쓰기 할 때 필터 체크해서 필터에 적용되면 insert
  void filterCheckForCommunityWrite({required String category, required String kind, required String location, required Community community}) {
    // 주제 확인
    if (categoryForFilter.contains(category)) {
      return GlobalData.filteredCommunityList.insert(0, community);
    }

    // 품종 확인
    if (kindForFilter.contains(kind)) {
      return GlobalData.filteredCommunityList.insert(0, community);
    }

    // 지역 확인
    if (location.contains(locationForFilter)) {
      return GlobalData.filteredCommunityList.insert(0, community);
    }
  }
}
