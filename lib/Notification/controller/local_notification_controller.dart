import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/main_page.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Notification/notification_page.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Home/Controller/navigation_controller.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String globalNotificationType = 'NOTIFICATION';

class LocalNotifcationController extends GetxController {
  static get to => Get.find<LocalNotifcationController>();
  final NavigationController navController = Get.put(NavigationController());

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
  late String selectedNotificationPayload;

  late NotificationDetails platformChannelSpecifics;
  bool hasCheck = false;

  Future<bool> init() async {
    if (hasCheck == true) return hasCheck;

    var initializationSettingsAndroid = AndroidInitializationSettings('noti_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (int? id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id!, title: title!, body: body!, payload: payload!));
        });

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
      selectedNotificationPayload = payload!;
      selectNotificationSubject.add(payload);
    });

    _configureSelectNotificationSubject();

    hasCheck = true;
    return hasCheck;
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      NotificationController notificationController = NotificationController.to;
      await notificationController.loadNotificationFutureData();

      int index = int.parse(payload);

      debugPrint("_configureSelectNotificationSubject call");

      switch (globalNotificationType) {
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
        case "BOWL":
          {
            navController.changeNavIndex(3);
          }
          break;
      }
    });
  }

  Future<bool> showNoti({String title = "welcome", String des = "JamesFlutter", String payload = ''}) async {
    if (!hasCheck) await init();
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    await flutterLocalNotificationsPlugin.show(0, title, des, platformChannelSpecifics, payload: payload);

    return true;
  }

  showTime() async {
    if (!hasCheck) await init();
    var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      channelDescription: 'your other channel description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, 'scheduled title', 'scheduled body', scheduledNotificationDateTime, platformChannelSpecifics);
  }

  showInterval() async {
    if (!hasCheck) await init();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeating channel id',
      'repeating channel name',
      channelDescription: 'repeating description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title', 'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics);
  }

  everyDayTime() async {
    if (!hasCheck) await init();
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      channelDescription: 'repeatDailyAtTime description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'show daily title', 'Daily notification shown at approximately ${time.hour}:${time.minute}:${time.second}', time, platformChannelSpecifics);
  }

  weeklyTargetDayTimeInterval() async {
    if (!hasCheck) await init();
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      channelDescription: 'show weekly description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  }

  Future<void> targetNotiCancel({required int targetIndex}) async => await flutterLocalNotificationsPlugin.cancel(targetIndex);

  Future<void> allNotiCancel() async => await flutterLocalNotificationsPlugin.cancelAll();
}
