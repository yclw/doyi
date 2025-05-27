import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/cookie_manager.dart';
import '../../core/utils/logger.dart';

/// 评论数据源接口
abstract class CommentDatasource {
  Future<CommentListModel> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  });
  
  Future<CommentReplyListModel> getCommentReplies({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  });
  
  Future<CommentAddResponseModel> addComment({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  });
}

/// 评论数据源实现
class CommentDatasourceImpl implements CommentDatasource {
  final ApiClient _apiClient;
  final CookieManager _cookieManager;
  
  CommentDatasourceImpl(this._apiClient, this._cookieManager);
  
  @override
  Future<CommentListModel> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  }) async {
    try {
      Logger.d('开始获取评论列表: type=$type, oid=$oid, sort=$sort, ps=$ps, pn=$pn');
      
      final response = await _apiClient.get(
        AppConstants.commentListUrl,
        queryParameters: {
          'type': type,
          'oid': oid,
          'sort': sort,
          'nohot': nohot,
          'ps': ps,
          'pn': pn,
        },
        options: Options(
          headers: _buildHeaders(),
        ),
      );
      
      if (response.data == null) {
        throw const ServerException('评论列表响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      if (code != 0) {
        final message = data['message'] as String? ?? '获取评论列表失败';
        if (code == -101) {
          throw const AuthException('账号未登录');
        } else if (code == -400) {
          throw const ServerException('请求错误');
        } else if (code == -404) {
          throw const ServerException('无此项');
        } else if (code == -412) {
          throw const ServerException('请求被拦截，可能触发风控。请稍后重试或检查网络环境');
        } else if (code == 12002) {
          throw const ServerException('评论区已关闭');
        } else if (code == 12009) {
          throw const ServerException('评论主体的type不合法');
        }
        throw ServerException(message);
      }
      
      Logger.d('评论列表获取成功');
      return CommentListModel.fromBilibiliApiResponse(data);
    } on DioException catch (e) {
      Logger.e('获取评论列表网络错误: ${e.message}');
      throw NetworkException('获取评论列表失败: ${e.message}');
    } catch (e) {
      Logger.e('获取评论列表异常: $e');
      if (e is AppException) rethrow;
      throw ServerException('获取评论列表失败: $e');
    }
  }
  
  /// 构建请求头
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Referer': 'https://www.bilibili.com/',
    };
    
    final cookie = _cookieManager.getCookie();
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }
    
    return headers;
  }
  
  @override
  Future<CommentReplyListModel> getCommentReplies({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  }) async {
    try {
      Logger.d('开始获取评论回复: type=$type, oid=$oid, root=$root, ps=$ps, pn=$pn');
      
      final response = await _apiClient.get(
        AppConstants.commentReplyUrl,
        queryParameters: {
          'type': type,
          'oid': oid,
          'root': root,
          'ps': ps,
          'pn': pn,
        },
        options: Options(
          headers: _buildHeaders(),
        ),
      );
      
      if (response.data == null) {
        throw const ServerException('评论回复响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      if (code != 0) {
        final message = data['message'] as String? ?? '获取评论回复失败';
        if (code == -101) {
          throw const AuthException('账号未登录');
        } else if (code == -400) {
          throw const ServerException('请求错误');
        } else if (code == -404) {
          throw const ServerException('无此项');
        } else if (code == -412) {
          throw const ServerException('请求被拦截，可能触发风控。请稍后重试或检查网络环境');
        } else if (code == 12002) {
          throw const ServerException('评论区已关闭');
        } else if (code == 12009) {
          throw const ServerException('评论主体的type不合法');
        }
        throw ServerException(message);
      }
      
      Logger.d('评论回复获取成功');
      return CommentReplyListModel.fromBilibiliApiResponse(data);
    } on DioException catch (e) {
      Logger.e('获取评论回复网络错误: ${e.message}');
      throw NetworkException('获取评论回复失败: ${e.message}');
    } catch (e) {
      Logger.e('获取评论回复异常: $e');
      if (e is AppException) rethrow;
      throw ServerException('获取评论回复失败: $e');
    }
  }
  
  @override
  Future<CommentAddResponseModel> addComment({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  }) async {
    try {
      Logger.d('开始发送评论: type=$type, oid=$oid, message=$message, root=$root, parent=$parent');
      
      // 获取CSRF token
      final cookie = _cookieManager.getCookie();
      if (cookie == null) {
        throw const AuthException('未登录，无法发送评论');
      }
      
      // 从cookie中提取CSRF token
      final csrfMatch = RegExp(r'bili_jct=([^;]+)').firstMatch(cookie);
      final csrf = csrfMatch?.group(1);
      if (csrf == null) {
        throw const AuthException('无法获取CSRF token，请重新登录');
      }
      
      // 构建请求参数
      final formData = FormData.fromMap({
        'type': type,
        'oid': oid,
        'message': message,
        'plat': plat,
        'csrf': csrf,
        if (root != null) 'root': root,
        if (parent != null) 'parent': parent,
      });
      
      final response = await _apiClient.post(
        AppConstants.commentAddUrl,
        data: formData,
        options: Options(
          headers: _buildHeaders(),
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      
      if (response.data == null) {
        throw const ServerException('发送评论响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      if (code != 0) {
        final message = data['message'] as String? ?? '发送评论失败';
        if (code == -101) {
          throw const AuthException('账号未登录');
        } else if (code == -102) {
          throw const AuthException('账号被封停');
        } else if (code == -111) {
          throw const AuthException('CSRF校验失败');
        } else if (code == -400) {
          throw const ServerException('请求错误');
        } else if (code == -404) {
          throw const ServerException('无此项');
        } else if (code == -509) {
          throw const ServerException('请求过于频繁');
        } else if (code == 12001) {
          throw const ServerException('已经存在评论主题');
        } else if (code == 12002) {
          throw const ServerException('评论区已关闭');
        } else if (code == 12003) {
          throw const ServerException('禁止回复');
        } else if (code == 12006) {
          throw const ServerException('没有该评论');
        } else if (code == 12009) {
          throw const ServerException('评论主体的type不合法');
        } else if (code == 12015) {
          throw const ServerException('需要评论验证码');
        } else if (code == 12016) {
          throw const ServerException('评论内容包含敏感信息');
        } else if (code == 12025) {
          throw const ServerException('评论字数过多');
        } else if (code == 12035) {
          throw const ServerException('该账号被UP主列入评论黑名单');
        } else if (code == 12051) {
          throw const ServerException('重复评论，请勿刷屏');
        } else if (code == 12052) {
          throw const ServerException('评论区已关闭');
        } else if (code == 12045) {
          throw const ServerException('购买后即可发表评论');
        }
        throw ServerException(message);
      }
      
      Logger.d('评论发送成功');
      return CommentAddResponseModel.fromBilibiliApiResponse(data);
    } on DioException catch (e) {
      Logger.e('发送评论网络错误: ${e.message}');
      throw NetworkException('发送评论失败: ${e.message}');
    } catch (e) {
      Logger.e('发送评论异常: $e');
      if (e is AppException) rethrow;
      throw ServerException('发送评论失败: $e');
    }
  }
} 