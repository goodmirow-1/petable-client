import 'package:flutter/material.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Notification/controller/notification_database.dart';
import 'package:myvef_app/Notification/model/notification.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:myvef_app/community/model/community.dart';

import '../Data/pet.dart';

class TotalNotificationPage extends StatefulWidget {
  const TotalNotificationPage({Key? key}) : super(key: key);

  @override
  _TotalNotificationPageState createState() => _TotalNotificationPageState();
}

class _TotalNotificationPageState extends State<TotalNotificationPage> {
  final GlobalData globalData = Get.put(GlobalData());
  final NotificationController notificationController = Get.put(NotificationController());
  SlidableController slidableController = SlidableController();
  Animation<double>? _rotationAnimation;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Color _fabColor = Colors.blue;

  List<NotificationModel> unreadList = [];
  List<NotificationModel> todayList = [];
  List<NotificationModel> weekList = [];
  List<NotificationModel> monthList = [];
  List<NotificationModel> prevList = [];

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool? isOpen) {
    setState(() {
      _fabColor = isOpen! ? Colors.green : Colors.blue;
    });
  }


  @override
  void initState() {
    unreadList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.NEW);
    todayList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.TODAY);
    weekList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.WEEK);
    monthList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.MONTH);
    prevList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.PREV);

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      notificationController.readNoti();
    });

    super.initState();
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
            title: '알림',
          ),
          body:
          SingleChildScrollView(
            child: RefreshIndicator(
              key: refreshKey,
              onRefresh: () async {
                unreadList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.NEW);
                todayList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.TODAY);
                weekList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.WEEK);
                monthList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.MONTH);
                prevList = notificationController.splitNotiList(SPLIT_ALARM_ENUM.PREV);

                setState(() {

                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if(unreadList.length != 0) ... [
                    Padding(
                      padding: EdgeInsets.fromLTRB(28 * sizeUnit, 8 * sizeUnit, 0, 0),
                      child: Text(
                        "새로운 알림", style: VfTextStyle.subTitle2(),
                      ),
                    ),
                    SizedBox(height: 8 * sizeUnit,),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 0, 16 * sizeUnit, 0),
                      child: Container(
                        width: 328 * sizeUnit,
                        height: (unreadList.length * 56 * sizeUnit) + (6 * sizeUnit),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(20 * sizeUnit),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              offset: Offset( -1 * sizeUnit, 4 * sizeUnit),
                              blurRadius: 10 * sizeUnit,
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: unreadList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return notificationItem(unreadList[index]);
                            }
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * sizeUnit,),
                  ],
                  buildNotificationList(todayList, '오늘'),
                  buildNotificationList(weekList, '이번 주'),
                  buildNotificationList(monthList, '이번 달'),
                  buildNotificationList(prevList, '이전 알림')
                ],
              ),
            ),
          )
      ),
    );
  }

  Widget buildNotificationList(List<NotificationModel> notiList, String text){
    if(notiList.length == 0) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28 * sizeUnit, 8 * sizeUnit, 0, 0),
          child: Text(
            text, style: VfTextStyle.subTitle2(),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16 * sizeUnit, 0, 16 * sizeUnit, 0),
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: notiList.length,
              itemBuilder: (BuildContext context, int index) {
                return Slidable(
                  key: Key(notiList[index].id.toString()),
                  controller: slidableController,
                  actionPane: SlidableBehindActionPane(),
                  actionExtentRatio: 0.125 * sizeUnit,
                  child: notificationItem(notiList[index]),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                        color: vfColorPink,
                        foregroundColor: Colors.white,
                        icon: Icons.clear,
                        onTap: () async {
                          await NotiDBHelper().deleteData(notiList[index].id);

                          setState(() {
                            notificationController.removeNotification(notiList[index]);
                            notiList.remove(notiList[index]);
                          });
                        }
                    ),
                  ],
                );
              }
          ),
        ),
        SizedBox(height: 24 * sizeUnit,),
      ],
    );
  }

  Widget notificationItem(NotificationModel model){

    UserData? user = globalData.getUser(model.from);

    return Container(
      width: 328 * sizeUnit,
      height: 56 * sizeUnit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if( user == null || user.profileURL == '' ) ... [
            Container(
              width: 72 * sizeUnit,
              child: Center(
                  child: vfGradationIconWidget(iconPath: svgPetPhotoDefault, blendMode: BlendMode.srcOver),
              ),
            )
          ] else ... [
            Container(
              width: 72 * sizeUnit,
              child: Center(
                child: Container(
                  width: 40 * sizeUnit,
                  height: 40 * sizeUnit,
                  child: ClipRRect(
                      borderRadius: new BorderRadius.circular(12 * sizeUnit),
                      child: FittedBox(
                        child: ExtendedImage.network(user.profileURL),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10 * sizeUnit, 0, 0),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    await notificationController.notiClickEvent(model).then((value) => {
                      setState(() {
                      })
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 24 * sizeUnit),
                    child: Container(
                      height: 44 * sizeUnit,
                      width: 232 * sizeUnit,
                      child: Align(alignment: Alignment.topLeft, child: getNotiInfoText(model)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getNotiInfoText(NotificationModel model) {
    return RichText(
        text: TextSpan(children: [
          customTextSpan(model, 0),
          customTextSpan(model, 1),
          customTextSpan(model, 2),
          customTextSpan(model, 3),
          TextSpan(text: "\n" + timeCheck(replaceDate(model.createdAt)), style: VfTextStyle.bWriteDate().copyWith(height: 1.4))
        ]));
  }

  TextSpan customTextSpan(NotificationModel model, int index) {
    String info = '';
    TextStyle style = VfTextStyle.body2();

    UserData? user = globalData.getUser(model.from);

    switch(model.type){
      case NOTI_EVENT_POST_LIKE:
        {
          switch(index){
            case 0:
              {
                info = user!.nickName;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "님이 게시글 ";
              }
              break;
            case 2:
              {
                Community community = GlobalData.communityList.singleWhere((element) => element.id == model.tableIndex);
                info = community.title;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 3:
              {
                info = " 글을 좋아합니다.";
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY:
        {
          switch(index){
            case 0:
              {
                info = user!.nickName;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "님이 게시글 ";
              }
              break;
            case 2:
              {
                Community community = GlobalData.communityList.singleWhere((element) => element.id == model.tableIndex);
                info = community.title;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 3:
              {
                info = " 에 댓글을 달았습니다.";
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_POST_REPLY_REPLY:
        {
          switch(index){
            case 0:
              {
                info = user!.nickName;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "님이 게시글 ";
              }
              break;
            case 2:
              {
                Community community = GlobalData.communityList.singleWhere((element) => element.id == model.tableIndex);
                info = community.title;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 3:
              {
                info = " 에 대댓글을 달았습니다.";
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_NEED_DEVICE_CHECK:
        {
          switch(index){
            case 0:
              {
                Pet pet = GlobalData.petList.singleWhere((element) => element.id == model.tableIndex);

                info = pet.name;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "이/가 사용하는 기기에 문제가 있는거 같습니다. 기기";
              }
              break;
            case 2:
              {
                info = " LED";
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 3:
              {
                info = " 의 상태를 확인해 주세요.";
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_NEED_BATTERY_CHECK:
        {
          switch(index){
            case 0:
              {
                Pet pet = GlobalData.petList.singleWhere((element) => element.id == model.tableIndex);

                info = pet.name;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "이/가 사용하는 기기에 배터리가 얼마 남지 않았습니다. ";
              }
              break;
            case 2:
              {
                info = "원활한 사용을 위해 배터리 교체를 추천드릴게요!";
              }
              break;
            case 3:
              {
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_PET_EAT_DONE:
        {
          switch(index){
            case 0:
              {
                Pet pet = GlobalData.petList.singleWhere((element) => element.id == model.tableIndex);

                info = "'" +  pet.name + "'" ;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                List<String> list = model.subIndex.split('/');
                info = int.parse(list[0]) == 0 ? "이/가 밥 " : "이/가 물 ";
              }
              break;
            case 2:
              {
                List<String> list = model.subIndex.split('/');
                info = list[1];
              }
              break;
            case 3:
              {
                List<String> list = model.subIndex.split('/');
                info = int.parse(list[0]) == 0 ? "g을 먹었어요!" : "ml를 마셨어요!";
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_PET_BOWL_IS_EMPTY:
        {
          switch(index){
            case 0:
              {
                Pet pet = GlobalData.petList.singleWhere((element) => element.id == model.tableIndex);

                info = pet.name;
                style = VfTextStyle.subTitle4().copyWith(fontWeight: FontWeight.bold);
              }
              break;
            case 1:
              {
                info = "이/가 사용하는 그릇이 비었어요";
              }
              break;
            case 2:
              {
              }
              break;
            case 3:
              {
              }
              break;
          }
        }
        break;
      case NOTI_EVENT_TEMP:
        {
          switch(index){
            case 0:
              {
                info = "test알람이야알람이야알람이야알람이야";
                style = VfTextStyle.subTitle4();
              }
              break;
            case 1:
              {
                info = "알람이야";
              }
              break;
            case 2:
              {
                info = "쓰지마";
                style = VfTextStyle.subTitle4();
              }
              break;
            case 3:
              {
                info = "쓰지마";
              }
              break;
          }
        }
        break;
      default: break;
    }

    return TextSpan(text: info, style: style);
  }
}
