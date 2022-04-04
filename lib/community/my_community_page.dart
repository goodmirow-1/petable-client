import 'package:flutter/material.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/community_post_card.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:get/get.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({Key? key, required this.appBarTitle}) : super(key: key);

  final String appBarTitle;

  @override
  State<MyCommunityPage> createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  final CommunityController controller = Get.find<CommunityController>();

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: vfAppBar(context, title: widget.appBarTitle),
        body: GlobalData.myCommunityList.isEmpty
            ? noSearchResultWidget()
            : ListView.builder(
                itemCount: GlobalData.myCommunityList.length,
                itemBuilder: (context, index) {
                  return CommunityPostCard(
                    community: GlobalData.myCommunityList[index],
                    onTap: () => controller.offOptions(), // 옵션 끄기
                    callSetState: () => setState(() {}),
                  );
                },
              ),
      ),
    );
  }
}
