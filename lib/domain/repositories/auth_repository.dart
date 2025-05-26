import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../entities/qr_code_entity.dart';
import '../entities/comment_entity.dart';
import '../../core/errors/failures.dart';

/// 认证仓库接口
abstract class AuthRepository {
  /// 生成二维码
  Future<Either<Failure, QrCodeEntity>> generateQrCode();
  
  /// 轮询二维码状态
  Future<Either<Failure, QrStatusEntity>> pollQrStatus(String qrcodeKey);
  
  /// 获取用户信息
  Future<Either<Failure, UserEntity>> getUserInfo();
  
  /// 获取缓存的用户信息
  Future<Either<Failure, UserEntity?>> getCachedUserInfo();
  
  /// 检查登录状态
  Future<Either<Failure, bool>> checkLoginStatus();
  
  /// 退出登录
  Future<Either<Failure, bool>> logout();
  
  /// 获取评论列表
  Future<Either<Failure, CommentListEntity>> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  });
  
  /// 获取评论回复
  Future<Either<Failure, CommentReplyListEntity>> getCommentReplies({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  });
} 