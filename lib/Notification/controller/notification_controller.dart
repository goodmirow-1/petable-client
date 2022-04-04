import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Notification/controller/notification_database.dart';
import 'package:myvef_app/Notification/model/notification.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/model/community.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Home/Controller/navigation_controller.dart';
import '../../Home/main_page.dart';

enum SPLIT_ALARM_ENUM{ NEW, TODAY, WEEK, MONTH, PREV}

const String NOTI_EVENT_TEMP = 'TEMP';
const String NOTI_EVENT_POST_LIKE = 'POST_LIKE';
const String NOTI_EVENT_POST_REPLY = 'POST_REPLY';
const String NOTI_EVENT_POST_REPLY_REPLY = 'POST_REPLY_REPLY';
const String NOTI_EVENT_POST_NEW_UPDATE = 'POST_NEW_UPDATE';
const String NOTI_EVENT_NEED_DEVICE_CHECK = 'NEED_DEVICE_CHECK';
const String NOTI_EVENT_NEED_BATTERY_CHECK = 'NEED_BATTERY_CHECK';
const String NOTI_EVENT_PET_EAT_DONE = "PET_EAT_DONE";
const String NOTI_EVENT_PET_BOWL_IS_EMPTY = "PET_BOWL_IS_EMPTY";

class NotificationController extends GetxController{
  static get to => Get.find<NotificationController>();

  static RxList<NotificationModel> notiList = <NotificationModel>[].obs;
  RxBool showRedDot = false.obs;

  final GlobalData globalData = Get.put(GlobalData());
  final NavigationController navController = Get.put(NavigationController());

  addNotification(NotificationModel model) async {
    model.id  = await NotiDBHelper().createData(model);
    notiList.insert(0, model);

    showRedDot.value = true;
  }

  getNotification(int id){
    return notiList.singleWhere((element) => element.id == id);
  }

  removeNotification(NotificationModel model){
    notiList.remove(model);
  }

  Future<void> notiClickEvent(NotificationModel model) async {
    switch(model.type){
      case NOTI_EVENT_POST_LIKE :
      case NOTI_EVENT_POST_REPLY :
      case NOTI_EVENT_POST_REPLY_REPLY:
        {
          final CommunityController communityController = CommunityController.to;
          Community community = GlobalData.communityList.singleWhere((element) => element.id == model.tableIndex);

          bool isDeleted = await communityController.setCommunityDetailData(model.tableIndex); // 커뮤니티 디테일 데이터 세팅

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

          bool isSubscribe = await communityController.subscribeCheck(model.tableIndex); // 구독 체크
          communityController.offActive(); // 액티브 끄기
          communityController.detailCommunity = community;
          Get.to(() => CommunityReplyPage(isSubscribe: isSubscribe))!.then((value) {
          });
        }
        break;
      case NOTI_EVENT_PET_EAT_DONE:
      case NOTI_EVENT_PET_BOWL_IS_EMPTY:
        {
          navController.changeNavIndex(3);
        }
        break;
      case NOTI_EVENT_NEED_DEVICE_CHECK:
      case NOTI_EVENT_NEED_BATTERY_CHECK:
        {
        }
        break;
      default :
        {

        }
        break;
    }
  }

  readNoti(){
    notiList.forEach((element) {
      if(element.isRead == false){
        element.isRead = true;
        NotiDBHelper().readNoti(element.id, 1);
      }
    });

    showRedDot.value = false;
  }

  Future setNotificationListByEvent() async {
    var notiListGet = await ApiProvider().post(
        '/Notification/UnSendSelect',
        jsonEncode({
          "userID": GlobalData.loggedInUser.value.userID,
        }));

    if (null != notiListGet) {
      for (int i = 0; i < notiListGet.length; ++i) {
        NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
        if(noti.type != NOTI_EVENT_POST_NEW_UPDATE){
          noti.id = await NotiDBHelper().createData(noti);
          if(noti.id != 0){
            notiList.insert(0, noti);
          }
        }
      }
    }
  }

  Future setNeedRegistryNotification() async {
    for(var element in GlobalData.petList){
      var intakeInfoRes = await ApiProvider().post(
          '/Bowl/Check/IntakeInfo',
          jsonEncode({
            "petID" : element.id,
          }));

      //기기 연결 알림 등록
      if(intakeInfoRes){
        NotificationModel intakeInfoNotification = NotificationModel(
          type: NOTI_EVENT_NEED_DEVICE_CHECK,
          from: nullInt,
          updatedAt: replaceDate(DateTime.now().toString()),
          createdAt: DateTime.now().toString(),
          tableIndex: element.id,
        );
        intakeInfoNotification.isRead = false;
        intakeInfoNotification.isSend = false;
        intakeInfoNotification.isLoad = true;

        notiList.insert(0, intakeInfoNotification);
      }

      //배터리 부족 알림 등록
      if((element.foodBowl != null && element.foodBowl!.battery != nullInt && element.foodBowl!.battery <= 1 )|| (element.waterBowl != null && element.waterBowl!.battery != nullInt) && element.waterBowl!.battery <= 1){
        NotificationModel batteryNotification = NotificationModel(
          type: NOTI_EVENT_NEED_BATTERY_CHECK,
          from: nullInt,
          updatedAt: replaceDate(DateTime.now().toString()),
          createdAt: DateTime.now().toString(),
          tableIndex: element.id,
        );
        batteryNotification.isRead = false;
        batteryNotification.isSend = false;
        batteryNotification.isLoad = true;

        notiList.insert(0,batteryNotification);
      }
    }
  }

