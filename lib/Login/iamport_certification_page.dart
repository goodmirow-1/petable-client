import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/vfiamport/vf_certification_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/vfiamport/vf_iamport_certification.dart';

class iamportCertificationPage extends StatefulWidget {

  final String redirectPage;

  iamportCertificationPage({Key? key, required this.redirectPage}) : super(key: key);
  @override
  _iamportCertificationPageState createState() => _iamportCertificationPageState();
}

class _iamportCertificationPageState extends State<iamportCertificationPage> {
  String userCode = 'imp34502371';

  vfCertificationData? data;

  @override
  void initState() {
    data = vfCertificationData.fromJson({
      'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
      'company': '마이베프', // 회사명 또는 URL
      'm_redirect_url' : ApiProvider().getUrl + '/certifications/redirect',
      'redirect_page' : widget.redirectPage
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: vfIamportCertification(
          initialChild: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/image/Login/kg_inicis.svg', width: 200 * sizeUnit, height: 200 * sizeUnit,),
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                    child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
                  ),
                ],
              ),
            ),
          ),
          userCode: userCode,
          data: data!,
          callback: null
        ),
      ),
    );
  }
}
