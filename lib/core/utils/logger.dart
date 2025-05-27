import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 日志工具类
class Logger {
  static const String _tag = 'doyi';
  
  /// 是否启用日志（仅在Debug模式下启用）
  static bool get _isEnabled => kDebugMode;
  
  /// 调试日志
  static void d(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      message, 
      name: tag ?? _tag, 
      level: 500,
      time: DateTime.now(),
    );
  }
  
  /// 信息日志
  static void i(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      message, 
      name: tag ?? _tag, 
      level: 800,
      time: DateTime.now(),
    );
  }
  
  /// 警告日志
  static void w(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      message, 
      name: tag ?? _tag, 
      level: 900,
      time: DateTime.now(),
    );
  }
  
  /// 错误日志
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_isEnabled) return;
    developer.log(
      message, 
      name: tag ?? _tag, 
      level: 1000,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 网络请求日志
  static void network(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      '[NETWORK] $message', 
      name: tag ?? _tag, 
      level: 500,
      time: DateTime.now(),
    );
  }
  
  /// 用户行为日志
  static void user(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      '[USER] $message', 
      name: tag ?? _tag, 
      level: 800,
      time: DateTime.now(),
    );
  }
  
  /// 性能日志
  static void performance(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      '[PERF] $message', 
      name: tag ?? _tag, 
      level: 800,
      time: DateTime.now(),
    );
  }
} 