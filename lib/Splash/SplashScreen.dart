import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Login/LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Get.off(() => LoginPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      colorType: vfGradationColorType.Red,
      type: 1,
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SvgPicture.asset(
                svgVfLogoAndText,
                width: 148 * sizeUnit,
                height: 120 * sizeUnit,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Text(
                    'Copyright 2021 SHEEPS Inc. 모든 권리 보유.',
                    style: VfTextStyle.body2(),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40 * sizeUnit),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
