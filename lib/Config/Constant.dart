import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color vfColorBlack = Color.fromRGBO(12, 24, 45, 1);//0C182D
const Color vfColorDarkGray = Color.fromRGBO(160, 160, 160, 1);//A0A0A0
const Color vfColorGrey = Color.fromRGBO(204, 204, 204, 1);//CCCCCC
const Color vfColorOrange = Color.fromRGBO(255, 162, 104, 1);//FFA268
const Color vfColorOrange60 = Color.fromRGBO(255, 162, 104, 0.6);//FFA268
const Color vfColorOrange20 = Color.fromRGBO(255, 162, 104, 0.2);//FFA268
const Color vfColorWaterBlue = Color.fromRGBO(130, 219, 255, 1);//82DBFF
const Color vfColorSkyBlue = Color.fromRGBO(116, 231, 238, 1);//74E7EE
const Color vfColorSkyBlue60 = Color.fromRGBO(116, 231, 238, 0.6);//82DBFF
const Color vfColorSkyBlue20 = Color.fromRGBO(116, 231, 238, 0.2);//82DBFF
const Color vfColorPink = Color.fromRGBO(255, 163, 183, 1);//FFA3B7
const Color vfColorPink60 = Color.fromRGBO(255, 163, 183, 0.6);//FFA3B7
const Color vfColorPink40 = Color.fromRGBO(255, 163, 183, 0.4);//FFA3B7
const Color vfColorPink20 = Color.fromRGBO(255, 163, 183, 0.2);//FFA3B7
const Color vfColorRed = Color.fromRGBO(245, 69, 59, 1);//F7675D
const Color vfColorRed60 = Color.fromRGBO(245, 69, 59, 0.6);//F7675D
const Color vfColorRed20 = Color.fromRGBO(245, 69, 59, 0.2);//F5453B
const Color vfColorViolet = Color.fromRGBO(113, 102, 210, 1);//7166D2
const Color vfColorViolet60 = Color.fromRGBO(113, 102, 210, 0.4);//7166D2
const Color vfGradationRed1 = Color.fromRGBO(255, 207, 139, 0.4);//FFCF8B
const Color vfGradationRed2 = Color.fromRGBO(245, 69, 56, 0.4);//F54538
const Color vfBackgroundGradationRed1 = Color.fromRGBO(255, 207, 139, 0.8);
const Color vfBackgroundGradationRed2 = Color.fromRGBO(245, 69, 56, 0.8);

const Color vfGradationBlue1 = Color.fromRGBO(130, 219, 255, 0.4);
const Color vfGradationBlue2 = Color.fromRGBO(116, 231, 238, 0.4);
const Color vfBackgroundGradationBlue1 = Color.fromRGBO(130, 219, 255, 0.8);
const Color vfBackgroundGradationBlue2 = Color.fromRGBO(116, 231, 238, 0.8);

const Color vfGradationViolet1 = Color.fromRGBO(255, 136, 183, 0.6);
const Color vfGradationViolet2 = Color.fromRGBO(113, 102, 210, 0.6);
const Color vfBackgroundGradationViolet1 = Color.fromRGBO(255, 136, 183, 0.8);
const Color vfBackgroundGradationViolet2 = Color.fromRGBO(113, 102, 210, 0.8);

// 바텀 네비게이션 펫 아이콘 컬러 리스트
const List<Color> navRedColorList = [Color.fromRGBO(245, 69, 59, 0.6), Color.fromRGBO(255, 207, 139, 0.6)];
const List<Color> navBlueColorList = [Color.fromRGBO(130, 217, 255, 0.6), Color.fromRGBO(116, 231, 238, 0.6)];
const List<Color> navVioletColorList = [Color.fromRGBO(113, 102, 210, 0.6), Color.fromRGBO(255, 163, 183, 0.6)];

// circularIndicator 컬러 리스트
const List<Color> loadingRedColorList = [Color.fromRGBO(245, 69, 59, 0.6), Color.fromRGBO(255, 207, 139, 1.0)];
const List<Color> loadingBlueColorList = [Color.fromRGBO(130, 217, 255, 0.6), Color.fromRGBO(116, 231, 238, 1.0)];
const List<Color> loadingVioletColorList = [Color.fromRGBO(113, 102, 210, 0.6), Color.fromRGBO(255, 200, 212, 1.0)];

