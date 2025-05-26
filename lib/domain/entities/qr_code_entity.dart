import 'package:equatable/equatable.dart';

/// 二维码实体
class QrCodeEntity extends Equatable {
  final String url;
  final String qrcodeKey;
  
  const QrCodeEntity({
    required this.url,
    required this.qrcodeKey,
  });
  
  @override
  List<Object> get props => [url, qrcodeKey];
}

/// 二维码状态实体
class QrStatusEntity extends Equatable {
  final int code;
  final String message;
  final String? url;
  final String? refreshToken;
  final int? timestamp;
  
  const QrStatusEntity({
    required this.code,
    required this.message,
    this.url,
    this.refreshToken,
    this.timestamp,
  });
  
  @override
  List<Object?> get props => [code, message, url, refreshToken, timestamp];
  
  /// 是否成功
  bool get isSuccess => code == 0;
  
  /// 是否未扫码
  bool get isNotScanned => code == 86101;
  
  /// 是否已扫码未确认
  bool get isScanned => code == 86090;
  
  /// 是否二维码过期
  bool get isExpired => code == 86038;
} 