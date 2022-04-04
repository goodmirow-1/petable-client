import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:myvef_app/Config/GlobalWidget/edit_image_page.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/community/community_reply_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/controller/filter_controller.dart';
import 'package:myvef_app/community/model/community.dart';

class CommunityWriteOrModifyController extends GetxController {
  static get to => Get.find<CommunityWriteOrModifyController>();

  final int TITLE_MIN_NUM = 2; // 제목 최대 갯수
  final int CONTENTS_MIN_NUM = 3; // 내용 최대 갯수
  final int IMAGE_MAX_NUM = 3; // 사진 최대 갯수

  List<String> categoryList = []; // 글쓰기 주제 리스트

  RxList<String> selectedPetKindList = <String>[].obs; // 선택 된 펫 리스트
  RxBool isOkForWrite = false.obs; // 작성 완료 가능 여부
  RxBool isOkForModify = true.obs; // 작성 완료 가능 여부

  Rx<String> category = ''.obs; // 주제
  String petKind = ''; // 품종
  RxString title = ''.obs; // 제목
  RxString contents = ''.obs; // 내용
  String petType = ''; // 펫 종류

  List tmpImageList = [].obs; // 임시 사진 리스트
  RxList imageList = [].obs; // 사진 리스트
  List imageFileList = []; // 이미지 파일 리스트
  List<int> removeIndexList = []; // 삭제된 이미지 리스트
  List<String> imageUrlList = []; // 유지되는 이미지 리스트

  int titleMaxLength = 20; // 제목 최대 글자 수
  int contentsMaxLength = 500; // 제목 최대 글자 수

  var selectedImage; // 선택된 이미지

