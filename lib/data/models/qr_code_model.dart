import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_code_entity.dart';

part 'qr_code_model.g.dart';

/// 二维码数据模型
@JsonSerializable()
class QrCodeModel extends QrCodeEntity {
  const QrCodeModel({
    required super.url,
    required super.qrcodeKey,
  });
  
  /// 从JSON创建二维码模型
  factory QrCodeModel.fromJson(Map<String, dynamic> json) => _$QrCodeModelFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$QrCodeModelToJson(this);
  
  /// 从B站API响应创建二维码模型
  factory QrCodeModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return QrCodeModel(
      url: data['url'] as String? ?? '',
      qrcodeKey: data['qrcode_key'] as String? ?? '',
    );
  }
}

/// 二维码状态数据模型
@JsonSerializable()
class QrStatusModel extends QrStatusEntity {
  const QrStatusModel({
    required super.code,
    required super.message,
    super.url,
    super.refreshToken,
    super.timestamp,
  });
  
  /// 从JSON创建二维码状态模型
  factory QrStatusModel.fromJson(Map<String, dynamic> json) => _$QrStatusModelFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$QrStatusModelToJson(this);
  
  /// 从B站API响应创建二维码状态模型
  factory QrStatusModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return QrStatusModel(
      code: data['code'] as int? ?? -1,
      message: data['message'] as String? ?? '',
      url: data['url'] as String?,
      refreshToken: data['refresh_token'] as String?,
      timestamp: data['timestamp'] as int?,
    );
  }
} 