// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: (json['uid'] as num).toInt(),
  username: json['username'] as String,
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String,
  isVip: json['isVip'] as bool,
  vipType: (json['vipType'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  coins: (json['coins'] as num).toInt(),
  isLogin: json['isLogin'] as bool,
  signature: json['signature'] as String,
  gender: (json['gender'] as num).toInt(),
  birthday: json['birthday'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'username': instance.username,
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'isVip': instance.isVip,
  'vipType': instance.vipType,
  'level': instance.level,
  'coins': instance.coins,
  'isLogin': instance.isLogin,
  'signature': instance.signature,
  'gender': instance.gender,
  'birthday': instance.birthday,
};
