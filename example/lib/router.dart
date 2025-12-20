import 'package:xmca/xmca.dart';
import 'package:xmcp_base/xmcp_base.dart';

import 'main.dart';

registRouters() {
  XRouter.instance.registRouters([
    GoRoute(path: XRouter.instance.initialLocation, builder: (context, state) => HomePage()),
  ]);

  // 注册xmca相关路由
  registCaRouters();
}
