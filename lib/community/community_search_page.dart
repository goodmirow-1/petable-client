import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/GlobalWidget/community_post_card.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/community_search_controller.dart';
import 'package:get/get.dart';

class CommunitySearchPage extends StatelessWidget {
  final CommunitySearchController controller = Get.put(CommunitySearchController());
  final CommunityController communityController = Get.find<CommunityController>();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(context, title: '글 검색'),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => unFocus(context),
          child: Column(
            children: [
              SizedBox(height: 8 * sizeUnit),
              buildSearchBar(),
              SizedBox(height: 16 * sizeUnit),
              Expanded(
                child: GetBuilder<CommunitySearchController>(
                  builder: (_) {
                    switch (controller.searchState) {
                      case COMMUNITY_SEARCH_STATE.beforeSearch:
                        return SizedBox.shrink();
                      case COMMUNITY_SEARCH_STATE.loading:
                        return buildLoadingWidget(); // 로딩
                      case COMMUNITY_SEARCH_STATE.afterSearch:
                        if (GlobalData.searchedCommunityList.isEmpty) return noSearchResultWidget(); // 검색 결과가 없어요!

                        return buildSearchResult(); // 검색 결과
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로딩 위젯
  Center buildLoadingWidget() {
    return Center(
      child: GradientCircularProgressIndicator(),
    );
  }

  // 검색 결과 리스트
  Widget buildSearchResult() {
    return ListView.builder(
      itemCount: GlobalData.searchedCommunityList.isNotEmpty ? GlobalData.searchedCommunityList.length : 0,
      itemBuilder: (context, index) {

        return CommunityPostCard(
          community: GlobalData.searchedCommunityList[index],
          onTap: () => communityController.offOptions(), // 옵션 끄기
          callSetState: () => controller.stateUpdate(),
        );
      },
    );
  }

  // 검색 바
  Padding buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: vfTextField(
        textEditingController: textEditingController,
        focusNode: focusNode,
        hintText: '검색어를 입력해 주세요.',
        borderColor: vfColorPink,
        suffixIcon: IconButton(
          splashRadius: 20 * sizeUnit,
          icon: Obx(() => SvgPicture.asset(
            svgMagnifyingGlassBlack,
            color: removeSpace(controller.keyword.value).length < 2 ? vfColorDarkGray : vfColorBlack,
          )),
          onPressed: () {
            focusNode.unfocus();
            controller.searchFunc();
          },
        ),
        onSubmitted: (_) => controller.searchFunc(),
        onChanged: (value) => controller.keyword(value),
      ),
    );
  }
}
