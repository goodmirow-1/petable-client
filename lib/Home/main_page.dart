import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Bowl/Model/bowl.dart';
import 'package:myvef_app/Bowl/manual_page.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAsset.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';
import 'package:myvef_app/Config/GlobalWidget/GlobalWidget.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:myvef_app/Config/GlobalWidget/get_extended_image.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';
import 'package:myvef_app/Home/Controller/navigation_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:myvef_app/Home/dash_board_page.dart';
import 'package:myvef_app/Home/test_page.dart';
import 'package:myvef_app/Login/Controller/LoginController.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/detail_pet_info/detail_pet_info_page.dart';
import 'package:myvef_app/graph/controller/graph_page_controller.dart';
import 'package:myvef_app/setting/account_management.dart';
import 'package:myvef_app/setting/add_pet_page.dart';
import 'package:myvef_app/setting/alarm_setting.dart';
import 'package:myvef_app/setting/app_info.dart';
import 'package:myvef_app/bowl/bowl_page.dart';
import 'package:myvef_app/community/controller/community_controller.dart';
import 'package:myvef_app/community/my_community_page.dart';
import 'package:myvef_app/edit/edit_pet_page.dart';
import 'package:myvef_app/edit/edit_user_page.dart';
import 'package:myvef_app/graph/graph_page.dart';
import 'package:myvef_app/community/community_page.dart';
import 'package:myvef_app/setting/faq_page.dart';
import 'package:package_info/package_info.dart';

import '../intake/controller/intake_contoller.dart';
import '../intake/controller/snack_intake_controller.dart';
import 'Controller/dash_board_controller.dart';

