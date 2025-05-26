import 'dart:developer' as developer;

/// 日志工具类
class Logger {
  static const String _tag = 'BilibiliApp';
  
  /// 调试日志
  static void d(String message) {
    developer.log(message, name: _tag, level: 500);
  }
  
  /// 信息日志
  static void i(String message) {
    developer.log(message, name: _tag, level: 800);
  }
  
  /// 警告日志
  static void w(String message) {
    developer.log(message, name: _tag, level: 900);
  }
  
  /// 错误日志
  static void e(String message) {
    developer.log(message, name: _tag, level: 1000);
  }
} 