import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/gradient_circular_progress_indicator.dart';
import 'package:myvef_app/Config/Painter/circle_paint_widget.dart';

class GetExtendedImage extends StatefulWidget {
  final String url;
  final BoxFit boxFit;
  final bool showDescription;
  final double indicatorRadius;
  final double indicatorStrokeWidth;
  final double scale;
  final Widget? errorWidget;
  final Color backGroundColor;

  const GetExtendedImage({Key? key, required this.url, required this.boxFit, this.showDescription = true, this.indicatorRadius = 20, this.indicatorStrokeWidth = 5, this.scale = 1, this.errorWidget, this.backGroundColor = Colors.white})
      : super(key: key);

  @override
  _GetExtendedImageState createState() => _GetExtendedImageState();
}

class _GetExtendedImageState extends State<GetExtendedImage> with SingleTickerProviderStateMixin {
  late AnimationController extendedController;

  @override
  void initState() {
    extendedController = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    extendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) return Container();

    return ExtendedImage.network(
      widget.url,
      fit: widget.boxFit,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            extendedController.reset();
            return Container(
              color: widget.backGroundColor,
              child: Center(
                child: GradientCircularProgressIndicator(
                  radius: widget.indicatorRadius,
                  strokeWidth: widget.indicatorStrokeWidth,
                ),
              ),
            );
          //return null;
          //return state.completedWidget;
          case LoadState.completed:
            extendedController.forward();
            return FadeTransition(
              opacity: extendedController,
              child: ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                fit: BoxFit.cover,
              ),
            );
          case LoadState.failed:
            extendedController.reset();

            return Container(
              color: Colors.white,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => state.reLoadImage(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (widget.errorWidget != null) ...[
                      widget.errorWidget!,
                    ] else ...[
                      CirclePaintWidget(
                        color: vfColorPink,
                        diameter: 204 * sizeUnit * widget.scale,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            vfBetiBodyBadStateWidget()
                          ],
                        ),
                      ),
                    ],
                    if (widget.showDescription) ...[
                      SizedBox(height: 24 * sizeUnit * widget.scale),
                      Text(
                        "사진 불러오기를 실패했어요!\n다시 한번 클릭해 주세요",
                        textAlign: TextAlign.center,
                        style: widget.scale >= 1 ? VfTextStyle.body1() : VfTextStyle.body2(),
                      ),
                    ],
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