GlobalKey<ScaffoldState> mainPageScaffoldKey = GlobalKey<ScaffoldState>();

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<FormState> bottomNavKey = GlobalKey<FormState>();
  final NavigationController navController = Get.find<NavigationController>();

  bool isCanDynamicLink = true;

  final List<Widget> widgetOptions = <Widget>[
    DashBoardPage(), // home
    GraphPage(), // graph
    SizedBox(), // empty
    BowlPage(), // bowl
    CommunityPage(), // community
  ];

  final List<Map<String, String>> navItemList = [
    {'title': 'HOME', 'iconPath': 'assets/image/nav_bar/home.svg'},
    {'title': 'GRAPH', 'iconPath': 'assets/image/nav_bar/graph.svg'},
    {'title': 'PET', 'iconPath': ''},
    {'title': 'BOWL', 'iconPath': 'assets/image/nav_bar/bowl.svg'},
    {'title': 'COMMUNITY', 'iconPath': 'assets/image/nav_bar/community.svg'},
  ];

  // navItem 으로 페이지 변경
  void changePageWithNavItem(PageController pageController) {
    const Duration duration = Duration(milliseconds: 300);
    const Cubic curves = Curves.ease;

    if (pageController.hasClients) {
      switch (pageController.page!.toInt()) {
        case 0:
          pageController.animateToPage(1, duration: duration, curve: curves);
          break;
        case 1:
          pageController.animateToPage(0, duration: duration, curve: curves);
          break;
      }
    }
  }

  //다이나믹링크 받는 함수
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      Uri deepLink = dynamicLinkData.link;
      if (GlobalData.loggedInUser.value.userID != nullInt) {
        _handleDynamicLink(deepLink);
      }
    }).onError((error) {
      debugPrint('onLinkError');
      debugPrint(error.message);
    });

    // Get any initial links
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      // Example of using the dynamic link to push the user to a different screen

      if (GlobalData.loggedInUser.value.userID != nullInt) {
        _handleDynamicLink(deepLink);
      }
    }
  }

  void _handleDynamicLink(Uri deepLink) {
    switch (deepLink.path) {
      case '/community':
        {
          NavigationController.to.changeNavIndex(4);
          setState(() {});
          int id = int.parse(deepLink.queryParameters['id']!);
          CommunityController.to.setCommunityDetailDataByID(id);
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    //다이나믹링크
    if (isCanDynamicLink) {
      isCanDynamicLink = false;
      initDynamicLinks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return baseWidget(
      context,
      type: 0,
      colorType: vfGradationColorType.Red,
      onWillPop: () {
        if (navController.currentIndex != 0) {
          navController.changeNavIndex(0);
          setState(() {});

          return Future.value(false);
        } else {
          return isEnd();
        }
      },
      child: GetBuilder<NavigationController>(
        builder: (_) =>
        Scaffold(
          key: mainPageScaffoldKey,
          body: Stack(
            children: [
              widgetOptions[navController.currentIndex],
              buildPetSelectionWidget(),
            ],
          ),
          endDrawer: navController.currentIndex == 1 ? null : settingEndDrawer(),
          bottomNavigationBar: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20 * sizeUnit),
              ),
              child: Container(
                height: devicePadding.bottom == 0 ? 56 * sizeUnit : null,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      offset: Offset(0, -1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child:
                   BottomNavigationBar(
                    key: bottomNavKey,
                    elevation: 0.0,
                    backgroundColor: Colors.white,
                    selectedFontSize: 3 * sizeUnit,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: navController.currentIndex,
                    onTap: (index) async {
                      if (index == 2) {
                        if (GlobalData.mainPet.value.type != PET_TYPE_ECT) {
                          navController.togglePetFunc(bottomNavKey.currentContext!.findRenderObject() as RenderBox);
                        }
                      } else {
                        //대시보드 페이지 동기화
                        if (index == 0) {
                          final IntakeController intakeController = Get.put(IntakeController());
                          final SnackController snackController = Get.put(SnackController());
                          final DashBoardController dashBoardController = Get.find<DashBoardController>();

                          await intakeController.setIntake(); // 최근 Intake 값 local 세팅 후 칼로리, 물 리스트에 insert
                          await snackController.setSnack(); // 최근 Snack 값 local 세팅 후 칼로리, 물 리스트에 insert

                          dashBoardController.calTodayCalorie(); // 오늘 섭취한 칼로리 최신화 (kcal)
                          dashBoardController.calTodayWater(); // 오늘 섭취한 물 최신화 (ml)
                        }

                        if (index == 1) changePageWithNavItem(GraphPageController.to.pageController); // 그래프 페이지 컨트롤
                        if (index == 3) changePageWithNavItem(BowlPageController.to.pageController); // 보울 페이지 컨트롤
                        if (index == 4) changePageWithNavItem(CommunityController.to.pageController); // 커뮤니티 페이지 컨트롤

                        if (navController.activePet.value) navController.offPetFunc(); // 펫 끄기
                        navController.changeNavIndex(index);
                        if (navController.currentIndex != navController.previousIndex) setState(() {});
                      }
                    },
                    items: List.generate(navItemList.length, (index) {
                      if (index == 2) return navPetItem();
                      return normalNavItem(title: navItemList[index]['title']!, iconPath: navItemList[index]['iconPath']!, index: index);
                    }),
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }

  BottomNavigationBarItem navPetItem() {
    return BottomNavigationBarItem(
      label: 'PET',
      icon: Obx(
        () => Container(
          width: 40 * sizeUnit,
          height: 40 * sizeUnit,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: GlobalData.mainPet.value.petPhotos.isNotEmpty ? Border.all(width: 2 * sizeUnit, color: Colors.white) : null,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20 * sizeUnit),
            child: GlobalData.mainPet.value.type == PET_TYPE_ECT
                ? ectNavPetItem() // 예비베프일 때 나오는 추가 버튼
                : GlobalData.mainPet.value.petPhotos.isNotEmpty
                    ? GetExtendedImage(
                        url: GlobalData.mainPet.value.petPhotos[0].imageUrl,
                        boxFit: BoxFit.fill,
                        showDescription: false,
                        indicatorRadius: 18,
                        scale: 0.1,
                        errorWidget: vfBetiHeadBadStateWidget(scale: 0.4),
                      )
                    : changeNavPetIcon(iconPath: svgFootIcon),
          ),
        ),
      ),
    );
  }

  // 예비베프일 때 나오는 추가 버튼
  Widget ectNavPetItem() {
    return Container(
      width: 36 * sizeUnit,
      height: 36 * sizeUnit,
      child: Obx(() => DottedBorder(
            color: navController.navItemColor.value,
            strokeWidth: 4 * sizeUnit,
            borderType: BorderType.Circle,
            dashPattern: [5, 4],
            strokeCap: StrokeCap.butt,
            child: IconButton(
              iconSize: 20 * sizeUnit,
              icon: Icon(Icons.add),
              color: navController.navItemColor.value,
              onPressed: () {
                Get.to(() => AddPetPage());
              },
            ),
          )),
    );
  }

  // 페이지에 따라 색이 변하는 펫 아이콘
  Widget changeNavPetIcon({required String iconPath, bool isBorder = true}) {
    return Obx(() => Container(
        width: 40 * sizeUnit,
        height: 40 * sizeUnit,
        padding: EdgeInsets.all(isBorder ? 2 * sizeUnit : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            // ignore: invalid_use_of_protected_member
            colors: navController.navPetColors.value,
            stops: [0.5, 1.6], //그라데이션 위치 보정값
          ),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: isBorder ? 38 * sizeUnit : 40 * sizeUnit,
          height: isBorder ? 38 * sizeUnit : 40 * sizeUnit,
        )));
  }

  BottomNavigationBarItem normalNavItem({required String title, required String iconPath, required int index}) {
    Rx<Color> darkGrey = vfColorDarkGray.obs;

    return BottomNavigationBarItem(
      label: title,
      icon: Obx(() {
        bool _isSelected = navController.currentIndex == index;

        return Column(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24 * sizeUnit,
              height: 24 * sizeUnit,
              color: _isSelected ? navController.navItemColor.value : darkGrey.value,
            ),
            Text(
              title,
              style: VfTextStyle.body3().copyWith(
                color: _isSelected ? navController.navItemColor.value : darkGrey.value,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildPetSelectionWidget() {
    return Obx(
      () => Column(
        children: [
          AnimatedContainer(
            duration: navController.longDuration,
            curve: Curves.decelerate,
            height: 48 * sizeUnit,
            constraints: BoxConstraints(minWidth: 48 * sizeUnit),
            transform: Matrix4.translationValues(0, navController.yOffset.value, 0),
            padding: EdgeInsets.all(4 * sizeUnit),
            decoration: BoxDecoration(
              color: navController.navItemColor.value.withOpacity(0.6),
              borderRadius: BorderRadius.circular(26 * sizeUnit),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(GlobalData.petList.length + 1, (index) {
                  if (GlobalData.petList.length == index) return addAnimationPetItem(index: index);
                  return animationPetItem(index: index, pet: GlobalData.petList[index]);
                }),
              ),
            ),
          ),
          Container() // 가운데 정렬용
        ],
      ),
    );
  }

  Widget animationPetItem({required int index, required Pet pet}) {
    bool isMainPet = pet.id == GlobalData.mainPet.value.id; // 메인 펫 여부
    double size = navController.activeAnimation.value && !isMainPet ? 40 * sizeUnit : 0;

    return GestureDetector(
      onTap: () => navController.changePet(pet),
      child: AnimatedContainer(
        duration: navController.activeAnimation.value && !navController.petChangeAnimation.value ? navController.shortDuration * (index * 1.2) : navController.shortDuration,
        curve: Curves.decelerate,
        width: size,
        height: size,
        margin: EdgeInsets.only(right: isMainPet ? 0 : 16 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: navController.activeAnimation.value && !isMainPet && pet.petPhotos.isNotEmpty ? Border.all(width: 2 * sizeUnit, color: Colors.white) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * sizeUnit),
          child: pet.type == nullInt
              ? changeNavPetIcon(iconPath: svgPetPhotoDefault)
              : pet.petPhotos.isNotEmpty
                  ? GetExtendedImage(
                      url: pet.petPhotos[0].imageUrl,
                      boxFit: BoxFit.cover,
                      showDescription: false,
                      indicatorRadius: 18,
                      scale: 0.1,
                    )
                  : changeNavPetIcon(iconPath: svgFootIcon),
        ),
      ),
    );
  }

  Widget addAnimationPetItem({required int index}) {
    double size = navController.activeAnimation.value ? 40 * sizeUnit : 0;

    return AnimatedContainer(
      duration: navController.activeAnimation.value && index != 0 ? navController.shortDuration * (index * 1.2) : navController.shortDuration,
      curve: Curves.decelerate,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 0.4)),
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: 38 * sizeUnit,
          height: 38 * sizeUnit,
          child: DottedBorder(
            color: navController.activeAnimation.value ? Colors.white : Colors.transparent,
            strokeWidth: 2 * sizeUnit,
            borderType: BorderType.Circle,
            dashPattern: [5, 5],
            strokeCap: StrokeCap.butt,
            child: AnimatedOpacity(
              duration: navController.activeAnimation.value && index != 0 ? navController.shortDuration * (index * 1.2) : navController.shortDuration,
              opacity: navController.activeAnimation.value ? 1 : 0,
              child: IconButton(
                iconSize: 20 * sizeUnit,
                icon: Icon(Icons.add),
                color: navController.activeAnimation.value ? Colors.white : Colors.transparent,
                onPressed: () {
                  navController.togglePetFunc(bottomNavKey.currentContext!.findRenderObject() as RenderBox);
                  Get.to(() => AddPetPage())!.then((value) => setState(() {}));
                  // scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget listItem(String _title, Function _onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          child: Container(
            height: 48 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_title),
                SvgPicture.asset(svgRightArrowSmall),
              ],
            ),
          ),
          onTap: () {
            _onTap();
          },
        ),
        Container(height: 1 * sizeUnit, decoration: BoxDecoration(color: vfColorGrey)),
      ],
    );
  }

  Widget settingEndDrawer() {
    Widget _endDrawer({
      required String title,
      required List<Widget> menuWidgetList,
      required List<Function> funcList,
      bool isHome = false,
    }) {
      return Container(
        width: 304 * sizeUnit,
        child: Drawer(
          elevation: 0,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 18 * sizeUnit, 0 * sizeUnit, 18 * sizeUnit),
                      child: Text(title, style: VfTextStyle.subTitle2()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16 * sizeUnit, right: 16 * sizeUnit),
                      child: Column(
                        children: menuWidgetList,
                      ),
                    ),
                  ],
                ),
              ),
              if (isHome == true) ...[
                Container(height: 1 * sizeUnit, decoration: BoxDecoration(color: vfColorGrey)),
                InkWell(
                  child: Container(
                    height: 56 * sizeUnit,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16 * sizeUnit),
                      child: Row(
                        children: [
                          SvgPicture.asset(svgLogout),
                          SizedBox(width: 4 * sizeUnit),
                          Text('로그아웃', style: VfTextStyle.body2()),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    showVfDialog(
                      title: '로그아웃 하시겠어요?',
                      description: '알림이 모두 초기화 돼요. \n그래도 로그아웃을 하시겠어요?',
                      colorType: vfGradationColorType.Violet,
                      isCancelButton: true,
                      okFunc: () async {
                        LoginController.to.loading = false; // 로그인 페이지 애니메이션 안돌게

                        var res = await ApiProvider().post(
                            '/User/Logout',
                            jsonEncode({
                              'userID': GlobalData.loggedInUser.value.userID,
                            }));

                        if (res == true) {
                          await GlobalData().callClear();

                          Get.offAll(() => LoginPage());
                        }
                      },
                    );
                  },
                ),
              ],
              if (devicePadding.bottom != 0) SizedBox(height: devicePadding.bottom / 2),
            ],
          ),
        ),
      );
    }

    String _title = '';
    List<String> _menuList = [];
    List<Widget> _menuWidgetList = [];
    List<Function> _funcList = [];
    bool _isHome = false;

    switch (navController.currentIndex) {
      case 0:
        {
          _title = '설정';
          _menuList = [
            '반려동물 정보 수정',
            '진료정보 내보내기',
            '내 정보 수정',
            '알람설정',
            '계정관리',
            '자주 묻는 질문',
            '앱 정보',
          ];

          _funcList = [
            () {
              if (GlobalData.petList.isNotEmpty) {
                Get.to(() => EditPetPage());
              }
            },
            () {
              if (GlobalData.petList.isNotEmpty) {
                Get.to(() => DetailPetInfo());
              }
            },
            () {
              Get.to(() => EditUserPage());
            },
            () {
              Get.to(() => AlarmSetting());
            },
            () {
              Get.to(() => AccountManagement());
            },
            () {
              Get.to(() => FAQPage());
            },
            () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              Get.to(() => AppInfo(packageInfo: packageInfo));
            },
          ];

          if(!kReleaseMode){
            _menuList.add('TEST');
            _funcList.add( () {
              Get.to(() => TestPage());
            });
          }

          _isHome = true;

          _menuWidgetList = _menuList.asMap().map((index, title) => MapEntry(index, listItem(title, _funcList[index]))).values.toList();
        }
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        BowlPageController _controller = Get.find();
        _title = '설정';
        _menuList = ['', '매뉴얼', '영점 조절하기'];
        _funcList = [
          () {
            _controller.endDrawerFunc();
          },
          () {
            Get.to(() => ManualPage());
          },
          () {
            _controller.endDrawerFunc2();
          },
        ];
        _menuWidgetList = [
          Obx(() {
            if (_controller.barIndex.value == BOWL_TYPE_FOOD) {
              if (_controller.isHaveFoodBowl.value)
                _controller.endDrawMenuState('기기 해제하기');
              else
                _controller.endDrawMenuState('기기 등록하기');
            } else if (_controller.barIndex.value == BOWL_TYPE_WATER) {
              if (_controller.isHaveWaterBowl.value)
                _controller.endDrawMenuState('기기 해제하기');
              else
                _controller.endDrawMenuState('기기 등록하기');
            }
            return listItem(_controller.endDrawMenuState.value, _funcList[0]);
          }),
          listItem(_menuList[1], _funcList[1]),
          listItem(_menuList[2], _funcList[2]),
        ];
        break;
      case 4:
        void backFunc() {
          CommunityController.to.offOptions(); // 옵션 끄기
          GlobalData.myCommunityList.clear(); // 마이 커뮤니티 리스트 초기화
        }

        _title = '모아보기';
        _menuList = ['내 게시글', '댓글 단 게시글', '\'좋아요\'한 게시글'];
        _funcList = [
          () async {
            vfLoadingDialog(); // 로딩 다이어로그
            await CommunityController.to.getMyCommunityData();
            Get.back(); // 다이어로그 끄기
            Get.to(() => MyCommunityPage(appBarTitle: '내 게시글'))!.then((value) {
              backFunc();
              CommunityController.to.stateUpdate();
            });
          },
          () async {
            vfLoadingDialog(); // 로딩 다이어로그
            await CommunityController.to.getWroteReplyCommunityData();
            Get.back(); // 다이어로그 끄기
            Get.to(() => MyCommunityPage(appBarTitle: '댓글 단 게시글'))!.then((value) {
              backFunc();
              CommunityController.to.stateUpdate();
            });
          },
          () async {
            vfLoadingDialog(); // 로딩 다이어로그
            await CommunityController.to.getLikeCommunityData();
            Get.back(); // 다이어로그 끄기
            Get.to(() => MyCommunityPage(appBarTitle: '\'좋아요\'한 게시글'))!.then((value) {
              backFunc();
              CommunityController.to.stateUpdate();
            });
          },
        ];
        _menuWidgetList = _menuList.asMap().map((index, title) => MapEntry(index, listItem(title, _funcList[index]))).values.toList();
        break;
    }

    return _endDrawer(title: _title, menuWidgetList: _menuWidgetList, funcList: _funcList, isHome: _isHome);
  }
}
