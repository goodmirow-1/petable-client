import 'package:flutter/material.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';

class ImageDetailPage extends StatelessWidget {
  ImageDetailPage({Key? key, required this.imgUrlList}) : super(key: key);

  final List<String> imgUrlList;
  final PageController pageController = PageController();

  RxInt currentPage = 1.obs;

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(height: 16 * sizeUnit),
            customAppBar(),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 360 * sizeUnit,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: imgUrlList.length,
                    onPageChanged: (value) => currentPage(value + 1),
                    itemBuilder: (context, index) {
                      return GetExtendedImage(
                        url: imgUrlList[index],
                        boxFit: BoxFit.cover,
                        backGroundColor: Colors.black,
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row customAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16 * sizeUnit),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: SvgPicture.asset(
              svgBackArrow,
              color: Colors.white,
              width: 24 * sizeUnit,
            ),
          ),
        ),
        Obx(() => Text(
          '${currentPage.value} / ${imgUrlList.length}',
          style: VfTextStyle.subTitle2().copyWith(color: Colors.white),
        )),
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: SizedBox(width: 24 * sizeUnit),
        ),
      ],
    );
  }

}
