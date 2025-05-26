// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrCodeModel _$QrCodeModelFromJson(Map<String, dynamic> json) => QrCodeModel(
  url: json['url'] as String,
  qrcodeKey: json['qrcodeKey'] as String,
);

Map<String, dynamic> _$QrCodeModelToJson(QrCodeModel instance) =>
    <String, dynamic>{'url': instance.url, 'qrcodeKey': instance.qrcodeKey};

QrStatusModel _$QrStatusModelFromJson(Map<String, dynamic> json) =>
    QrStatusModel(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      url: json['url'] as String?,
      refreshToken: json['refreshToken'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$QrStatusModelToJson(QrStatusModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'url': instance.url,
      'refreshToken': instance.refreshToken,
      'timestamp': instance.timestamp,
    };
