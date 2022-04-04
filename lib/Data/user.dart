import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Network/ApiProvider.dart';


class UserData {
  int userID;
  String email;
  int loginType;
  String nickName;
  String location;
  String si;
  String dong;
  String information;
  String realName;
  String phoneNumber;
  String profileURL;
  int sex;
  String birthday;
  bool marketingAgree;
  String marketingAgreeTime;
  int loginState;
  String createdAt;
  String updatedAt;

  UserData({
    this.userID = nullInt,
    this.email = '',
    this.loginType = nullInt,
    this.nickName = '',
    this.location = '',
    this.si = '',
    this.dong = '',
    this.information = '',
    this.realName = '',
    this.phoneNumber = '',
    this.profileURL = '',
    this.sex = nullInt,
    this.birthday = '',
    this.marketingAgree = false,
    this.marketingAgreeTime = '',
    this.loginState = nullInt,
    this.createdAt = '',
    this.updatedAt = '',
  });



  factory UserData.fromJson(Map<String, dynamic> json) {
    // 주소 행정구역 별로 나누기
    List<String> locationList = [];
    String location = json['Location'] ?? '';
    String si = ''; // 도/특별시/광역시
    String dong = ''; // 읍/면/동

    if(location.isNotEmpty){
      locationList = location.split(' ');

      si = locationList[0];
      dong = locationList[locationList.length - 1];
    }

    int _sex = json['Sex'] == null ? nullInt : json['Sex'] ? 1 : 0;

    return UserData(
      userID: json['UserID'] ?? nullInt,
      email: json['Email'] ?? '',
      loginType: json['LoginType'] ?? nullInt,
      nickName: json['NickName'] ?? '',
      location: json['Location'] ?? '',
      si: si,
      dong: dong,
      information: json['Information'] ?? '',
      realName: json['RealName'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      profileURL: json['ProfileURL'] == null || json['ProfileURL'] == '' ? "" : ApiProvider().getImgUrl + '/ProfilePhotos/' + json['UserID'].toString() + '/' + json['ProfileURL'],
      sex: _sex,
      birthday: json['Birthday'] ?? '',
      marketingAgree: json['MarketingAgree'] ?? false,
      marketingAgreeTime: json['MarketingAgreeTime'] ?? '',
      loginState: json['LoginState'] ?? nullInt,
      createdAt: replaceDate(json['createdAt'] ?? ''),
      updatedAt: replaceDate(json['updatedAt'] ?? ''),
    );
  }

  factory UserData.setData({required UserData oldUser, required UserData newUser}) => UserData(
    userID: newUser.userID == nullInt ? oldUser.userID : newUser.userID,
    email: newUser.email.isEmpty ? oldUser.email : newUser.email,
    loginType: newUser.loginType == nullInt ? oldUser.loginType : newUser.loginType,
    nickName: newUser.nickName.isEmpty ? oldUser.nickName : newUser.nickName,
    location: newUser.location.isEmpty ? oldUser.location : newUser.location,
    information: newUser.information.isEmpty ? oldUser.information : newUser.information,
    realName: newUser.realName.isEmpty ? oldUser.realName : newUser.realName,
    phoneNumber: newUser.phoneNumber.isEmpty ? oldUser.phoneNumber : newUser.phoneNumber,
    profileURL: newUser.profileURL.isEmpty ? oldUser.profileURL : newUser.profileURL,
    sex: newUser.sex == nullInt ? oldUser.sex : newUser.sex,
    birthday: newUser.birthday.isEmpty ? oldUser.birthday : newUser.birthday,
    marketingAgree: oldUser.marketingAgree,
    marketingAgreeTime: newUser.marketingAgreeTime.isEmpty ? oldUser.marketingAgreeTime : newUser.marketingAgreeTime,
    loginState: newUser.loginState == nullInt ? oldUser.loginState : newUser.loginState,
    createdAt: newUser.createdAt.isEmpty ? oldUser.createdAt : newUser.createdAt,
    updatedAt: newUser.updatedAt.isEmpty ? oldUser.updatedAt : newUser.updatedAt,
  );
}