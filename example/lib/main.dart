import 'package:flutter/material.dart';
import 'package:xmca/xmca.dart';
import 'package:xmca_example/router.dart';
import 'package:xmcp_base/xmcp_base.dart';

/// 非第三方App入口函数
void main() async {
  appInit(() => xlog('Main ==> FlutterApp 启动'));
}

void appInit(Function() setting) async {
  WidgetsFlutterBinding.ensureInitialized();
  await XGlobal.init();
  XLoading.init();
  setting.call();
  runApp(CsApp());
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
    registRouters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    xdp('_CsAppState');
    return ChangeNotifierProvider(
      create: (context) => AppTheme.get()..mode = AppTheme.themeModeFormString('system'),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return ScreenUtilInit(
          designSize: const Size(750, 1624),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              themeMode: appTheme.mode,
              theme: createLightThemeData(context),
              darkTheme: createDarkThemeData(),
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
                      ).copyWith(textScaler: TextScaler.linear(XNativeUtil.style.textScaler)),
                      child: BotToastInit()(context, child),
                    ),
                  );
                },
              ),
              routerConfig: XRouter.instance.getRouter(),
            );
          },
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
              var params = {
                "appParams": {
                  "openToken": "sds",
                  "appKey": "GrA3gEpJZNJB7__-mnMtUg==",
                  "baseUrl": "sss",
                  "companyId": "1",
                  "communityTopId": "1",
                  "communityId": "1",
                },
                "appStyle": {"textScaler": '1', "iconScaler": "1", "titleScaler": "1"},
              };

              XNativeUtil.appParams = params;
              context.push(grpXmca);
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