// 기본 boxShadow
const List<BoxShadow> vfBasicBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.05),
    offset: Offset(0, 6),
    blurRadius: 6,
  ),
];

// 이미지용 boxShadow
const List<BoxShadow> vfImgBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.15),
    offset: Offset(0, 6),
    blurRadius: 6,
  ),
];

// 커뮤니티 주제 리스트
const List<String> communityCategories = [
  '자유',
  '질문',
  '자랑하기',
  '정보공유',
  '산책',
  '마이베프 컨텐츠',
];

// 지역 리스트
const List<String> areaCategory = [
  "서울특별시",
  "인천광역시",
  "경기도",
  "강원도",
  "충청남도",
  "충청북도",
  "세종특별자치시",
  "대전광역시",
  "경상북도",
  "경상남도",
  "대구광역시",
  "부산광역시",
  "전라북도",
  "전라남도",
  "광주광역시",
  "울산광역시",
  "제주특별자치도",
  "국외",
];

const List<String> areaSeoulCategory = [
  "강남구",
  "강동구",
  "강북구",
  "강서구",
  "관악구",
  "광진구",
  "구로구",
  "금천구",
  "노원구",
  "도봉구",
  "동대문구",
  "동작구",
  "마포구",
  "서대문구",
  "서초구",
  "성동구",
  "성북구",
  "송파구",
  "양천구",
  "영등포구",
  "용산구",
  "은평구",
  "종로구",
  "중구",
  "중랑구",
];

const List<String> areaIncheonCategory = [
  "강화군",
  "계양구",
  "남동구",
  "동구",
  "미추홀구",
  "부평구",
  "서구",
  "연수구",
  "옹진군",
  "중구",
];

const List<String> areaGyeonggiCategory = [
  "가평군",
  "고양시 덕양구",
  "고양시 일산동구",
  "고양시 일산서구",
  "과천시",
  "광명시",
  "광주시",
  "구리시",
  "군포시",
  "김포시",
  "남양주시",
  "동두천시",
  "부천시",
  "성남시 분당구",
  "성남시 중원구",
  "수원시 권선구",
  "수원시 영통구",
  "수원시 장안구",
  "수정구",
  "시흥시",
  "안산시 단원구",
  "안산시 상록구",
  "안성시",
  "안양시 동안구",
  "안양시 만안구",
  "양주시",
  "양평군",
  "여주시",
  "연천군",
  "오산시",
  "용인시 기흥구",
  "용인시 수지구",
  "의왕시",
  "의정부시",
  "이천시",
  "처인구",
  "파주시",
  "팔달구",
  "평택시",
  "포천시",
  "하남시",
  "화성시",
];

const List<String> areaKangwonCategory = [
  "강릉시",
  "고성군",
  "동해시",
  "삼척시",
  "속초시",
  "양구군",
  "양양군",
  "영월군",
  "원주시",
  "인제군",
  "정선군",
  "철원군",
  "춘천시",
  "태백시",
  "평창군",
  "홍천군",
  "화천군",
  "횡성군",
];

const List<String> areaDaeguCategory = [
  "남구",
  "달서구",
  "달성군",
  "동구",
  "북구",
  "서구",
  "수성구",
  "중구",
];

const List<String> areaDaejeonCategory = [
  "대덕구",
  "동구",
  "서구",
  "유성구",
  "중구",
];

const List<String> areaChungbukCategory = [
  "괴산군",
  "단양군",
  "보은군",
  "영동군",
  "옥천군",
  "음성군",
  "제천시",
  "증평군",
  "진천군",
  "청주시 상당구",
  "청주시 서원구",
  "청주시 청원구",
  "청주시 흥덕구",
  "충주시",
];

const List<String> areaSejongCategory = ["세종특별자치시"];

