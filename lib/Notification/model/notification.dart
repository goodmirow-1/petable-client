
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

class NotificationModel {
  int id;
  int to;
  int from;
  String type;
  int tableIndex;
  String subIndex;
  bool isSend;
  bool isRead;
  bool isLoad;
  String createdAt;
  String updatedAt;

  NotificationModel({
    this.id = nullInt,
    this.to = nullInt,
    this.from = nullInt,
    this.type = '',
    this.tableIndex = nullInt,
    this.subIndex = '',
    this.isSend = false,
    this.isRead = false,
    this.isLoad = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id : json['id'] ?? nullInt,
      to : json['TargetID'] ?? nullInt,
      from: json['UserID'] ?? nullInt,
      type: json['Type'] ?? '',
      tableIndex: json['TableIndex'] ?? nullInt,
      subIndex: json['SubIndex'] ?? '',
      isSend: json['IsSend'] ?? false,
      isRead: false,
      isLoad: false,
      createdAt: replaceDateToDateTime(json['createdAt'] ?? ''),
      updatedAt: replaceDateToDateTime(json['updatedAt'] ?? '')
    );
  }
}