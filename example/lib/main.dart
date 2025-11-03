import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:xmca/xmca.dart';
import 'package:xmca_example/native_bridge.dart';

bool get fromOtherApp => 'com.xmai.xmca'.fromOtherApp;

String initialRoute = '';

Widget get homePage {
  return initialRoute.isEmpty
      ? HomePage()
      : initialRoute == '/xmcs'
      ? HomePage()
      : Xmca.chatRoomPage;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInit();
  runApp(CsApp());
}

appInit() async {
  XGlobal.init();
  XLoading.init();
  if (fromOtherApp) {
    xlog('Main ==> 来自第三方App: ${XAppDeviceInfo.instance.packageName}');
    initialRoute = ui.PlatformDispatcher.instance.defaultRouteName;
    // 设置原生调用的回调
    NativeBridge.instance.setMethodCall();
  } else {
    xlog('Main ==> 来自xmcaExample App');
    Xmca.config(
      params: {
        "openToken": "sds",
        "appKey": "GrA3gEpJZNJB6__-mnMtUg==",
        "companyId": "1",
        "communityTopId": "1",
        "communityId": "1",
        "baseUrl": "sss",
      },
    );
  }
}

showToast(String? content, {int? animationTime, Object? stackTrace}) {
  content = content ?? '';
  if (content.isEmpty) return;
  BotToast.showText(
    text: content,
    align: Alignment.center,
    duration: Duration(seconds: animationTime ?? 2),
  );
}

class CsApp extends StatefulWidget {
  const CsApp({super.key});

  @override
  State<CsApp> createState() => _CsAppState();
}

class _CsAppState extends State<CsApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {}

  @override
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1624),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          color: Colors.white,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('zh', 'CN'), // 中文
            const Locale('en', 'US'), // 英文
          ],
          locale: const Locale('zh', 'CN'), // 默认语言设置为中文
          builder: EasyLoading.init(
            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent, // 关键属性，允许穿透点击‌
                onTap: () {
                  // 关闭所有焦点键盘
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(XPlatform.isDesktop() ? 0.95 : 1)),
                  child: BotToastInit()(context, child),
                ),
              );
            },
            // 这里设置了全局字体固定大小，不随系统设置变更
          ),
          home: GestureDetector(
            behavior: HitTestBehavior.translucent, // 关键属性，允许穿透点击‌
            onTap: () {
              // 关闭所有焦点键盘
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: homePage,
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.brown[300]),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // 圆角半径
                ),
              ),
            ),
            child: const Text('进入聊天室(CA)', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Xmca.chatRoomPage;
                  },
                ),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
