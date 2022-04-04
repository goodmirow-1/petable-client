
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Controller/bowl_page_controller.dart';
import 'package:myvef_app/Config/AppConfig.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalAbStractClass.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Home/Controller/initial_binding.dart';
import 'package:myvef_app/Login/CreateAccountPage.dart';
import 'package:myvef_app/Login/LoginPage.dart';
import 'package:myvef_app/Login/find_complete_page.dart';
import 'package:myvef_app/Network/ApiProvider.dart';
import 'package:myvef_app/Notification/controller/notification_controller.dart';
import 'package:myvef_app/Splash/SplashScreen.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '/Config/GlobalWidget/GlobalWidget.dart';


class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({Key ?key, required this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver{

  final GlobalData globalData = Get.put(GlobalData());
  final NotificationController notificationController = Get.put(NotificationController());
  final BowlPageController bowlPageController = Get.put(BowlPageController());

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('state = $state');

    List<StoppableService> services = [
      globalData,
    ];

    services.forEach((service) {
      if(state == AppLifecycleState.resumed){
        if(GlobalData.loggedInUser.value.userID != nullInt){
          notificationController.setNotificationListByEvent();

          Future.microtask(() async {
            if (int.parse(GlobalData.accessTokenExpiredAt) < int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10))) {
              debugPrint('refresh token call in recycle');
              var res = await ApiProvider().post('/User/Check/Token', jsonEncode({"userID": GlobalData.loggedInUser.value.userID, "refreshToken": GlobalData.refreshToken}));

              if(res != null){
                GlobalData.accessToken = res['AccessToken'] as String;
                GlobalData.accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
              }
            }
          });
        }

        service.start();
      }else if(state == AppLifecycleState.paused){
        service.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
  FlutterAppBadger.updateBadgeCount(1);
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final String config = await rootBundle.loadString('assets/config/config.json');
  final data = await json.decode(config);

  //카카오 네이티브앱 키
  KakaoContext.clientId = data['items'][0]['data'];

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    sizeUnit = WidgetsBinding.instance!.window.physicalSize.width / WidgetsBinding.instance!.window.devicePixelRatio / 360;
    debugPrint("size unit is $sizeUnit");
    return LifeCycleManager(
      child: GetMaterialApp(
        getPages: [
          GetPage(
            name: '/LoginPage',
            page: () => LoginPage(),
          ),
          GetPage(
            name: '/CreateAccountPage',
            page: () => CreateAccountPage(loginType: LOGIN_TYPE_EMAIL),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/FindCompletePage',
            page: () => FindCompletePage(),
            transition: Transition.rightToLeft
          )
        ],
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        initialRoute: '/LoginPage',
        routes: {
          '/SplashScreen': (BuildContext context) => SplashScreen(),
          '/LoginPage': (BuildContext context) => LoginPage(),
          '/CreateAccountPage' : (_) => CreateAccountPage(loginType: LOGIN_TYPE_EMAIL,),
          '/FindCompletePage' :(_) => FindCompletePage(),
        },
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            brightness: Brightness.light,
            backwardsCompatibility: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          //기본 배경색 지정
          bottomAppBarColor: Colors.white,
          backgroundColor: Colors.transparent,
          dialogBackgroundColor: Colors.white,
          primaryColor: Colors.white,
          fontFamily: 'SpoqaHanSansNeo',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
            },
          ),
        ),
        localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: [
          const Locale('ko', 'KR'),
        ],
        initialBinding: InitialBinding(), // GetController Binding
      ),
    );
  }
}
