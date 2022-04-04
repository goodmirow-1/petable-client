import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/user.dart';
import 'package:myvef_app/Network/ApiProvider.dart';

const int COMMUNITY_TYPE_NORMAL = 0; // 기본
const int COMMUNITY_TYPE_POPULAR = 1; // 인기

const int COMMUNITY_POST_TYPE_POST = 0; // 커뮤니티글
const int COMMUNITY_POST_TYPE_REPLY = 1; // 댓글
const int COMMUNITY_POST_TYPE_REPLY_REPLY = 2; // 답글

const int BLIND_COUNT = 5; // 블라인드 되는 수

class Community {
  int id;
  int userId;
  String nickName;
  String profileURL;
  String category;
  String kind;
  String location;
  String title;
  String contents;
  String imageUrl1;
  String imageUrl2;
  String imageUrl3;
  List<String> imgUrlList;
  String petType;
  int isShow;
  int type;
  int point;
  String registerTime;
  String createdAt;
  String updatedAt;
  List<CommunityPostLike> communityPostLikes;
  List<CommunityPostReply> communityPostReplies;
  int declareLength;
  int likePressingCount;
  bool isBlind;

  Community({
    this.id = nullInt,
    this.userId = nullInt,
    this.nickName = '',
    this.profileURL = '',
    this.category = '',
    this.kind = '',
    this.location = '',
    this.title = '',
    this.contents = '',
    this.imageUrl1 = '',
    this.imageUrl2 = '',
    this.imageUrl3 = '',
    this.imgUrlList = const [],
    this.petType = '',
    this.isShow = nullInt,
    this.type = nullInt,
    this.point = nullInt,
    this.registerTime = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.communityPostLikes = const [],
    this.communityPostReplies = const [],
    this.declareLength = nullInt,
    this.likePressingCount = 0,
    this.isBlind = false
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    List<CommunityPostLike> likeList = json['community']['CommunityPostLikes'] == null ? [] : (json['community']['CommunityPostLikes'] as List).map((e) => CommunityPostLike.fromJson(e)).toList();

    return Community(
      id: json['community']["id"] ?? nullInt,
      userId: json['community']['UserID'] ?? nullInt,
      nickName: json['nickName'] ?? '',
      profileURL: json['profileURL'] == null || json['profileURL'] == '' ? "" : ApiProvider().getImgUrl + '/ProfilePhotos/' + json['userID'].toString() + '/' + json['profileURL'],
      category: json['community']["Category"] ?? '',
      kind: json['community']["Kind"] ?? '',
      location: json['community']["Location"] ?? '',
      title: json['community']["Title"] ?? '',
      contents: json['community']["Contents"] ?? '',
      imageUrl1: json['community']["ImageURL1"] == null || json['community']["ImageURL1"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL1"],
      imageUrl2: json['community']["ImageURL2"] == null || json['community']["ImageURL2"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL2"],
      imageUrl3: json['community']["ImageURL3"] == null || json['community']["ImageURL3"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL3"],

      // 이미지 파일 리스트에 저장
      imgUrlList: [
        json['community']["ImageURL1"] == null || json['community']["ImageURL1"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL1"],
        json['community']["ImageURL2"] == null || json['community']["ImageURL2"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL2"],
        json['community']["ImageURL3"] == null || json['community']["ImageURL3"] == '' ? '' : ApiProvider().getImgUrl + '/CommunityPhotos/' + json['community']["id"].toString() + '/' + json['community']["ImageURL3"],
      ].where((element) => element.isNotEmpty).toList().cast<String>(),

      petType: json['community']["PetType"] ?? '',
      isShow: json['community']["IsShow"] == null ? nullInt : json['community']['IsShow'] ? 1 : 0,
      type: json['community']["Type"] ?? nullInt,
      point: json['community']["Point"] ?? nullInt,
      registerTime: replaceDate(json['community']['RegisterTime'] ?? ''),
      createdAt: replaceDateToDateTime(json['community']['createdAt'] ?? ''),
      updatedAt: replaceDateToDateTime(json['community']['updatedAt'] ?? ''),
      communityPostLikes: likeList,
      communityPostReplies: json['community']['CommunityPostReplies'] == null ? [] : (json['community']['CommunityPostReplies'] as List).map((e) => CommunityPostReply.fromJson(e)).toList(),
      declareLength: json['declareLength'] ?? 0,
      isBlind: communityPostBlindCheck(declareLength: json['declareLength'] ?? 0, likeLength: likeList.length),
    );
  }
}

// 커뮤니티 좋아요
class CommunityPostLike {
  int id;
  int userId;
  int postId;
  String createdAt;
  String updatedAt;

  CommunityPostLike({
    this.id = nullInt,
    this.userId = nullInt,
    this.postId = nullInt,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory CommunityPostLike.fromJson(Map<String, dynamic> json) => CommunityPostLike(
    id: json["id"],
    userId: json["UserID"],
    postId: json["PostID"],
    createdAt: replaceDate(json['createdAt'] ?? ''),
    updatedAt: replaceDate(json['updatedAt'] ?? ''),
  );
}

// 커뮤니티 댓글
class CommunityPostReply {
  int id;
  int userId;
  int postId;
  String contents;
  int isShow;
  List<CommunityPostReplyReply> communityReplyReplies;
  String createdAt;
  String updatedAt;
  int declareLength;
  bool isBlind;

  CommunityPostReply({
    this.id = nullInt,
    this.userId = nullInt,
    this.postId = nullInt,
    this.contents = '',
    this.isShow = nullInt,
    this.communityReplyReplies = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.declareLength = nullInt,
    this.isBlind = false,
  });

  factory CommunityPostReply.fromJson(Map<String, dynamic> json) => CommunityPostReply(
    id: json["id"],
    userId: json["UserID"],
    postId: json["PostID"],
    contents: json["Contents"],
    isShow: json["IsShow"] == null ? nullInt : json['IsShow'] ? 1 : 0,
    communityReplyReplies: json['CommunityPostReplyReplies'] == null ? [] : (json['CommunityPostReplyReplies'] as List).map((e) => CommunityPostReplyReply.fromJson(e)).toList(),
    createdAt: replaceDateToDateTime(json['createdAt'] ?? ''),
    updatedAt: replaceDateToDateTime(json['updatedAt'] ?? ''),
    declareLength: json['CommunityPostReplyDeclares'] == null ? 0 : (json['CommunityPostReplyDeclares'] as List).length,
    isBlind: replyBlindCheck((json['CommunityPostReplyDeclares'] == null ? 0 : (json['CommunityPostReplyDeclares'] as List).length)),
  );
}

// 커뮤니티 답글
class CommunityPostReplyReply {
  int id;
  int userId;
  int replyId;
  String contents;
  int isShow;
  String createdAt;
  String updatedAt;
  int declareLength;
  bool isBlind;

  CommunityPostReplyReply({
    this.id = nullInt,
    this.userId = nullInt,
    this.replyId = nullInt,
    this.contents = '',
    this.isShow = nullInt,
    this.createdAt = '',
    this.updatedAt = '',
    this.declareLength = nullInt,
    this.isBlind = false,
  });

  factory CommunityPostReplyReply.fromJson(Map<String, dynamic> json) => CommunityPostReplyReply(
    id: json["id"],
    userId: json["UserID"],
    replyId: json["ReplyID"],
    contents: json["Contents"],
    isShow: json["IsShow"] == null ? nullInt : json['IsShow'] ? 1 : 0,
    createdAt: replaceDateToDateTime(json['createdAt'] ?? ''),
    updatedAt: replaceDateToDateTime(json['updatedAt'] ?? ''),
    declareLength: json['CommunityPostReplyReplyDeclares'] == null ? 0 : (json['CommunityPostReplyReplyDeclares'] as List).length,
    isBlind: replyBlindCheck(json['CommunityPostReplyReplyDeclares'] == null ? 0 : (json['CommunityPostReplyReplyDeclares'] as List).length),
  );
}

// 좋아요 동기화
void syncLikeOnInsert(int communityID, CommunityPostLike communityPostLike){
  void insertLike(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == communityID && !communityList[i].communityPostLikes.contains(communityPostLike)){
        communityList[i].communityPostLikes.add(communityPostLike);
        break;
      }
    }
  }

  insertLike(GlobalData.communityList); // 전체
  insertLike(GlobalData.popularCommunityList); // 인기
  insertLike(GlobalData.filteredCommunityList); // 필터 전체
  insertLike(GlobalData.filteredPopularCommunityList); // 필터 인기
  insertLike(GlobalData.myCommunityList); // 마이
  insertLike(GlobalData.searchedCommunityList); // 검색
  insertLike(GlobalData.profileCommunityList); // 프로필
}

// 좋아요 취소 동기화
void syncLikeOnRemove(int communityID){
  void removeLike(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == communityID){
        communityList[i].communityPostLikes.removeWhere((element) => element.userId == GlobalData.loggedInUser.value.userID);
        break;
      }
    }
  }

  removeLike(GlobalData.communityList); // 전체
  removeLike(GlobalData.popularCommunityList); // 인기
  removeLike(GlobalData.filteredCommunityList); // 필터 전체
  removeLike(GlobalData.filteredPopularCommunityList); // 필터 인기
  removeLike(GlobalData.myCommunityList); // 마이
  removeLike(GlobalData.searchedCommunityList); // 검색
  removeLike(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 리스트 동기화 (수정할때 씀)
void syncCommunityList(Community community){
  communityPostSetUserData(community); // 유저 데이터 세팅

  void sync(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == community.id) {
        communityList[i] = community;
        break;
      }
    }
  }

  sync(GlobalData.communityList); // 전체
  sync(GlobalData.popularCommunityList); // 인기
  sync(GlobalData.filteredCommunityList); // 필터 전체
  sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  sync(GlobalData.myCommunityList); // 마이
  sync(GlobalData.searchedCommunityList); // 검색
  sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 글 유저 데이터 세팅
void communityPostSetUserData(Community community){
  community.nickName = GlobalData.loggedInUser.value.nickName; // 유저 닉네임
  community.profileURL = GlobalData.loggedInUser.value.profileURL; // 유저 프로필 이미지
}

// 커뮤니티 삭제 동기화
void syncCommunityDelete(int communityID){
  void sync(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == communityID) {
        communityList.removeAt(i);
        break;
      }
    }
  }

  sync(GlobalData.communityList); // 전체
  sync(GlobalData.popularCommunityList); // 인기
  sync(GlobalData.filteredCommunityList); // 필터 전체
  sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  sync(GlobalData.myCommunityList); // 마이
  sync(GlobalData.searchedCommunityList); // 검색
  sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 댓글 데이터 동기화
void syncCommunityReplyData(int communityID, List<CommunityPostReply> replyList){
  void sync(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == communityID) {
        communityList[i].communityPostReplies = replyList;
        break;
      }
    }
  }

  sync(GlobalData.communityList); // 전체
  sync(GlobalData.popularCommunityList); // 인기
  sync(GlobalData.filteredCommunityList); // 필터 전체
  sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  sync(GlobalData.myCommunityList); // 마이
  sync(GlobalData.searchedCommunityList); // 검색
  sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 댓글 삽입 동기화
void syncAddCommunityReply(int communityID, CommunityPostReply reply){
  void sync(List<Community> communityList) {
    for (int i = 0; i < communityList.length; i++) {
      if (communityList[i].id == communityID) {
        if(!communityList[i].communityPostReplies.contains(reply)){
          communityList[i].communityPostReplies.add(reply);
          break;
        }
      }
    }
  }

  sync(GlobalData.communityList); // 전체
  sync(GlobalData.popularCommunityList); // 인기
  sync(GlobalData.filteredCommunityList); // 필터 전체
  sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  sync(GlobalData.myCommunityList); // 마이
  sync(GlobalData.searchedCommunityList); // 검색
  sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 댓글 삭제 동기화
void syncCommunityReplyDelete(int communityID, int replyID){
  void sync(List<Community> communityList){
    for(int i = 0; i < communityList.length; i++){
      if(communityList[i].id == communityID) {
        for(int j = 0; j < communityList[i].communityPostReplies.length; j++){
          if(communityList[i].communityPostReplies[j].id == replyID) {
            communityList[i].communityPostReplies[j].isShow = 0;
            break;
          }
        }
        break;
      }
    }
  }

  sync(GlobalData.communityList); // 전체
  sync(GlobalData.popularCommunityList); // 인기
  sync(GlobalData.filteredCommunityList); // 필터 전체
  sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  sync(GlobalData.myCommunityList); // 마이
  sync(GlobalData.searchedCommunityList); // 검색
  sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 유저 데이터 동기화
void syncCommunityUserData(UserData userData){
  void _sync(List<Community> communityList){
    communityList.forEach((element) {
      if(element.userId == userData.userID) {
        element.nickName = userData.nickName;
        element.profileURL = userData.profileURL;
        element.location = userData.location;
      }
    });
  }

  _sync(GlobalData.communityList); // 전체
  _sync(GlobalData.popularCommunityList); // 인기
  _sync(GlobalData.filteredCommunityList); // 필터 전체
  _sync(GlobalData.filteredPopularCommunityList); // 필터 인기
  _sync(GlobalData.myCommunityList); // 마이
  _sync(GlobalData.searchedCommunityList); // 검색
  _sync(GlobalData.profileCommunityList); // 프로필
}

// 커뮤니티 블라인드 체크
bool communityPostBlindCheck({required int declareLength, required int likeLength}){
  bool isBlind = false;

  if (declareLength >= BLIND_COUNT && declareLength > likeLength) isBlind = true;

  return isBlind;
}

// 커뮤니티 댓글, 답글 블라인드 체크
bool replyBlindCheck(int declareLength){
  bool isBlind = false;

  if(declareLength >= BLIND_COUNT) isBlind = true;

  return isBlind;
}