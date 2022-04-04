import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Network/firebaseNotification.dart';
import '../Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';

class AlarmSetting extends StatefulWidget {
  const AlarmSetting({Key? key}) : super(key: key);

  @override
  _AlarmSettingState createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {


  void _sendDetailAlarmSettingData(){
    ApiProvider().post('/Fcm/DetailAlarmSetting',jsonEncode({
          'userID' : GlobalData.loggedInUser.value.userID,
          'eating': FirebaseNotifications.isEating,
          'analysis': FirebaseNotifications.isAnalysis,
          'advice': FirebaseNotifications.isAdvice,
          'community': FirebaseNotifications.isCommunity,
          'marketing': FirebaseNotifications.isMarketing,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 2,
      colorType: vfGradationColorType.Pink,
      child: Scaffold(
        appBar: vfAppBar(
          context,
          title: '푸시 알림 설정',
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 6 * sizeUnit, 16 * sizeUnit, 0 * sizeUnit),
          child: Column(
            children: [
              buildAlarmColumn( '섭취 알림', "MyBowl에 그릇이 비었을 때 알려드려요.", FirebaseNotifications.isEating, (value) => {
                setState(() {
                  FirebaseNotifications.isEating = value;
                }),
                _sendDetailAlarmSettingData()
              }),
              // buildAlarmColumn( '분석된 데이터 알림', "분석된 데이터가 오면 바로 알려드려요!", FirebaseNotifications.isAnalysis, (value) => {
              //   setState(() {
              //     FirebaseNotifications.isAnalysis = value;
              //   }),
              //   _sendDetailAlarmSettingData()
              // }),
              // buildAlarmColumn( '수의사 한마디알림', "수의사 한마디가 도착하면 바로 알려드려요!", FirebaseNotifications.isAdvice, (value) => {
              //   setState(() {
              //     FirebaseNotifications.isAdvice = value;
              //   }),
              //   _sendDetailAlarmSettingData()
              // }),
              buildAlarmColumn( '내 게시글 댓글, 좋아요 알림', "내가 쓴 글에 대한 댓글과 답글, 좋아요가 푸시됩니다.", FirebaseNotifications.isCommunity, (value) => {
                setState(() {
                  FirebaseNotifications.isCommunity = value;
                }),
                _sendDetailAlarmSettingData()
              }),
              buildAlarmColumn( '마케팅 알림', "중요한 이벤트와 혜택을 놓치지 않도록, 동의해 주세요!", FirebaseNotifications.isMarketing, (value) => {
                setState(() {
                  FirebaseNotifications.isMarketing = value;
                }),
                _sendDetailAlarmSettingData()
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAlarmColumn(String main, String sub, bool value, Function func){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(main, style: VfTextStyle.body1()),
                SizedBox(height: 2*sizeUnit),
                Text(sub, style: VfTextStyle.body3()),
              ],
            ),
            CupertinoSwitch(
              value: value,
              onChanged: (value) => func(value),
              activeColor: vfColorPink,
              trackColor: vfColorGrey,
              thumbColor: Colors.white.withOpacity(0.8),
            ),
          ],
        ),

        SizedBox(height: 14*sizeUnit),
      ],
    );
  }
}
