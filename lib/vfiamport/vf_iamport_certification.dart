import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/vfiamport/vf_certification_data.dart';
import 'package:iamport_flutter/model/url_data.dart';
import 'package:myvef_app/vfiamport/vf_iamport_webview.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';

class vfIamportCertification extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? initialChild;
  final String userCode;
  final vfCertificationData data;
  final callback;

  vfIamportCertification({
    Key? key,
    this.appBar,
    this.initialChild,
    required this.userCode,
    required this.data,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return vfIamportWebView(
      type: ActionType.auth,
      appBar: this.appBar,
      initialChild: this.initialChild,
      redirectURL: this.data.mRedirectUrl,
      redirectPage: this.data.redirectPage,
      executeJS: (WebViewController controller) {
        controller.evaluateJavascript('''
            IMP.init("${this.userCode}");
            IMP.certification(${jsonEncode(this.data.toJson())}, function(response) {
              const query = [];
              Object.keys(response).forEach(function(key) {
                query.push(key + "=" + response[key]);
              });
              location.href = "${UrlData.redirectUrl}" + "?" + query.join("&");
            });
          ''');
      },
      useQueryData: (Map<String, String> data) {
        this.callback(data);
      },
      isPaymentOver: (String url) {
        return url.startsWith(UrlData.redirectUrl);
      },
      // 인증에는 customPGAction 수행할 필요 없음
      customPGAction: (WebViewController controller) {},
    );
  }
}
