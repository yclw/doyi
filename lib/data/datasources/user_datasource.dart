import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/cookie_manager.dart';
import '../../core/utils/logger.dart';

/// 用户数据源接口
abstract class UserDatasource {
  Future<UserModel> getUserInfo();
  Future<bool> checkLoginStatus();
}

/// 用户数据源实现
class UserDatasourceImpl implements UserDatasource {
  final ApiClient _apiClient;
  final CookieManager _cookieManager;
  
  UserDatasourceImpl(this._apiClient, this._cookieManager);
  
  @override
  Future<UserModel> getUserInfo() async {
    try {
      Logger.d('开始获取用户信息');
      
      final response = await _apiClient.get(
        AppConstants.userInfoUrl,
        options: Options(
          headers: _buildHeaders(),
        ),
      );
      
      if (response.data == null) {
        throw const ServerException('用户信息响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      if (code != 0) {
        final message = data['message'] as String? ?? '获取用户信息失败';
        if (code == -101) {
          throw const AuthException('账号未登录');
        } else if (code == -412) {
          throw const ServerException('请求被拦截，可能触发风控。请稍后重试或检查网络环境');
        }
        throw ServerException(message);
      }
      
      Logger.d('用户信息获取成功');
      return UserModel.fromBilibiliApiResponse(data);
    } on DioException catch (e) {
      Logger.e('获取用户信息网络错误: ${e.message}');
      throw NetworkException('获取用户信息失败: ${e.message}');
    } catch (e) {
      Logger.e('获取用户信息异常: $e');
      if (e is AppException) rethrow;
      throw ServerException('获取用户信息失败: $e');
    }
  }
  
  @override
  Future<bool> checkLoginStatus() async {
    try {
      Logger.d('开始检查登录状态');
      
      final response = await _apiClient.get(
        AppConstants.loginStatusUrl,
        options: Options(
          headers: _buildHeaders(),
        ),
      );
      
      if (response.data == null) {
        throw const ServerException('登录状态检查响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      final isLoggedIn = code == 0;
      Logger.d('登录状态检查结果: $isLoggedIn');
      
      return isLoggedIn;
    } on DioException catch (e) {
      Logger.e('检查登录状态网络错误: ${e.message}');
      throw NetworkException('检查登录状态失败: ${e.message}');
    } catch (e) {
      Logger.e('检查登录状态异常: $e');
      if (e is AppException) rethrow;
      throw ServerException('检查登录状态失败: $e');
    }
  }
  
  /// 构建请求头
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Referer': 'https://www.bilibili.com/',
    };
    
    final cookie = _cookieManager.getCookie();
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }
    
    return headers;
  }
} 