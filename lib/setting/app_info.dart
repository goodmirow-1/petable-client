import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import '../Config/GlobalWidget/GlobalWidget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

class AppInfo extends StatelessWidget {

  late final PackageInfo packageInfo;

  AppInfo({required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 1,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '앱 정보',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgVfLogo),
              SizedBox(height: 24 * sizeUnit),
              Text('마이베프 최신 버전을 사용중이세요', style: VfTextStyle.subTitle2()),
              SizedBox(height: 8 * sizeUnit),
              Text('현재 버전 ' + packageInfo.version, style: VfTextStyle.body2()),
              SizedBox(height: 24 * sizeUnit),
              GestureDetector(
                child: Container(
                  height: 26 * sizeUnit,
                  width: 70 * sizeUnit,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12*sizeUnit),
                    color: vfColorPink,

                  ),
                  child: Center(
                    child: Text(
                      '회사정보',
                      style: VfTextStyle.body2().copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () {
                  Get.to(() => CompanyInfo());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyInfo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '회사정보',
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 40 * sizeUnit, right: 40 * sizeUnit),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('상호', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('주식회사 아이비알', style: VfTextStyle.highlight3()),
              SizedBox(height: 32 * sizeUnit),
              Text('대표', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('김태완', style: VfTextStyle.highlight3()),
              SizedBox(height: 32 * sizeUnit),
              Text('주소', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('인천광역시 연수구 송도과학로 32, S동 2703호(송도동, 송도테크노파크IT센터)', style: VfTextStyle.highlight3()),
              SizedBox(height: 32 * sizeUnit),
              Text('홈페이지', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('www.presento.co.kr', style: VfTextStyle.highlight3()),
              SizedBox(height: 32 * sizeUnit),
              Text('사업자등록번호', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('416-87-01210', style: VfTextStyle.highlight3()),
              SizedBox(height: 32 * sizeUnit),
              Text('통신판매업신고번호', style: VfTextStyle.subTitle4()),
              SizedBox(height: 8 * sizeUnit),
              Text('2019-인천연수구-0667', style: VfTextStyle.highlight3()),
            ],
          ),
        ),
      ),
    );
  }
}

