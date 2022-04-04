import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Home/Controller/dash_board_controller.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/Notification/controller/local_notification_controller.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(NavigationController());
    Get.put<NotificationController>(NotificationController());
    Get.put<LocalNotifcationController>(LocalNotifcationController());
    Get.put<DashBoardController>(DashBoardController());
    Get.put<GraphPageController>(GraphPageController());
    Get.put<CommunityController>(CommunityController());
    Get.put<FilterController>(FilterController());
    Get.put<LoginController>(LoginController());
  }
}