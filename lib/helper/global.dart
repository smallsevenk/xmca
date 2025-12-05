import 'package:xkit/helper/x_sp.dart';
import 'package:xmca/pages/chat/util/nui_util.dart';

/// 全局自动播放开关
bool get autoPlaySwitchIsOpen => XSpUtil.prefs.getBool(autoPlayKey) ?? false;
setAutoPlay() {
  XSpUtil.prefs.setBool(autoPlayKey, !autoPlaySwitchIsOpen);
}