  // 글쓰기 or 수정하기 함수
  Future<void> communityWriteOrModify({required bool isWrite, required Community community}) async {
    vfLoadingDialog(); // 로딩 다이어로그

    if (isWrite) {
      petKind = makeKindWord(selectedPetKindList); // 품종 단어 만들기
      petType = makePetTypeWord(); // 펫 타입 단어 만들기
    } else {
      petKind = community.kind;
      petType = community.petType;
    }

    await setImageList(); // 이미지 리스트 가공

    FormData formData = FormData.fromMap({
      'isCreate': isWrite ? 1 : 0,
      'id': community.id,
      'userID': GlobalData.loggedInUser.value.userID,
      'category': category.value,
      'kind': petKind,
      'location': GlobalData.loggedInUser.value.location,
      'title': controlSpace(title.value),
      'contents': controlSpace(contents.value),
      'petType': petType,
      'images': imageFileList, // 추가되는 이미지 파일
      'removeindexlist': removeIndexList, // 삭제되는 이미지 인덱스
      'imageurllist': imageUrlList, // 유지되는 이미지 url
      'accessToken' : GlobalData.accessToken,
    });

    try {
      final FilterController filterController = Get.find<FilterController>();

      Dio dio = Dio();
      var res = await dio.post(ApiProvider().getUrl + '/CommunityPost/InsertOrModify', data: formData);

      Community resCommunity = Community.fromJson(json.decode(res.toString()));

      if (isWrite) {
        CommunityController communityController = Get.find<CommunityController>();

        communityPostSetUserData(resCommunity); // 유저 데이터 세팅
        GlobalData.communityList.insert(0, resCommunity); // 글로벌 리스트에 넣어주기

        // 필터가 켜져있을 때 필터에 적용되는지 확인 후 insert
        if (filterController.isFiltered.value) {
          filterController.filterCheckForCommunityWrite(
            category: category.value,
            kind: petKind,
            location: GlobalData.loggedInUser.value.location,
            community: resCommunity,
          );
        }

        // 1초뒤 로딩 끄기
        await Future.delayed(Duration(seconds: 1), () {
          Get.back();
        });

        Get.back(); // 글쓰기 페이지 나가기
        communityController.detailCommunity = resCommunity;
        Get.to(() => CommunityReplyPage(isSubscribe: true))!.then((value) => communityController.stateUpdate());
      } else {
        syncCommunityList(resCommunity); // 커뮤니티 리스트 동기화

        resCommunity.communityPostReplies = CommunityController.to.detailCommunity.communityPostReplies; // resCommunity에 댓글 정보 저장
        CommunityController.to.detailCommunity = resCommunity; // 댓글 페이지 커뮤니티에 수정된거 적용

        // 1초뒤 로딩 끄기
        await Future.delayed(Duration(seconds: 1), () {
          Get.back();
        });

        Get.back();
        Fluttertoast.showToast(
            msg: '수정이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: Colors.white);
      }
    } on DioError catch (e) {
      Get.back();
      Fluttertoast.showToast(
          msg: '파일 전송에 실패했습니다. 다시 시도해주세요.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white);
      throw (e.message);
    }
  }

  // 이미지 리스트 가공
  Future<void> setImageList() async {
    imageFileList.clear();
    imageUrlList.clear();

    for (int i = 0; i < imageList.length; i++) {
      if (imageList[i] is XFile) {
        var file = await MultipartFile.fromFile(imageList[i].path, filename: imageList[i].path.split('/').last);
        imageFileList.add(file);
      } else {
        String imageUrl = imageList[i].toString().split('/').last;
        imageUrlList.add(imageUrl);
      }
    }
  }

  // 삭제되는 이미지 리스트에 담기
  void setRemoveList(Community community, String imageUrl) {
    int index = -1;

    for (int i = 0; i < community.imgUrlList.length; i++) {
      if (imageUrl == community.imgUrlList[i]) index = i + 1;
    }

    removeIndexList.add(index);
  }

  // 펫 타입 만들기 (강아지 1, 고양이 2)
  String makePetTypeWord() {
    String result = '';

    void makeWord(String value) {
      if (!result.contains(value)) {
        if (result.isEmpty) {
          result = value;
        } else {
          if (result == '2')
            result = '1 | 2'; // 2가 첫 번째면 순서 바꿔주기
          else
            result += ' | ' + value;
        }
      }
    }

    selectedPetKindList.forEach((element) {
      if (GlobalData.dogKindList.contains(element))
        makeWord('1');
      else if (GlobalData.catKindList.contains(element)) makeWord('2');
    });

    return result;
  }

  // 품종 단어 만들기
  String makeKindWord(List<String> selectedList) {
    String result = '';

    for (int i = 0; i < selectedList.length; i++) {
      if (i == 0)
        result = selectedList[i];
      else
        result += ' | ' + selectedList[i];
    }

    return result;
  }

  // 품종 선택 토글
  void togglePetKind({required String value, int? limit}) {
    if (selectedPetKindList.contains(value)) {
      selectedPetKindList.remove(value); // 이미 포함되어 있다면 삭제
    } else {
      if (limit == null) {
        selectedPetKindList.add(value); // 갯수 제한이 없다면 add
      } else {
        if (selectedPetKindList.length < limit) selectedPetKindList.add(value); // 갯수 제한이 있다면
      }
    }
  }

  // 주제 토글
  void toggleCategory(String value) {
    if (category.value == value)
      category('');
    else
      category(value);
  }

  // 사진 가져오기
  Future getImageEvent({required bool isCamera}) async {
    if(tmpImageList.length >= 3) {
      return Fluttertoast.showToast(
        msg: '사진은 최대 3장까지 가능해요',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );
    }

    vfLoadingDialog(); // 로딩 인디케이터 시작

    final ImagePicker _picker = ImagePicker();
    selectedImage = await _picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

    Get.back();// 로딩 인디케이터 끄기

    if (selectedImage != null) {
      if (await isBigFile(selectedImage)) {
        return Fluttertoast.showToast(
          msg: '사진의 크기는 10mb를 넘을 수 없습니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );
      } else {
        File imageFile = File(selectedImage.path);

        await Get.to(() => EditImagePage(imageFile: imageFile))!.then((value) {
          if(value != null) {
            XFile _xFile = XFile(value.path);
            tmpImageList.add(_xFile);
            selectedImage = _xFile;
          }
        });
      }
    }
  }

  // 필수 입력 사랑 미입력 시 안내 토스트
  void notOkToast(bool isWrite){
    if(isWrite){
      if(category.value.isEmpty) {
        Fluttertoast.showToast(
          msg: '주제를 선택해 주세요.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );
      } else if(selectedPetKindList.isEmpty) {
        Fluttertoast.showToast(
          msg: '품종을 선택해 주세요.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.51),
          textColor: Colors.white,
        );
      }
    }
  }

  // 이미지 선택 완료
  void imageSelectionComplete() {
    imageList.clear();
    imageList.addAll(tmpImageList);
    Get.back();
  }

  // 선택된 이미지 취소
  void cancelSelectedImage() {
    tmpImageList.remove(selectedImage);
    if(tmpImageList.isNotEmpty) selectedImage = tmpImageList.last;
    else selectedImage = null;
  }

  // 주제 세팅
  void setCategoryList() {
    final String value = '마이베프 컨텐츠';
    final int adminID = 1;

    categoryList = [...communityCategories]; // 커뮤니티 주제 세팅
    categoryList.remove(value); // '마이베프 컨텐츠' 삭제

    if (GlobalData.loggedInUser.value.userID == adminID) categoryList.insert(0, value); // 관리자인 경우 '마이베프 컨텐츠' 0번째에 add
  }

  // 글쓰기 ok 체크
  void okCheck(bool isWrite) {
    String removedTitle = removeSpace(title.value);
    String removedContents = removeSpace(contents.value);

    if (isWrite) {
      if (category.value.isNotEmpty && selectedPetKindList.isNotEmpty && removedTitle.length >= TITLE_MIN_NUM && removedContents.length >= CONTENTS_MIN_NUM)
        isOkForWrite(true);
      else
        isOkForWrite(false);
    } else {
      if (removedTitle.length >= TITLE_MIN_NUM && removedContents.length >= CONTENTS_MIN_NUM)
        isOkForModify(true);
      else
        isOkForModify(false);
    }
  }
}
