import '../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../entities/qr_code_entity.dart';
import '../entities/comment_entity.dart';

/// 认证仓库接口
abstract class AuthRepository {
  /// 生成二维码
  Future<Result<QrCodeEntity>> generateQrCode();
  
  /// 轮询二维码状态
  Future<Result<QrStatusEntity>> pollQrStatus(String qrcodeKey);
  
  /// 获取用户信息
  Future<Result<UserEntity>> getUserInfo();
  
  /// 获取缓存的用户信息
  Future<Result<UserEntity?>> getCachedUserInfo();
  
  /// 检查登录状态
  Future<Result<bool>> checkLoginStatus();
  
  /// 退出登录
  Future<Result<bool>> logout();
  
  /// 获取评论列表
  Future<Result<CommentListEntity>> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  });
  
  /// 获取评论回复
  Future<Result<CommentReplyListEntity>> getCommentReplies({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  });
  
  /// 发送评论
  Future<Result<CommentAddResponseEntity>> addComment({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  });
} 