  void setShowRedDot() {
    notiList.forEach((element) {
      if(element.isRead == false){
        showRedDot.value = true;
        return;
      }
    });
  }

  //로컬에서 알림 추가할 때
  addLocalNotification(String type, String createTime) {
    NotificationModel notification = NotificationModel(
      type: type,
      from: nullInt,
      updatedAt: replaceDate(DateTime.now().toString()),
      createdAt: createTime,
    );
    notification.isRead = false;
    notification.isSend = false;
    notification.isLoad = true;

    notiList.add(notification);
  }

  makeTempNotiList(){
    addLocalNotification(NOTI_EVENT_TEMP, DateTime.now().toString());

    addLocalNotification(NOTI_EVENT_TEMP, '2022-02-22 19:18:59.820443');
    addLocalNotification(NOTI_EVENT_TEMP, '2022-02-02 19:18:59.820443');

    addLocalNotification(NOTI_EVENT_TEMP, '2022-01-01 19:18:59.820443');
    addLocalNotification(NOTI_EVENT_TEMP, '2021-12-31 19:18:59.820443');

    addLocalNotification(NOTI_EVENT_TEMP, '2021-11-07 19:18:59.820443');
    addLocalNotification(NOTI_EVENT_TEMP, '2021-08-07 19:18:59.820443');
  }

  List<NotificationModel> splitNotiList(SPLIT_ALARM_ENUM alarmEnum){
    return notiList.where((e) {
      bool check = false;
      DateTime createTime = DateTime.parse(e.createdAt);
      switch(alarmEnum){
        case SPLIT_ALARM_ENUM.NEW :
          {
            if(e.isRead == false) check = true;
          }
        break;
        case  SPLIT_ALARM_ENUM.TODAY : //오늘
          {
            if(e.isRead == false) check = false;
            else if(createTime.day == DateTime.now().day) check = true;
          }
          break;
        case SPLIT_ALARM_ENUM.WEEK : //이번주
          {
            if(e.isRead == false) {
              check = false;
              break;
            }

            int diffDays = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day).difference(
                DateTime(
                    createTime.year,
                    createTime.month,
                    createTime.day)
            ).inDays;

            if(createTime.day != DateTime.now().day && diffDays <= 7) check = true;
          }
          break;
        case SPLIT_ALARM_ENUM.MONTH : //이번달
          {
            if(e.isRead == false) {
              check = false;
              break;
            }

            int diffDays = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day).difference(
                DateTime(
                    createTime.year,
                    createTime.month,
                    createTime.day)
            ).inDays;

            if(createTime.day != DateTime.now().day &&
                diffDays > 7 &&
                createTime.month == DateTime.now().month
            )
              check = true;
          }
          break;
        case SPLIT_ALARM_ENUM.PREV : //이전알림
          {
            if(e.isRead == false) {
              check = false;
              break;
            }

            int diffDays = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day).difference(
                DateTime(
                    createTime.year,
                    createTime.month,
                    createTime.day)
            ).inDays;

            if(createTime.day != DateTime.now().day &&
                diffDays > 7 &&
              createTime.month != DateTime.now().month
            )
              check = true;
          }
          break;
      }

      return check;
    }).toList();
  }

  Future<bool> loadNotificationFutureData() async {

    int i = 0 ;
    while( i < notiList.length ){
      if (notiList[i].isLoad == true){
        i++;
        continue;
      }

      NotificationModel notificationModel = notiList[i];

      if(notificationModel.to != GlobalData.loggedInUser.value.userID){
        await globalData.getFutureUser(notificationModel.to);
      }

      if(notificationModel.from != GlobalData.loggedInUser.value.userID){
        await globalData.getFutureUser(notificationModel.from);
      }

      //관리자 계정
      if(GlobalData.loggedInUser.value.userID == 1){
        await globalData.getFutureUser(notificationModel.from);
      }

      switch(notiList[i].type){
        case NOTI_EVENT_POST_LIKE:
        case NOTI_EVENT_POST_REPLY:
        case NOTI_EVENT_POST_REPLY_REPLY:
          {
            Community community = await GlobalData().getFutureCommunity(notificationModel.tableIndex);
            if(community.id == nullInt){
              NotiDBHelper().deleteData(notiList[i].id);
              notiList.removeAt(i);
              continue;
            }
          }
          break;
      }

      notiList[i].isLoad = true;
      i++;
    }

    return Future.value(true);
  }
}