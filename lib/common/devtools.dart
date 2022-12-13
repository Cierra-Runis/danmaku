import 'package:danmaku/index.dart';

import 'dart:developer' as devtools show log;

class DevTools {
  // 在这改设定
  static const showLog = true;
  static const showDebugPaintSizeEnabled = false;

  // 调试用输出语句
  static void printLog(String message) {
    if (showLog) {
      devtools.log('[${DateTime.now()}] $message');
    }
  }

  static void init() {
    // 是否启用边界显示
    debugPaintSizeEnabled = DevTools.showDebugPaintSizeEnabled;
  }
}
