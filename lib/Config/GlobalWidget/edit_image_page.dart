import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_editor/image_editor.dart';

class EditImagePage extends StatelessWidget {
  EditImagePage({Key? key, required this.imageFile}) : super(key: key);

  final File imageFile;

  GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();
  final List<Map<String, String>> navItemList = [
    {'title': 'Crop', 'iconPath': 'assets/image/nav_bar/crop.svg'},
    {'title': 'Flip', 'iconPath': 'assets/image/nav_bar/flip.svg'},
    {'title': 'Rotate Left', 'iconPath': 'assets/image/nav_bar/rotateLeft.svg'},
    {'title': 'Rotate Right', 'iconPath': 'assets/image/nav_bar/rotateRight.svg'},
    {'title': 'Reset', 'iconPath': 'assets/image/nav_bar/reset.svg'},
  ];

  bool initialize = true;

  @override
  Widget build(BuildContext context) {
    final String imageExtension = imageFile.path.split('.').last;

    // gif 일 경우 편집 기능 x
    if(initialize) {
      initialize = false;
      if(imageExtension == 'gif') {
        Get.back(result: imageFile);
      }
    }

    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: vfAppBar(
          context,
          actions: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 16 * sizeUnit),
              child: GestureDetector(
                onTap: () => _cropImage(),
                child: Text(
                  '완료',
                  style: VfTextStyle.headline4().copyWith(fontSize: 15 * sizeUnit),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ExtendedImage.file(
                imageFile,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                enableLoadState: true,
                extendedImageEditorKey: editorKey,
                initEditorConfigHandler: (ExtendedImageState? state) {
                  return EditorConfig(
                      maxScale: 8.0 * sizeUnit,
                      cropRectPadding: EdgeInsets.zero,
                      hitTestSize: 20.0 * sizeUnit,
                      initCropRectType: InitCropRectType.imageRect,
                      editorMaskColorHandler: (context, isOnPressed) {
                        return isOnPressed ? Colors.black38 : Colors.black12;
                      });
                },
                cacheRawData: true,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          selectedFontSize: 3 * sizeUnit,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            switch(index) {
              case 0:
                break;
              case 1:
                editorKey.currentState!.flip();
                break;
              case 2:
                editorKey.currentState!.rotate(right: false);
                break;
              case 3:
                editorKey.currentState!.rotate();
                break;
              case 4:
                editorKey.currentState!.reset();
                break;
            }
          },
          items: List.generate(navItemList.length, (index) {
            Map<String, String> navItem = navItemList[index];

            return BottomNavigationBarItem(
              label: navItem['title']!,
              icon: SvgPicture.asset(navItem['iconPath']!),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    String msg;

    try {
      Uint8List? fileData;

      fileData = await cropImageDataWithNativeLibrary(state: editorKey.currentState!);
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg').create();
      file.writeAsBytesSync(fileData!);
      Get.back(result: file);
    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      debugPrint(msg);
    }
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary({required ExtendedImageEditorState state}) async {
    debugPrint('native library start cropping');

    final Rect? cropRect = state.getCropRect();
    final EditActionDetails action = state.editAction!;

    final int rotateAngle = action.rotateAngle.toInt();
    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List img = state.rawImageData;

    final ImageEditorOption option = ImageEditorOption();

    if (action.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    }

    if (action.hasRotateAngle) {
      option.addOption(RotateOption(rotateAngle));
    }

    final DateTime start = DateTime.now();
    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    debugPrint('${DateTime.now().difference(start)} ：total time');
    return result;
  }
}
