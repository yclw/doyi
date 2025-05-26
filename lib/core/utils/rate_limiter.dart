/// 请求频率限制器
class RateLimiter {
  static final Map<String, DateTime> _lastRequestTimes = {};
  static const Duration _minInterval = Duration(milliseconds: 500); // 最小请求间隔500ms
  
  /// 检查是否可以发起请求
  static Future<void> checkAndWait(String endpoint) async {
    final now = DateTime.now();
    final lastTime = _lastRequestTimes[endpoint];
    
    if (lastTime != null) {
      final elapsed = now.difference(lastTime);
      if (elapsed < _minInterval) {
        final waitTime = _minInterval - elapsed;
        await Future.delayed(waitTime);
      }
    }
    
    _lastRequestTimes[endpoint] = DateTime.now();
  }
  
  /// 重置特定端点的限制
  static void reset(String endpoint) {
    _lastRequestTimes.remove(endpoint);
  }
  
  /// 重置所有限制
  static void resetAll() {
    _lastRequestTimes.clear();
  }
} 