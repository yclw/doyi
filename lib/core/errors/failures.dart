import 'package:equatable/equatable.dart';

/// 基础失败类
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// 网络失败
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 二维码失败
class QrCodeFailure extends Failure {
  const QrCodeFailure(super.message);
}

/// 解析失败
class ParseFailure extends Failure {
  const ParseFailure(super.message);
} 