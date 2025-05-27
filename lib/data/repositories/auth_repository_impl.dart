import '../../core/utils/result.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/cookie_manager.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/qr_code_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/qr_login_datasource.dart';
import '../datasources/user_datasource.dart';
import '../datasources/comment_datasource.dart';

/// 认证仓库实现
class AuthRepositoryImpl implements AuthRepository {
  final QrLoginDatasource _qrLoginDatasource;
  final UserDatasource _userDatasource;
  final LocalDatasource _localDatasource;
  final CookieManager _cookieManager;
  final CommentDatasource _commentDatasource;
  
  AuthRepositoryImpl(
    this._qrLoginDatasource,
    this._userDatasource,
    this._localDatasource,
    this._cookieManager,
    this._commentDatasource,
  );
  
  @override
  Future<Result<QrCodeEntity>> generateQrCode() async {
    try {
      final qrCode = await _qrLoginDatasource.generateQrCode();
      return Result.success(qrCode);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('生成二维码失败: $e'));
    }
  }
  
  @override
  Future<Result<QrStatusEntity>> pollQrStatus(String qrcodeKey) async {
    try {
      final status = await _qrLoginDatasource.pollQrStatus(qrcodeKey);
      
      // 如果登录成功，提取并保存Cookie
      if (status.isSuccess && status.url != null) {
        await _extractAndSaveCookie(status.url!);
      }
      
      return Result.success(status);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('轮询二维码状态失败: $e'));
    }
  }
  
  @override
  Future<Result<UserEntity>> getUserInfo() async {
    try {
      final user = await _userDatasource.getUserInfo();
      
      // 缓存用户信息
      await _localDatasource.cacheUserInfo(user);
      await _localDatasource.setLoginStatus(true);
      
      return Result.success(user);
    } on NetworkException catch (e) {
      // 网络异常时尝试从缓存获取
      return await _getCachedUserInfoWithFallback(e.message);
    } on AuthException catch (e) {
      // 认证失败，清除本地数据
      await _clearLocalData();
      return Result.failure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('获取用户信息失败: $e'));
    }
  }
  
  @override
  Future<Result<UserEntity?>> getCachedUserInfo() async {
    try {
      final user = await _localDatasource.getCachedUserInfo();
      return Result.success(user);
    } catch (e) {
      return Result.failure(CacheFailure('获取缓存用户信息失败: $e'));
    }
  }
  
  @override
  Future<Result<bool>> checkLoginStatus() async {
    try {
      final isLoggedIn = await _userDatasource.checkLoginStatus();
      await _localDatasource.setLoginStatus(isLoggedIn);
      
      if (!isLoggedIn) {
        await _clearLocalData();
      }
      
      return Result.success(isLoggedIn);
    } on NetworkException {
      // 网络异常时从本地获取状态
      final localStatus = await _localDatasource.getLoginStatus();
      return Result.success(localStatus);
    } catch (e) {
      return Result.failure(NetworkFailure('检查登录状态失败: $e'));
    }
  }
  
  @override
  Future<Result<bool>> logout() async {
    try {
      await _clearLocalData();
      await _cookieManager.clearCookie();
      return const Result.success(true);
    } catch (e) {
      return Result.failure(CacheFailure('退出登录失败: $e'));
    }
  }
  
  @override
  Future<Result<CommentListEntity>> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  }) async {
    try {
      final commentList = await _commentDatasource.getCommentList(
        type: type,
        oid: oid,
        sort: sort,
        nohot: nohot,
        ps: ps,
        pn: pn,
      );
      return Result.success(commentList);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('获取评论列表失败: $e'));
    }
  }
  
  @override
  Future<Result<CommentReplyListEntity>> getCommentReplies({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  }) async {
    try {
      final replyList = await _commentDatasource.getCommentReplies(
        type: type,
        oid: oid,
        root: root,
        ps: ps,
        pn: pn,
      );
      return Result.success(replyList);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('获取评论回复失败: $e'));
    }
  }
  
  @override
  Future<Result<CommentAddResponseEntity>> addComment({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  }) async {
    try {
      final response = await _commentDatasource.addComment(
        type: type,
        oid: oid,
        message: message,
        root: root,
        parent: parent,
        plat: plat,
      );
      return Result.success(response);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('发送评论失败: $e'));
    }
  }
  
  /// 提取并保存Cookie
  Future<void> _extractAndSaveCookie(String url) async {
    try {
      // 从URL中提取Cookie参数
      final uri = Uri.parse(url);
      final cookies = <String>[];
      
      uri.queryParameters.forEach((key, value) {
        if (['SESSDATA', 'DedeUserID', 'bili_jct', 'DedeUserID__ckMd5'].contains(key)) {
          cookies.add('$key=$value');
        }
      });
      
      if (cookies.isNotEmpty) {
        final cookieString = cookies.join('; ');
        await _cookieManager.saveCookie(cookieString);
        Logger.i('Cookie保存成功: ${cookieString.length}字符');
      }
    } catch (e) {
      Logger.e('提取Cookie失败: $e');
    }
  }
  
  /// 清除本地数据
  Future<void> _clearLocalData() async {
    try {
      await _localDatasource.clearAll();
    } catch (e) {
      Logger.e('清除本地数据失败: $e');
    }
  }
  
  /// 网络异常时从缓存获取用户信息
  Future<Result<UserEntity>> _getCachedUserInfoWithFallback(String errorMessage) async {
    try {
      final cachedUser = await _localDatasource.getCachedUserInfo();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      } else {
        return Result.failure(NetworkFailure(errorMessage));
      }
    } catch (e) {
      return Result.failure(NetworkFailure(errorMessage));
    }
  }
} 