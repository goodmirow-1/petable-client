import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/GlobalWidget/animated_tap_bar.dart';
import 'package:myvef_app/Config/GlobalWidget/community_post_card.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'package:myvef_app/community/community_search_page.dart';
import 'package:myvef_app/community/community_write_or_modify_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:get/get.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:myvef_app/community/pet_kind_selection_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityController controller = Get.put(CommunityController());
  final FilterController filterController = Get.put(FilterController());
  final ScrollController communityScrollController = ScrollController();
  final ScrollController popularScrollController = ScrollController();

  final Duration filterDuration = Duration(milliseconds: 500);
  final Curve filterCurves = Curves.fastOutSlowIn;

  final String svgDeselectIcon = 'assets/image/community/deselectIcon.svg'; // 선택 해제 아이콘
  final String svgFloatingAddIcon = 'assets/image/community/floatingAddIcon.svg'; // 플로팅 버튼 add
  final String svgFilterIcon = 'assets/image/community/filterIcon.svg'; // 필터 아이콘
  final String svgWriteIcon = 'assets/image/community/writeIcon.svg'; // 글쓰기 아이콘

  @override
  void initState() {
    super.initState();
    controller.currentScrollController = communityScrollController; // 스크롤 컨트롤러 세팅
    controller.onPage(true);
    communityScrollController.addListener(() {
      if (communityScrollController.position.maxScrollExtent == communityScrollController.position.pixels) {
        if (filterController.isFiltered.value)
          filterController.getFilterData(COMMUNITY_TYPE_NORMAL).then((value) => controller.stateUpdate());
        else
          controller.getCommunityData().then((value) => controller.stateUpdate());
      }
    });

    popularScrollController.addListener(() {
      if (popularScrollController.position.maxScrollExtent == popularScrollController.position.pixels) {
        if (filterController.isFiltered.value)
          filterController.getFilterData(COMMUNITY_TYPE_POPULAR).then((value) => controller.stateUpdate());
        else
          controller.getPopularCommunityData().then((value) => controller.stateUpdate());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    controller.onPage(false);
    controller.pageIndex(COMMUNITY_TYPE_NORMAL); // 탭바 초기화
    controller.offActive(); // 각종 액티브 끄기 (옵션, 필터, 플로팅 버튼 등)
    controller.moreContentsIDList.clear(); // 더 보기 한 커뮤니티 리스트 초기화

    communityScrollController.dispose();
    popularScrollController.dispose();
  }

  // 커뮤니티 포스트 카드 탭했을 때
  void postCardTapEvent() {
    controller.offOptions(); // 옵션 끄기

    // 필터박스 활성화 되어있을 때 필터 적용하기
    if (filterController.activeFilter.value) {
      filterController.activeFilter(false); // 필터 올리기

      filterController.isFilterLoading(true); // 로딩 시작
      controller.stateUpdate();

      // 필터 이벤트
      filterController.filterEvent().then((value) {
        filterController.isFilterLoading(false); // 로딩 끝
        controller.stateUpdate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: communityAppBar(context),
        body: Column(
          children: [
            Obx(() => buildFilter()), // 필터
            Obx(() => AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInExpo,
                  height: filterController.activeFilter.value ? 0 : 36 * sizeUnit,
                  child: ListView(
                    children: [
                      AnimatedTapBar(
                        barIndex: controller.pageIndex.value,
                        pageController: controller.pageController,
                        listTabItemTitle: ['전체', '인기'],
                      ),
                    ],
                  ),
                )),
            Obx(() => AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInExpo,
                  height: filterController.activeFilter.value ? 0 : 8 * sizeUnit,
                )),
            GetBuilder<CommunityController>(
              builder: (_) {
                ScrollPhysics scrollPhysics = AlwaysScrollableScrollPhysics();
                if (filterController.activeFilter.value) scrollPhysics = NeverScrollableScrollPhysics();

                return Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: controller.pageController,
                        physics: scrollPhysics,
                        itemCount: 2,
                        onPageChanged: (value) {
                          controller.offOptions(); // 옵션 끄기
                          controller.pageIndex(value);

                          // 스크롤 컨트롤러 세팅
                          if (value == COMMUNITY_TYPE_NORMAL) {
                            controller.currentScrollController = communityScrollController;
                          } else {
                            controller.currentScrollController = popularScrollController;
                          }
                        },
                        itemBuilder: (context, index) {
                          if (index == COMMUNITY_TYPE_NORMAL) {
                            List<Community> communityList = filterController.isFiltered.value ? GlobalData.filteredCommunityList : GlobalData.communityList;

                            return buildAllCommunity(communityList, scrollPhysics); // 전체
                          } else {
                            List<Community> communityList = filterController.isFiltered.value ? GlobalData.filteredPopularCommunityList : GlobalData.popularCommunityList;

                            return buildPopularCommunity(communityList, scrollPhysics); // 인기
                          }
                        },
                      ),
                      if (filterController.isFilterLoading.value) ...[
                        Container(color: Colors.black38, child: Center(child: GradientCircularProgressIndicator())), // 필터 로딩 처리
                      ],
                      if (controller.activeNewPost.value) newPostWidget(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: customFloatingButton(),
      ),
    );
  }

  // 새 글이 업데이트 되었어요
  Positioned newPostWidget() {
    return Positioned(
      top: 16 * sizeUnit,
      child: GestureDetector(
        onTap: () {
          controller.activeNewPost(false);
          controller.currentScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: filterCurves);
          controller.onRefresh();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * sizeUnit),
            color: Colors.white
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit, vertical: 4 * sizeUnit),
            decoration: BoxDecoration(
              boxShadow: vfBasicBoxShadow,
              borderRadius: BorderRadius.circular(16 * sizeUnit),
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(113, 102, 210, 0.6),
                  Color.fromRGBO(255, 163, 183, 0.6),
                ],
              ),
            ),
            child: Text("새 글이 업데이트 되었어요", style: VfTextStyle.body2().copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget customFloatingButton() {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller.activeFloating.value) ...[
            floatingChildButton(
              iconPath: svgMagnifyingGlassBlack,
              onTap: () {
                controller.offActive(); // 각종 액티브 끄기 (옵션, 필터, 플로팅 버튼 등)
                Get.to(() => CommunitySearchPage())!.then((value) => controller.stateUpdate());
              },
            ),
            SizedBox(height: 16 * sizeUnit),
            floatingChildButton(
              iconPath: svgWriteIcon,
              onTap: () {
                controller.offActive(); // 각종 액티브 끄기 (옵션, 필터, 플로팅 버튼 등)
                Get.to(() => CommunityWriteOrModifyPage(isWrite: true))!.then((value) => controller.stateUpdate());
              },
            ),
            SizedBox(height: 16 * sizeUnit),
          ],
          GestureDetector(
            onTap: () => controller.toggleFloating(),
            child: Container(
              padding: EdgeInsets.all(16 * sizeUnit),
              width: 56 * sizeUnit,
              height: 56 * sizeUnit,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(113, 102, 210, 0.6),
                    Color.fromRGBO(255, 163, 183, 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: AnimatedRotation(
                duration: Duration(milliseconds: 150),
                turns: controller.activeFloating.value ? 45 / 360 : 0 / 360,
                child: SvgPicture.asset(
                  svgFloatingAddIcon,
                  width: 24 * sizeUnit,
                  height: 24 * sizeUnit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget floatingChildButton({required String iconPath, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40 * sizeUnit,
        height: 40 * sizeUnit,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: vfBasicBoxShadow,
        ),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [vfColorViolet, vfColorPink],
            ).createShader(bounds);
          },
          child: SvgPicture.asset(
            iconPath,
            width: 24 * sizeUnit,
            height: 24 * sizeUnit,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildFilter() {
    return AnimatedContainer(
      duration: filterDuration,
      curve: filterCurves,
      width: double.infinity,
      height: filterController.activeFilter.value ? null : 0,
      constraints: BoxConstraints(maxHeight: Get.height * 0.7),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: vfBasicBoxShadow,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16 * sizeUnit),
            Padding(
              padding: EdgeInsets.only(left: 16 * sizeUnit, right: 10 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  filterContainer(
                    title: '주제',
                    stringList: communityCategories,
                    boolList: filterController.communityCategoryCheckList,
                  ),
                  Obx(() => filterController.kindFilterCheckInt.value < -1
                      ? SizedBox.shrink()
                      : filterContainer(
                          title: '품종',
                          stringList: GlobalData.communityPetKinds,
                          boolList: filterController.communityPetKindCheckList,
                          haveAddButton: true,
                          haveCancel: true,
                        )),
                  filterContainer(
                    title: '지역',
                    stringList: filterController.areaList,
                    boolList: filterController.communityLocationCheckList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column filterContainer({required String title, required List<String> stringList, required RxList<bool> boolList, bool haveAddButton = false, bool haveCancel = false}) {
    int num = haveAddButton ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleAndDeselect(title: title, boolList: boolList),
        SizedBox(height: 8 * sizeUnit),
        Wrap(
          spacing: 8 * sizeUnit,
          runSpacing: 8 * sizeUnit,
          children: List.generate(
            stringList.length + num,
            (index) {
              if (index == stringList.length)
                return filterItem(
                    index: index,
                    isAddButton: true,
                    onTap: () => Get.to(() => PetKindSelectionPage())!.then((value) {
                          if (value != null) filterController.addPetKind(value);
                        }));
              return Obx(() => filterItem(
                    text: stringList[index],
                    index: index,
                    isChecked: boolList[index],
                    haveCancel: haveCancel,
                    onTap: () => filterController.toggleFilterButton(index, boolList),
                  ));
            },
          ),
        ),
        SizedBox(height: 24 * sizeUnit),
      ],
    );
  }

  Widget filterItem({String text = '', required int index, bool isChecked = false, bool isAddButton = false, bool haveCancel = false, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                        onTap: () => filterController.removePetKind(index),
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

  Row titleAndDeselect({required String title, required List<bool> boolList}) {
    return Row(
      children: [
        Text(title, style: VfTextStyle.highlight3()),
        SizedBox(width: 16 * sizeUnit),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => List.generate(boolList.length, (index) => boolList[index] = false),
          child: Row(
            children: [
              SvgPicture.asset(
                svgDeselectIcon,
                width: 16 * sizeUnit,
                height: 16 * sizeUnit,
              ),
              SizedBox(width: 4 * sizeUnit),
              Text('선택 해제', style: VfTextStyle.bWriteDate()),
            ],
          ),
        ),
      ],
    );
  }

  // 전체 게시글
  Widget buildAllCommunity(List<Community> communityList, ScrollPhysics scrollPhysics) {
    return vfCustomRefreshIndicator(
      onRefresh: () => controller.onRefresh(),
      child: communityList.isEmpty
          ? buildNoSearchResult(scrollPhysics) // 검색 결과 없음
          : ListView.builder(
              controller: communityScrollController,
              physics: scrollPhysics,
              itemCount: communityList.length,
              itemBuilder: (context, index) {
                if (communityList[index].isBlind) return SizedBox.shrink(); // 블라인드 처리

                return CommunityPostCard(
                  community: communityList[index],
                  onTap: () => postCardTapEvent(),
                  callSetState: () => controller.stateUpdate(),
                );
              },
            ),
    );
  }

  // 인기 게시글
  Widget buildPopularCommunity(List<Community> communityList, ScrollPhysics scrollPhysics) {
    return vfCustomRefreshIndicator(
      onRefresh: () => controller.onRefresh(),
      child: communityList.isEmpty
          ? buildNoSearchResult(scrollPhysics) // 검색 결과 없음
          : ListView.builder(
              controller: popularScrollController,
              physics: scrollPhysics,
              itemCount: communityList.length,
              itemBuilder: (context, index) {
                if (communityList[index].isBlind) return SizedBox.shrink(); // 블라인드 처리

                return CommunityPostCard(
                  community: communityList[index],
                  onTap: () => postCardTapEvent(),
                  callSetState: () => controller.stateUpdate(),
                );
              },
            ),
    );
  }

  // 검색 결과 없음
  Widget buildNoSearchResult(ScrollPhysics scrollPhysics) {
    return GestureDetector(
      onTap: () => postCardTapEvent(),
      child: ListView(
        physics: scrollPhysics,
        children: [
          SizedBox(height: Get.height * 0.2),
          noSearchResultWidget(),
        ],
      ),
    );
  }

  PreferredSize communityAppBar(BuildContext context) {
    return vfAppBar(
      context,
      title: '커뮤니티',
      isBackButton: false,
      actions: [
        GestureDetector(
          onTap: () async {
            filterController.toggleFilter(); // 필터 토글

            // 필터 방금 올라갔으면
            if (!filterController.activeFilter.value) {
              filterController.isFilterLoading(true); // 로딩 시작
              controller.stateUpdate();

              await filterController.filterEvent(); // 필터 이벤트

              filterController.isFilterLoading(false); // 로딩 끝
            }

            controller.stateUpdate();
          },
          child: Obx(() => SvgPicture.asset(
                svgFilterIcon,
                width: 24 * sizeUnit,
                height: 24 * sizeUnit,
                color: filterController.isFiltered.value ? vfColorPink : vfColorBlack,
              )),
        ),
        SizedBox(width: 24 * sizeUnit),
        GestureDetector(
          onTap: () {
            controller.offOptions(); // 옵션 끄기
            mainPageScaffoldKey.currentState!.openEndDrawer();
          },
          child: SvgPicture.asset(
            svgSettingIcon,
            width: 24 * sizeUnit,
            height: 24 * sizeUnit,
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
      ],
    );
  }
}
