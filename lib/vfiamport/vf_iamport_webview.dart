import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iamport_flutter/model/iamport_url.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:get/get.dart';

import 'package:myvef_app/Network/ApiProvider.dart';

enum ActionType { auth, payment }

class vfIamportWebView extends StatefulWidget {
  static final Color primaryColor = Color(0xff344e81);
  static final String html = '''
    <html>
      <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">

        <script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js" ></script>
        <script type="text/javascript" src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
      </head>
      <body></body>
    </html>
  ''';

  final ActionType type;
  final PreferredSizeWidget? appBar;
  final Widget? initialChild;
  final ValueSetter<WebViewController> executeJS;
  final ValueSetter<Map<String, String>> useQueryData;
  final Function isPaymentOver;
  final Function customPGAction;

  final String? redirectURL;
  final String? redirectPage;

  vfIamportWebView({
    required this.type,
    this.appBar,
    this.initialChild,
    required this.executeJS,
    required this.useQueryData,
    required this.isPaymentOver,
    required this.customPGAction,

    this.redirectURL,
    this.redirectPage
  });

  @override
  _vfIamportWebViewState createState() => _vfIamportWebViewState();
}

class _vfIamportWebViewState extends State<vfIamportWebView> {
  late WebViewController _webViewController;
  StreamSubscription? _sub;
  late int _isWebviewLoaded;
  late int _isImpLoaded;
  bool _bCheck = false;

  @override
  void initState() {
    super.initState();
    _isWebviewLoaded = 0;
    _isImpLoaded = 0;
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    if (widget.initialChild != null) {
      _isWebviewLoaded++;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_sub != null) _sub!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print(WebView.platform.toString());
    return Scaffold(
      appBar: widget.appBar,
      body: _bCheck ? Text('call') : SafeArea(
        child: IndexedStack(
          index: _isWebviewLoaded,
          children: [
            WebView(
              initialUrl:
              Uri.dataFromString(vfIamportWebView.html, mimeType: 'text/html')
                  .toString(),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                this._webViewController = controller;
                if (widget.type == ActionType.payment) {
                  // 스마일페이, 나이스 실시간 계좌이체
                  _sub = widget.customPGAction(this._webViewController);
                }
              },
              onPageFinished: (String url) {
                // 웹뷰 로딩 완료시에 화면 전환
                if (_isWebviewLoaded == 1) {
                  setState(() {
                    _isWebviewLoaded = 0;
                  });
                }
                // 페이지 로딩 완료시 IMP 코드 실행
                if (_isImpLoaded == 0) {
                  widget.executeJS(this._webViewController);
                  _isImpLoaded++;
                }
              },
              navigationDelegate: (request) async {
                print("url: " + request.url);
                if (widget.isPaymentOver(request.url)) {
                  String decodedUrl = Uri.decodeComponent(request.url);
                  widget.useQueryData(Uri.parse(decodedUrl).queryParameters);

                  return NavigationDecision.prevent;
                }

                final iamportUrl = IamportUrl(request.url);
                if (iamportUrl.isAppLink()) {
                  print("appLink: " + iamportUrl.appUrl!);
                  // 앱 실행 로직을 iamport_url 모듈로 이동
                  iamportUrl.launchApp();
                  return NavigationDecision.prevent;
                }

                if(request.url.substring(0,widget.redirectURL!.length) == widget.redirectURL){

                  var resultToken = request.url.lastIndexOf('=');

                  if((request.url.length - resultToken - 1) == 4){ //success=true
                    var imp_uid_start_token = request.url.lastIndexOf('?') + 1 + 'imp_uid='.length;
                    var imp_uid_end_token = request.url.lastIndexOf('&');

                    var check = await ApiProvider().post('/certifications/check', jsonEncode({
                      "imp_uid" : request.url.substring(imp_uid_start_token,imp_uid_end_token)
                    }));

                    if(widget.redirectPage!.contains('?')){
                      bool emailPage = widget.redirectPage!.substring(widget.redirectPage!.lastIndexOf('?') + 1, widget.redirectPage!.length) == "true" ? true : false;

                      Get.offAndToNamed(widget.redirectPage!, arguments: {"name" : check['name'] , "phone" : check['phone'] , "emailPage" : emailPage});
                    }else{
                      var phoneCheck = await ApiProvider().post('/User/PhoneCheck', jsonEncode({
                        "name" : check['name'],
                        "phoneNumber" : check['phone']
                      }));

                      Get.offAndToNamed(widget.redirectPage!, arguments: {"name" : check['name'] , "phone" : check['phone'] , "bCheckPhoneNumber" : phoneCheck == null ? false : true }, );
                    }
                  }else{  //success=false
                    Get.back();
                  }
                }

                return NavigationDecision.navigate;
              },
            ),
            if (_isWebviewLoaded == 1) widget.initialChild!,
          ],
        ),
      ),
    );
  }
}
