import 'package:flutter/foundation.dart';
import '../../domain/entities/comment_entity.dart';

/// 评论搜索状态
enum CommentSearchState {
  initial,
  searching,
  found,
  notFound,
  error,
}

/// 评论搜索Provider
class CommentSearchProvider extends ChangeNotifier {
  CommentSearchProvider();
  
  // 状态
  CommentSearchState _state = CommentSearchState.initial;
  CommentSearchState get state => _state;
  
  // 搜索结果
  List<CommentEntity> _searchResults = [];
  List<CommentEntity> get searchResults => _searchResults;
  
  // 搜索条件
  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;
  
  String _searchType = 'all'; // all, username, content
  String get searchType => _searchType;
  
  // 原始评论数据
  List<CommentEntity> _allComments = [];
  
  bool get isSearching => _state == CommentSearchState.searching;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get isSearchActive => _searchKeyword.isNotEmpty;
  
  /// 设置要搜索的评论数据
  void setComments(List<CommentEntity> comments) {
    _allComments = comments;
    // 如果当前有搜索关键词，重新执行搜索
    if (_searchKeyword.isNotEmpty) {
      _performSearch();
    }
  }
  
  /// 执行搜索
  void search(String keyword, {String type = 'all'}) {
    _searchKeyword = keyword.trim();
    _searchType = type;
    
    if (_searchKeyword.isEmpty) {
      clearSearch();
      return;
    }
    
    _performSearch();
  }
  
  /// 执行实际的搜索逻辑
  void _performSearch() {
    _state = CommentSearchState.searching;
    notifyListeners();
    
    try {
      final keyword = _searchKeyword.toLowerCase();
      final results = <CommentEntity>[];
      
      // 搜索所有评论（包括回复）
      _searchInComments(_allComments, keyword, results);
      
      _searchResults = results;
      _state = results.isEmpty 
          ? CommentSearchState.notFound 
          : CommentSearchState.found;
      
    } catch (e) {
      _state = CommentSearchState.error;
    }
    
    notifyListeners();
  }
  
  /// 递归搜索评论及其回复
  void _searchInComments(List<CommentEntity> comments, String keyword, List<CommentEntity> results) {
    for (final comment in comments) {
      bool matches = false;
      
      switch (_searchType) {
        case 'username':
          matches = comment.member.uname.toLowerCase().contains(keyword);
          break;
        case 'content':
          matches = comment.content.message.toLowerCase().contains(keyword);
          break;
        case 'all':
        default:
          matches = comment.member.uname.toLowerCase().contains(keyword) ||
                   comment.content.message.toLowerCase().contains(keyword);
          break;
      }
      
      if (matches) {
        results.add(comment);
      }
      
      // 递归搜索回复
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        _searchInComments(comment.replies!, keyword, results);
      }
    }
  }
  
  /// 清除搜索
  void clearSearch() {
    _searchKeyword = '';
    _searchResults.clear();
    _state = CommentSearchState.initial;
    notifyListeners();
  }
  
  /// 设置搜索类型
  void setSearchType(String type) {
    if (_searchType != type) {
      _searchType = type;
      if (_searchKeyword.isNotEmpty) {
        _performSearch();
      }
    }
  }
  
  /// 获取搜索结果统计
  Map<String, int> getSearchStats() {
    if (_searchResults.isEmpty) {
      return {'total': 0, 'username': 0, 'content': 0};
    }
    
    final keyword = _searchKeyword.toLowerCase();
    int usernameMatches = 0;
    int contentMatches = 0;
    
    for (final comment in _searchResults) {
      if (comment.member.uname.toLowerCase().contains(keyword)) {
        usernameMatches++;
      }
      if (comment.content.message.toLowerCase().contains(keyword)) {
        contentMatches++;
      }
    }
    
    return {
      'total': _searchResults.length,
      'username': usernameMatches,
      'content': contentMatches,
    };
  }
} 