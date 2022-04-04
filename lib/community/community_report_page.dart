import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:myvef_app/community/controller/community_report_controller.dart';
import 'package:myvef_app/community/model/community.dart';

class CommunityReportPage extends StatelessWidget {
  CommunityReportPage({Key? key, required this.postType, required this.postID, this.community, this.communityPostReply, this.communityPostReplyReply}) : super(key: key);

  final int postType;
  final int postID;
  final Community? community;
  final CommunityPostReply? communityPostReply;
  final CommunityPostReplyReply? communityPostReplyReply;

  final CommunityReportController controller = Get.put(CommunityReportController());
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        appBar: vfAppBar(context, title: '신고하기'),
        body: GestureDetector(
          onTap: () => unFocus(context),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: reportList.length,
                        itemBuilder: (context, index) => reportItem(reportList[index], index),
                      ),
                      SizedBox(height: 24 * sizeUnit),
                      Obx(() => reportContentsWidget()), // 신고 내용 위젯
                    ],
                  ),
                ),
              ),
              Obx(() => vfGradationButton(
                  text: '신고하기',
                  colorType: vfGradationColorType.Violet,
                  isOk: controller.title.value == '기타' ? removeSpace(controller.contents.value).isNotEmpty : controller.title.isNotEmpty,
                  onTap: () {
                    unFocus(context);
                    showVfDialog(
                      colorType: vfGradationColorType.Violet,
                      title: '신고 하시겠어요?',
                      description: '허위 신고 시\n관리자에 의해 제재 받을 수 있습니다.',
                      isCancelButton: true,
                      cancelText: '취소',
                      cancelFunc: () => Get.back(),
                      okFunc: () => controller.submitReport(
                        postType: postType,
                        targetID: postID,
                        community: community,
                        communityPostReply: communityPostReply,
                        communityPostReplyReply: communityPostReplyReply,
                      ),
                    );
                  })),
            ],
          ),
        ),
      ),
    );
  }

  Widget reportContentsWidget() {
    return controller.title.value == '기타'
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('신고내용', style: VfTextStyle.body2()),
                      Obx(() => Text('${controller.contents.value.length}/500', style: VfTextStyle.bWriteDate())),
                    ],
                  ),
                ),
                SizedBox(height: 8 * sizeUnit),
                vfTextField(
                  textEditingController: textEditingController,
                  borderColor: vfColorPink,
                  textStyle: VfTextStyle.body2(),
                  onChanged: (value) => controller.contents(value),
                ),
                SizedBox(height: Get.height * 0.1),
              ],
            ),
          )
        : SizedBox();
  }

  Widget reportItem(String reportTitle, int index) {
    return Column(
      children: [
        Obx(() => RadioListTile(
              value: reportTitle,
              title: Text(reportTitle, style: VfTextStyle.body1()),
              activeColor: vfColorPink,
              groupValue: controller.title.value,
              onChanged: (value) {
                controller.title(value.toString());
                controller.titleIdx = index;
              },
            )),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
          height: 1 * sizeUnit,
          width: double.infinity,
          color: vfColorGrey,
        ),
      ],
    );
  }
}
