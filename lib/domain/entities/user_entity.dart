import 'package:equatable/equatable.dart';

/// 用户实体
class UserEntity extends Equatable {
  final int uid;
  final String username;
  final String nickname;
  final String avatar;
  final bool isVip;
  final int vipType;
  final int level;
  final int coins;
  final bool isLogin;
  final String signature;
  final int gender;
  final String birthday;
  
  const UserEntity({
    required this.uid,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.isVip,
    required this.vipType,
    required this.level,
    required this.coins,
    required this.isLogin,
    required this.signature,
    required this.gender,
    required this.birthday,
  });
  
  @override
  List<Object> get props => [
    uid,
    username,
    nickname,
    avatar,
    isVip,
    vipType,
    level,
    coins,
    isLogin,
    signature,
    gender,
    birthday,
  ];
  
  /// 空用户
  static const empty = UserEntity(
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
  
  /// 是否为空用户
  bool get isEmpty => uid == 0;
  
  /// 是否不为空
  bool get isNotEmpty => !isEmpty;
} 