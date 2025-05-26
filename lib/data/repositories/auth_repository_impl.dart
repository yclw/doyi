import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, QrCodeEntity>> generateQrCode() async {
    try {
      final qrCode = await _qrLoginDatasource.generateQrCode();
      return Right(qrCode);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('生成二维码失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, QrStatusEntity>> pollQrStatus(String qrcodeKey) async {
    try {
      final status = await _qrLoginDatasource.pollQrStatus(qrcodeKey);
      
      // 如果登录成功，提取并保存Cookie
      if (status.isSuccess && status.url != null) {
        await _extractAndSaveCookie(status.url!);
      }
      
      return Right(status);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('轮询二维码状态失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getUserInfo() async {
    try {
      final user = await _userDatasource.getUserInfo();
      
      // 缓存用户信息
      await _localDatasource.cacheUserInfo(user);
      await _localDatasource.setLoginStatus(true);
      
      return Right(user);
    } on NetworkException catch (e) {
      // 网络异常时尝试从缓存获取
      return await _getCachedUserInfoWithFallback(e.message);
    } on AuthException catch (e) {
      // 认证失败，清除本地数据
      await _clearLocalData();
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('获取用户信息失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity?>> getCachedUserInfo() async {
    try {
      final user = await _localDatasource.getCachedUserInfo();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('获取缓存用户信息失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> checkLoginStatus() async {
    try {
      final isLoggedIn = await _userDatasource.checkLoginStatus();
      await _localDatasource.setLoginStatus(isLoggedIn);
      
      if (!isLoggedIn) {
        await _clearLocalData();
      }
      
      return Right(isLoggedIn);
    } on NetworkException {
      // 网络异常时从本地获取状态
      final localStatus = await _localDatasource.getLoginStatus();
      return Right(localStatus);
    } catch (e) {
      return Left(NetworkFailure('检查登录状态失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _clearLocalData();
      await _cookieManager.clearCookie();
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('退出登录失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, CommentListEntity>> getCommentList({
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
      return Right(commentList);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('获取评论列表失败: $e'));
    }
  }
  
  @override
  Future<Either<Failure, CommentReplyListEntity>> getCommentReplies({
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
      return Right(replyList);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('获取评论回复失败: $e'));
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
  Future<Either<Failure, UserEntity>> _getCachedUserInfoWithFallback(String errorMessage) async {
    try {
      final cachedUser = await _localDatasource.getCachedUserInfo();
      if (cachedUser != null) {
        return Right(cachedUser);
      } else {
        return Left(NetworkFailure(errorMessage));
      }
    } catch (e) {
      return Left(NetworkFailure(errorMessage));
    }
  }
} 