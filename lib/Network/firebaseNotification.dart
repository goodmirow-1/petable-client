import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Notification/controller/local_notification_controller.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Notification/model/notification.dart';
import 'package:myvef_app/Notification/notification_page.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'ApiProvider.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

bool isFirebaseCheck = false;
bool isLoadFirebase = false;
bool isRecvData = false;
//Firebase관련 class
class FirebaseNotifications {
  static String _fcmToken = '';

  static bool isEating = false;
  static bool isAnalysis = false;
  static bool isAdvice = false;
  static bool isCommunity = false;
  static bool isMarketing = false;

  String get getFcmToken => _fcmToken;

  final GlobalData globalData = Get.put(GlobalData());
  final LocalNotifcationController localNotifcationController = Get.put(LocalNotifcationController());
  final NotificationController notificationController = Get.put(NotificationController());

  void setFcmToken (String token) {
    _fcmToken = token;
    isFirebaseCheck = false;
  }

  FirebaseNotifications(){
  }

  void setUpFirebase() {
    if(isFirebaseCheck == false){
      isFirebaseCheck = true;
    }else{
      return;
    }

    Future.microtask(() async {
      await FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, provisional: false);

      firebaseCloudMessaging_Listeners();
      return FirebaseMessaging.instance;
    }) .then((_) async{
      if(_fcmToken == ''){
        _fcmToken = (await _.getToken())!;
        var res = await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
          "userID" : GlobalData.loggedInUser.value.userID,
          "token" : _fcmToken,
        }));

        if(res != null){
          FirebaseNotifications.isEating = res['item']['isEating'] == null ? true : res['item']['isEating'];
          FirebaseNotifications.isAnalysis = res['item']['isAnalysis'] == null ? true : res['item']['isAnalysis'];
          FirebaseNotifications.isAdvice = res['item']['isAdvice'] == null ? true : res['item']['isAdvice'];
          FirebaseNotifications.isCommunity = res['item']['isCommunity'] == null ? true : res['item']['isCommunity'];
          FirebaseNotifications.isMarketing = GlobalData.loggedInUser.value.marketingAgree;
        }
      }
      return;
    });
  }

  void firebaseCloudMessaging_Listeners() {

    if(isLoadFirebase == false){
      isLoadFirebase = true;
    }else{
      return;
    }

    FirebaseMessaging.instance.getToken().then((token) {
        debugPrint('firebase getToken func call');
        debugPrint(token);
    });

    FirebaseMessaging.instance.getAPNSToken().then((token) {
      debugPrint('firebase getAPNSToken func call');
      debugPrint(token);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('firebase onTokenRefresh func call');
      debugPrint(token);

      await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
        "userID" : GlobalData.loggedInUser.value.userID,
        "token" : _fcmToken,
      }));
    });

    FirebaseMessaging.instance.getInitialMessage();


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("firebase onMessage Call " + message.data.toString());
      List<String> strList = (message.data['body'] as String).split('|');

      NotificationModel model = NotificationModel(
        id:  int.parse(strList[0]),
        from: int.parse(strList[1]),
        to: int.parse(strList[2]),
        type: strList[3],
        tableIndex: int.parse(strList[4]),
        subIndex: strList[5],
        createdAt: strList[6],
        updatedAt: strList[6]
      );

      if(model.type == NOTI_EVENT_POST_NEW_UPDATE){
        debugPrint(Get.currentRoute);
        if(Get.currentRoute == '/MainPage'){
          CommunityController communityController = Get.find();
          if(communityController.onPage.value){
            communityController.activeNewPost(true);
            communityController.stateUpdate();
          }
        }
      }else{
        await notificationController.addNotification(model);

        globalNotificationType = message.data['screen'];
        String payload = model.tableIndex.toString();

        if(message.data['title'] != null && message.data['notibody'] != null){
          localNotifcationController.showNoti(title: message.data['title'], des: message.data['notibody'], payload: payload);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("firebase onMessageOpenedApp Call");

      if(isRecvData == false){
        isRecvData = true;
      }
      //lifecycle에서 는 데이터를 가져오지 않음.
      Future.microtask(() async {
        await screenControllFunc(message.data);

        FlutterAppBadger.removeBadge();
      });
    });
  }

  Future screenControllFunc(Map<String, dynamic> message) async {
    var screen = 'NOTIFICATION';
    screen = message['screen'] as String;

    NotificationController notificationController = NotificationController.to;
    await notificationController.loadNotificationFutureData();

    List<String> list = (message['body'] as String).split('|');

    NotificationModel notificationModel = NotificationModel(
        id:  int.parse(list[0]),
        from: int.parse(list[1]),
        to: int.parse(list[2]),
        type: list[3],
        tableIndex: int.parse(list[4]),
        subIndex: list[5],
        createdAt: list[6],
        updatedAt: list[6]
    );

    int index = notificationModel.tableIndex;

    debugPrint("_configureSelectNotificationSubject call");

    switch (screen) {
      case "NOTIFICATION":
        {
          Get.to(() => TotalNotificationPage());
        }
        break;
      case "COMMUNITY":
        {
          final CommunityController communityController = CommunityController.to;
          Community community = GlobalData.communityList.singleWhere((element) => element.id == index);

          bool isDeleted = await communityController.setCommunityDetailData(index); // 커뮤니티 디테일 데이터 세팅

          // 삭제된 글이면
          if(isDeleted) {
            syncCommunityDelete(community.id); // 커뮤니티 리스트에서 삭제

            Fluttertoast.showToast(
              msg: '삭제된 게시글입니다.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
              textColor: Colors.white,
            );
            return;
          }

          bool isSubscribe = await communityController.subscribeCheck(index); // 구독 체크
          communityController.offActive(); // 액티브 끄기
          communityController.detailCommunity = community;
          Get.to(() => CommunityReplyPage(isSubscribe: isSubscribe))!.then((value) {});
        }
        break;
    }
  }

  showNotification(Map<String, dynamic> msg){
  }

  void SetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  void SetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static void setSubScriptionToTopicClear(){

  }

  static void globalSetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void globalSetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}