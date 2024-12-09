import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:im_flutter/firebase_options.dart';
import 'package:im_flutter/global.dart';
import 'package:im_flutter/pages/group/MyGroup/index.dart';
import 'common/index.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  await Global.init();

  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();

  await initRefresh();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message){
    print('Got a message while in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future initRefresh() async {
  /// 初始化刷新样式
  EasyRefresh.defaultHeader = ClassicalHeader(
      refreshText: "下拉刷新",
      refreshReadyText: "释放刷新",
      refreshingText: "正在刷新",
      refreshedText: "刷新完成",
      noMoreText: "没有更多了",
      infoText: '更新于 %T');
  EasyRefresh.defaultFooter = ClassicalFooter(
      loadText: "上拉加载更多",
      loadReadyText: "释放加载更多",
      loadingText: "加载中",
      loadedText: "加载更多...",
      noMoreText: "没有更多了",
      infoText: '更新于 %T');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896), //设计稿尺寸
      splitScreenMode: false, //是否支持分屏模式
      minTextAdapt: false, // 是否根据宽度/高度中的最小值适配文字

      builder: (context, child) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          //主题样式
          theme: ConfigService.to.isDarkMode ? AppTheme.dark : AppTheme.light,
          //路由
          initialRoute: RouteNames.systemMain, //RouteNames.systemLogin,
          //RouteNames.stylesStyleIndex, // RouteNames.systemSplash,
          defaultTransition: Transition.rightToLeftWithFade,

          getPages: RoutePages.list,
          navigatorObservers: [RoutePages.observer],
          //多语言
          translations: Translation(), //词典
          localizationsDelegates: Translation.localizationsDelegates, //代理
          supportedLocales: Translation.supportedLocales, //支持的语言种类
          locale: ConfigService.to.locale, //当前的语言种类
          fallbackLocale: Translation.fallbackLocale, //默认语言
          //builder
          builder: (context, widget) {
            widget = EasyLoading.init()(context, widget); // EasyLoading初始化
            //不随系统字体缩放比例
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget,
            );
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
