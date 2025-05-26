import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

/// 本地数据源接口
abstract class LocalDatasource {
  Future<void> cacheUserInfo(UserModel user);
  Future<UserModel?> getCachedUserInfo();
  Future<void> clearUserInfo();
  Future<void> setLoginStatus(bool isLoggedIn);
  Future<bool> getLoginStatus();
  Future<void> clearAll();
}

/// 本地数据源实现
class LocalDatasourceImpl implements LocalDatasource {
  final SharedPreferences _prefs;
  
  LocalDatasourceImpl(this._prefs);
  
  @override
  Future<void> cacheUserInfo(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _prefs.setString(AppConstants.userInfoKey, userJson);
      Logger.d('用户信息缓存成功');
    } catch (e) {
      Logger.e('缓存用户信息失败: $e');
      throw CacheException('缓存用户信息失败: $e');
    }
  }
  
  @override
  Future<UserModel?> getCachedUserInfo() async {
    try {
      final userJson = _prefs.getString(AppConstants.userInfoKey);
      if (userJson == null) {
        Logger.d('未找到缓存的用户信息');
        return null;
      }
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);
      Logger.d('获取缓存用户信息成功: ${user.nickname}');
      return user;
    } catch (e) {
      Logger.e('获取缓存用户信息失败: $e');
      throw CacheException('获取缓存用户信息失败: $e');
    }
  }
  
  @override
  Future<void> clearUserInfo() async {
    try {
      await _prefs.remove(AppConstants.userInfoKey);
      Logger.d('用户信息缓存清除成功');
    } catch (e) {
      Logger.e('清除用户信息缓存失败: $e');
      throw CacheException('清除用户信息缓存失败: $e');
    }
  }
  
  @override
  Future<void> setLoginStatus(bool isLoggedIn) async {
    try {
      await _prefs.setBool(AppConstants.loginStatusKey, isLoggedIn);
      Logger.d('登录状态设置成功: $isLoggedIn');
    } catch (e) {
      Logger.e('设置登录状态失败: $e');
      throw CacheException('设置登录状态失败: $e');
    }
  }
  
  @override
  Future<bool> getLoginStatus() async {
    try {
      final isLoggedIn = _prefs.getBool(AppConstants.loginStatusKey) ?? false;
      Logger.d('获取登录状态: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      Logger.e('获取登录状态失败: $e');
      throw CacheException('获取登录状态失败: $e');
    }
  }
  
  @override
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearUserInfo(),
        _prefs.remove(AppConstants.loginStatusKey),
      ]);
      Logger.d('所有本地数据清除成功');
    } catch (e) {
      Logger.e('清除所有本地数据失败: $e');
      throw CacheException('清除所有本地数据失败: $e');
    }
  }
} 