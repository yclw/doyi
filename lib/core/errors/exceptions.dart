/// 基础异常类
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(super.message);
}

/// 认证异常
class AuthException extends AppException {
  const AuthException(super.message);
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(super.message);
}

/// 二维码异常
class QrCodeException extends AppException {
  const QrCodeException(super.message);
}

/// 解析异常
class ParseException extends AppException {
  const ParseException(super.message);
} 