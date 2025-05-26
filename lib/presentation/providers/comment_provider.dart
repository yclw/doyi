import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/get_comment_list_usecase.dart';

/// 评论状态
enum CommentState {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

/// 评论状态管理
class CommentProvider extends ChangeNotifier {
  final GetCommentListUsecase _getCommentListUsecase;
  
  CommentProvider(this._getCommentListUsecase);
  
  // 状态
  CommentState _state = CommentState.initial;
  CommentListEntity? _commentList;
  String? _errorMessage;
  
  // 当前查询参数
  int _currentType = 1; // 默认视频类型
  int _currentOid = 0;
  int _currentSort = 0;
  int _currentPage = 1;
  
  // 分页控制
  bool _hasMorePages = true;
  int _lastPageSize = 20; // 记录最后一次请求返回的评论数量
  
  // Getters
  CommentState get state => _state;
  CommentListEntity? get commentList => _commentList;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CommentState.loading || _state == CommentState.loadingMore;
  bool get hasData => _commentList != null;
  
  List<CommentEntity> get allComments {
    if (_commentList == null) return [];
    return [..._commentList!.hots, ..._commentList!.replies];
  }
  
  List<CommentEntity> get hotComments => _commentList?.hots ?? [];
  List<CommentEntity> get normalComments {
    final comments = _commentList?.replies ?? [];
    Logger.d('CommentProvider: normalComments getter调用 - 返回${comments.length}条评论');
    return comments;
  }
  
  int get totalCount => _commentList?.page.count ?? 0;
  int get currentPage => _currentPage;
  bool get hasMorePages {
    Logger.d('CommentProvider: hasMorePages检查 - _hasMorePages:$_hasMorePages, 最后页大小:$_lastPageSize');
    return _hasMorePages;
  }
  
  /// 获取评论列表
  Future<void> getCommentList({
    required int type,
    required int oid,
    int sort = 0,
    int page = 1,
    bool isRefresh = false,
  }) async {
    Logger.d('CommentProvider: 开始获取评论列表 - type=$type, oid=$oid, sort=$sort, page=$page');
    
    // 如果是新的视频或者是刷新，清理旧数据
    if (page == 1 && (_currentOid != oid || isRefresh)) {
      _commentList = null;
      _errorMessage = null;
      _hasMorePages = true;
      _lastPageSize = 20;
    }
    
    if (isRefresh || _state == CommentState.initial) {
      _setState(CommentState.loading);
    } else if (page > 1) {
      // 加载更多时设置loadingMore状态
      _setState(CommentState.loadingMore);
    }
    
    _currentType = type;
    _currentOid = oid;
    _currentSort = sort;
    _currentPage = page;
    
    final result = await _getCommentListUsecase(
      type: type,
      oid: oid,
      sort: sort,
      ps: 20,
      pn: page,
    );
    
    result.fold(
      (failure) {
        Logger.e('CommentProvider: 获取评论列表失败 - ${failure.message}');
        _errorMessage = failure.message;
        _setState(CommentState.error);
      },
      (commentList) {
        Logger.d('CommentProvider: 评论列表获取成功 - 总数: ${commentList.page.count}');
        
        // 记录当前页返回的评论数量
        final currentPageRepliesCount = commentList.replies.length;
        _lastPageSize = currentPageRepliesCount;
        
        // 判断是否还有更多页面 - 使用多重判断逻辑
        if (currentPageRepliesCount == 0) {
          // 如果返回0条评论，肯定没有更多了
          _hasMorePages = false;
        } else if (page == 1 || isRefresh) {
          // 第一页：通过总数和已加载数量判断
          final totalRootCount = commentList.page.count;
          final loadedCount = currentPageRepliesCount;
          _hasMorePages = loadedCount >= 20 && loadedCount < totalRootCount;
        } else {
          // 后续页面：如果返回的评论数量小于20，说明是最后一页
          // 同时也要检查累计加载数量是否已达到总数
          final totalRootCount = commentList.page.count;
          final totalLoadedCount = (_commentList?.replies.length ?? 0) + currentPageRepliesCount;
          _hasMorePages = currentPageRepliesCount >= 20 && totalLoadedCount < totalRootCount;
        }
        
        if (page == 1 || isRefresh) {
          _commentList = commentList;
          _currentPage = page;
          Logger.d('CommentProvider: 设置第一页数据 - 热评:${commentList.hots.length}, 普通评论:${commentList.replies.length}, 总根评论数:${commentList.page.count}, 还有更多:$_hasMorePages');
        } else {
          // 加载更多，合并数据
          if (_commentList != null) {
            final oldRepliesCount = _commentList!.replies.length;
            final newRepliesCount = commentList.replies.length;
            
            // 创建新的合并列表
            final mergedReplies = List<CommentEntity>.from(_commentList!.replies);
            mergedReplies.addAll(commentList.replies);
            
            _commentList = CommentListEntity(
              page: commentList.page,
              replies: mergedReplies,
              hots: _commentList!.hots, // 热评只在第一页显示
            );
            _currentPage = page; // 更新当前页码
            
            Logger.d('CommentProvider: 合并数据完成 - 原有:$oldRepliesCount, 新增:$newRepliesCount, 总计:${_commentList!.replies.length}, 总根评论数:${commentList.page.count}, 还有更多:$_hasMorePages');
          } else {
            _commentList = commentList;
            _currentPage = page;
            Logger.d('CommentProvider: 首次设置数据 - 普通评论:${commentList.replies.length}, 还有更多:$_hasMorePages');
          }
        }
        
        _setState(CommentState.loaded);
        // 强制通知监听器，确保UI更新
        notifyListeners();
      },
    );
  }
  
  /// 刷新评论
  Future<void> refreshComments() async {
    if (_currentOid == 0) return;
    
    await getCommentList(
      type: _currentType,
      oid: _currentOid,
      sort: _currentSort,
      page: 1,
      isRefresh: true,
    );
  }
  
  /// 加载更多评论
  Future<void> loadMoreComments() async {
    Logger.d('CommentProvider: 尝试加载更多评论 - currentPage=$_currentPage, hasMorePages=$hasMorePages, isLoading=$isLoading');
    
    if (_currentOid == 0 || !hasMorePages || isLoading) {
      Logger.d('CommentProvider: 无法加载更多 - oid=$_currentOid, hasMore=$hasMorePages, loading=$isLoading');
      return;
    }
    
    final nextPage = _currentPage + 1;
                Logger.d('CommentProvider: 开始加载第$nextPage页评论');
    
    await getCommentList(
      type: _currentType,
      oid: _currentOid,
      sort: _currentSort,
      page: nextPage,
    );
  }
  
  /// 切换排序方式
  Future<void> changeSortType(int sort) async {
    if (_currentOid == 0 || _currentSort == sort) return;
    
    await getCommentList(
      type: _currentType,
      oid: _currentOid,
      sort: sort,
      page: 1,
      isRefresh: true,
    );
  }
  
  /// 清除错误
  void clearError() {
    _errorMessage = null;
    if (_state == CommentState.error) {
      _setState(CommentState.initial);
    }
  }
  
  /// 重置状态
  void reset() {
    _commentList = null;
    _errorMessage = null;
    _currentOid = 0;
    _currentPage = 1;
    _currentType = 1;
    _currentSort = 0;
    _hasMorePages = true;
    _lastPageSize = 20;
    _setState(CommentState.initial);
  }
  
  /// 设置状态
  void _setState(CommentState state) {
    if (_state != state) {
      _state = state;
      notifyListeners();
    }
  }
} 