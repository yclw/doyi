import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../utils/network_utils.dart';
import '../utils/rate_limiter.dart';

/// API客户端
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'User-Agent': AppConstants.userAgent,
        'Referer': 'https://www.bilibili.com/',
        'Origin': 'https://www.bilibili.com',
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'DNT': '1',
      },
      // 添加更宽松的验证设置
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    _setupInterceptors();
  }
  
  /// 获取Dio实例
  Dio get dio => _dio;
  
  /// 设置拦截器
  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('请求: ${options.method} ${options.uri}');
        if (options.data != null) {
          Logger.d('请求数据: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('响应: ${response.statusCode} ${response.requestOptions.uri}');
        Logger.d('响应数据: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        Logger.e('请求错误: ${error.message}');
        if (error.response != null) {
          Logger.e('错误响应: ${error.response?.data}');
          
          // 检查是否是-412风控错误
          if (error.response?.data is Map<String, dynamic>) {
            final data = error.response?.data as Map<String, dynamic>;
            final code = data['code'];
            if (code == -412) {
              Logger.e('触发B站风控(-412)，建议：1.检查请求头设置 2.降低请求频率 3.使用有效Cookie');
            }
          }
        }
        
        // 检查网络连接
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          final isConnected = await NetworkUtils.isConnected();
          if (!isConnected) {
            Logger.e('网络连接失败，请检查网络设置');
          } else {
            final canReachBilibili = await NetworkUtils.checkBilibiliConnection();
            if (!canReachBilibili) {
              Logger.e('无法连接到B站服务器，请稍后重试');
            }
          }
        }
        
        handler.next(error);
      },
    ));
  }
  
  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // 应用频率限制
    await RateLimiter.checkAndWait(path);
    
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // 应用频率限制
    await RateLimiter.checkAndWait(path);
    
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
} 