const List<String> areaChungnamCategory = [
  "계룡시",
  "공주시",
  "금산군",
  "논산시",
  "당진시",
  "보령시",
  "부여군",
  "서산시",
  "서천군",
  "아산시",
  "예산군",
  "천안시 동남구",
  "천안시 서북구",
  "청양군",
  "태안군",
  "홍성군",
];

const List<String> areaGwangjuCategory = [
  "광산구",
  "남구",
  "동구",
  "북구",
  "서구",
];

const List<String> areaJeonnamCategory = [
  "강진군",
  "고흥군",
  "곡성군",
  "광양시",
  "구례군",
  "나주시",
  "담양군",
  "목포시",
  "무안군",
  "보성군",
  "순천시",
  "신안군",
  "여수시",
  "영광군",
  "영암군",
  "완도군",
  "장성군",
  "장흥군",
  "진도군",
  "함평군",
  "해남군",
  "화순군",
];

const List<String> areaJeonbukCategory = [
  "고창군",
  "군산시",
  "김제시",
  "남원시",
  "무주군",
  "부안군",
  "순창군",
  "완주군",
  "익산시",
  "임실군",
  "장수군",
  "전주시 덕진구",
  "전주시 완산구",
  "정읍시",
  "진안군",
];

const List<String> areaBusanCategory = [
  "강서구",
  "금정구",
  "기장군",
  "남구",
  "동구",
  "동래구",
  "부산진구",
  "북구",
  "사상구",
  "사하구",
  "서구",
  "수영구",
  "연제구",
  "영도구",
  "중구",
  "해운대구",
];

const List<String> areaGyeongnamCategory = [
  "경산시",
  "경주시",
  "고령군",
  "구미시",
  "군위군",
  "김천시",
  "문경시",
  "봉화군",
  "상주시",
  "성주군",
  "안동시",
  "영덕군",
  "영양군",
  "영주시",
  "영천시",
  "예천군",
  "울릉군",
  "울진군",
  "의성군",
  "청도군",
  "청송군",
  "칠곡군",
  "포항시 남구",
  "포항시 북구",
];

const List<String> areaGyeongbukCategory = [
  "거제시",
  "거창군",
  "고성군",
  "김해시",
  "남해군",
  "밀양시",
  "사천시",
  "산청군",
  "양산시",
  "의령군",
  "진주시",
  "창녕군",
  "창원시 마산합포구",
  "창원시 마산회원구",
  "창원시 성산구",
  "창원시 의창구",
  "창원시 진해구",
  "통영시",
  "하동군",
  "함안군",
  "함양군",
  "합천군",
];

const List<String> areaJejuCategory = ["서귀포시", "제주시"];

const List<String> areaUlsanCategory = [
  "남구",
  "동구",
  "북구",
  "울주군",
  "중구",
];

const List<String> areaAbroad = ["국외"];

// 신고 목록 리스트
const List<String> reportList = [
  '토픽에 맞지 않는 글',
  '욕설 / 비하발언',
  '특정인 비방',
  '개인사생활 침해',
  '음란물',
  '게시글 / 댓글 도배',
  '홍보 및 광고',
  '닉네임 신고',
  '기타',
];

const int nullInt = -100; // null 들어오는 int 대체

const double nullDouble = -100.0; // null 들어오는 double 대체

const int PET_TYPE_DOG = 0;
const int PET_TYPE_CAT = 1;
const int PET_TYPE_ECT = 2;

const int MALE = 0; // 남
const int FEMALE = 1; // 여
const int NEUTERING_MALE = 2; // 중남
const int NEUTERING_FEMALE = 3; // 중녀

const int LOGIN_TYPE_EMAIL = 0;
const int LOGIN_TYPE_GOOGLE = 1;
const int LOGIN_TYPE_KAKAOTALK = 2;
const int LOGIN_TYPE_APPLE = 3;

const int WEIGHT_NORMAL = 0; // 정상
const int WEIGHT_LOW_ACTIVITY = 1; // 활동량 적음
const int WEIGHT_OBESITY = 2; // 비만

const int NONE = 0; // 임신, 수유 x
const int PREGNANT = 1; // 임신중
const int LACTATION = 2; // 수유중

const int ADD_PICTURE_RED = 0;
const int ADD_PICTURE_VIOLET = 1;