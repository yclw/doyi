import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// 用户数据模型
@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.username,
    required super.nickname,
    required super.avatar,
    required super.isVip,
    required super.vipType,
    required super.level,
    required super.coins,
    required super.isLogin,
    required super.signature,
    required super.gender,
    required super.birthday,
  });
  
  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  /// 从B站API响应创建用户模型
  factory UserModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return UserModel(
      uid: data['mid'] as int? ?? 0,
      username: data['uname'] as String? ?? '',
      nickname: data['uname'] as String? ?? '',
      avatar: data['face'] as String? ?? '',
      isVip: (data['vipStatus'] as int? ?? 0) == 1,
      vipType: data['vipType'] as int? ?? 0,
      level: data['level_info']?['current_level'] as int? ?? 0,
      coins: (data['money'] as num?)?.toInt() ?? 0,
      isLogin: data['isLogin'] as bool? ?? false,
      signature: data['sign'] as String? ?? '',
      gender: _parseGender(data['sex'] as String?),
      birthday: data['birthday'] as String? ?? '',
    );
  }
  
  /// 解析性别
  static int _parseGender(String? sex) {
    switch (sex) {
      case '男':
        return 1;
      case '女':
        return 2;
      default:
        return 0;
    }
  }
  
  /// 从用户实体创建模型
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      username: entity.username,
      nickname: entity.nickname,
      avatar: entity.avatar,
      isVip: entity.isVip,
      vipType: entity.vipType,
      level: entity.level,
      coins: entity.coins,
      isLogin: entity.isLogin,
      signature: entity.signature,
      gender: entity.gender,
      birthday: entity.birthday,
    );
  }
  
  /// 空用户模型
  static const empty = UserModel(
    uid: 0,
    username: '',
    nickname: '',
    avatar: '',
    isVip: false,
    vipType: 0,
    level: 0,
    coins: 0,
    isLogin: false,
    signature: '',
    gender: 0,
    birthday: '',
  );
}