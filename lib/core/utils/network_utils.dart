import 'dart:io';

/// 网络工具类
class NetworkUtils {
  /// 检查网络连接状态
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('www.baidu.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查是否可以访问指定主机
  static Future<bool> canReachHost(String host, {int port = 443}) async {
    try {
      final result = await InternetAddress.lookup(host);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // 尝试建立Socket连接
        final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
        socket.destroy();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查B站服务器连接状态
  static Future<bool> checkBilibiliConnection() async {
    try {
      // 检查passport.bilibili.com
      final passportReachable = await canReachHost('passport.bilibili.com');
      if (!passportReachable) {
        return false;
      }
      
      // 检查api.bilibili.com
      final apiReachable = await canReachHost('api.bilibili.com');
      return apiReachable;
    } catch (e) {
      return false;
    }
  }
} 