import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Cookie管理器
class CookieManager {
  final SharedPreferences _prefs;
  
  CookieManager(this._prefs);
  
  /// 保存Cookie
  Future<void> saveCookie(String cookie) async {
    try {
      await _prefs.setString(AppConstants.cookieKey, cookie);
      Logger.i('Cookie保存成功');
    } catch (e) {
      Logger.e('Cookie保存失败: $e');
      rethrow;
    }
  }
  
  /// 获取Cookie
  String? getCookie() {
    try {
      final cookie = _prefs.getString(AppConstants.cookieKey);
      if (cookie != null && cookie.isNotEmpty) {
        Logger.d('获取到Cookie: ${cookie.length > 50 ? '${cookie.substring(0, 50)}...' : cookie}');
        return cookie;
      }
      Logger.d('未找到Cookie');
      return null;
    } catch (e) {
      Logger.e('获取Cookie失败: $e');
      return null;
    }
  }
  
  /// 清除Cookie
  Future<void> clearCookie() async {
    try {
      await _prefs.remove(AppConstants.cookieKey);
      Logger.i('Cookie清除成功');
    } catch (e) {
      Logger.e('Cookie清除失败: $e');
      rethrow;
    }
  }
  
  /// 检查Cookie是否存在
  bool hasCookie() {
    final cookie = getCookie();
    return cookie != null && cookie.isNotEmpty;
  }
  
  /// 从响应头提取Cookie
  String? extractCookieFromHeaders(Map<String, List<String>> headers) {
    final setCookieHeaders = headers['set-cookie'];
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
      return null;
    }
    
    final cookies = <String>[];
    for (final header in setCookieHeaders) {
      // 提取cookie名称和值
      final parts = header.split(';');
      if (parts.isNotEmpty) {
        cookies.add(parts.first.trim());
      }
    }
    
    if (cookies.isNotEmpty) {
      final cookieString = cookies.join('; ');
      Logger.d('从响应头提取Cookie: ${cookieString.length > 100 ? '${cookieString.substring(0, 100)}...' : cookieString}');
      return cookieString;
    }
    
    return null;
  }
} 