import 'package:flutter/foundation.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/get_comment_replies_usecase.dart';
import '../../core/errors/failures.dart';

/// 评论回复状态
enum CommentReplyState {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

/// 评论回复Provider
class CommentReplyProvider extends ChangeNotifier {
  final GetCommentRepliesUsecase _getCommentRepliesUsecase;
  
  CommentReplyProvider(this._getCommentRepliesUsecase);
  
  // 状态
  CommentReplyState _state = CommentReplyState.initial;
  CommentReplyState get state => _state;
  
  // 数据
  CommentEntity? _rootComment;
  CommentEntity? get rootComment => _rootComment;
  
  List<CommentEntity> _replies = [];
  List<CommentEntity> get replies => _replies;
  
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  int _totalCount = 0;
  int get totalCount => _totalCount;
  
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 请求参数
  int? _type;
  int? _oid;
  int? _root;
  
  /// 初始化并加载第一页回复
  Future<void> initialize({
    required int type,
    required int oid,
    required int root,
  }) async {
    _type = type;
    _oid = oid;
    _root = root;
    
    _state = CommentReplyState.loading;
    _currentPage = 1;
    _replies.clear();
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
    
    await _loadReplies();
  }
  
  /// 加载更多回复
  Future<void> loadMore() async {
    if (!_hasMore || _state == CommentReplyState.loadingMore) {
      return;
    }
    
    _state = CommentReplyState.loadingMore;
    notifyListeners();
    
    _currentPage++;
    await _loadReplies();
  }
  
  /// 刷新回复列表
  Future<void> refresh() async {
    _currentPage = 1;
    _replies.clear();
    _hasMore = true;
    _errorMessage = null;
    
    _state = CommentReplyState.loading;
    notifyListeners();
    
    await _loadReplies();
  }
  
  /// 加载回复数据
  Future<void> _loadReplies() async {
    if (_type == null || _oid == null || _root == null) {
      _state = CommentReplyState.error;
      _errorMessage = '参数错误';
      notifyListeners();
      return;
    }
    
    final result = await _getCommentRepliesUsecase(
      type: _type!,
      oid: _oid!,
      root: _root!,
      ps: 20,
      pn: _currentPage,
    );
    
    result.fold(
      (failure) {
        _state = CommentReplyState.error;
        _errorMessage = _getFailureMessage(failure);
        if (_currentPage > 1) {
          _currentPage--; // 回退页码
        }
        notifyListeners();
      },
      (replyList) {
        // 设置根评论（只在第一页时设置）
        if (_currentPage == 1) {
          _rootComment = replyList.root;
        }
        
        // 添加回复到列表
        if (_currentPage == 1) {
          _replies = replyList.replies;
        } else {
          _replies.addAll(replyList.replies);
        }
        
        // 更新分页信息
        _totalCount = replyList.page.count;
        _hasMore = replyList.replies.length >= 20;
        
        _state = CommentReplyState.loaded;
        notifyListeners();
      },
    );
  }
  
  /// 清除错误状态
  void clearError() {
    _errorMessage = null;
    if (_state == CommentReplyState.error) {
      _state = CommentReplyState.initial;
      notifyListeners();
    }
  }
  
  /// 获取失败信息
  String _getFailureMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return '网络连接失败，请检查网络设置';
    } else if (failure is AuthFailure) {
      return '认证失败，请重新登录';
    } else if (failure is ServerFailure) {
      return failure.message;
    }
    return '未知错误';
  }
} 