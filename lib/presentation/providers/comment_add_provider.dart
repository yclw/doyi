import 'package:flutter/foundation.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../core/errors/failures.dart';

/// 评论发送状态
enum CommentAddState {
  initial,
  sending,
  success,
  error,
}

/// 评论发送Provider
class CommentAddProvider extends ChangeNotifier {
  final AddCommentUsecase _addCommentUsecase;
  
  CommentAddProvider(this._addCommentUsecase);
  
  // 状态
  CommentAddState _state = CommentAddState.initial;
  CommentAddState get state => _state;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  CommentAddResponseEntity? _response;
  CommentAddResponseEntity? get response => _response;
  
  bool get isLoading => _state == CommentAddState.sending;
  bool get isSuccess => _state == CommentAddState.success;
  bool get hasError => _state == CommentAddState.error;
  
  /// 发送评论
  Future<bool> addComment({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  }) async {
    _state = CommentAddState.sending;
    _errorMessage = null;
    _response = null;
    notifyListeners();
    
    final result = await _addCommentUsecase(
      type: type,
      oid: oid,
      message: message,
      root: root,
      parent: parent,
      plat: plat,
    );
    
    return result.fold(
      (failure) {
        _state = CommentAddState.error;
        _errorMessage = _getFailureMessage(failure);
        notifyListeners();
        return false;
      },
      (response) {
        _state = CommentAddState.success;
        _response = response;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// 重置状态
  void reset() {
    _state = CommentAddState.initial;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
  
  /// 清除错误状态
  void clearError() {
    if (_state == CommentAddState.error) {
      _state = CommentAddState.initial;
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// 获取失败信息
  String _getFailureMessage(Failure failure) {
    switch (failure) {
      case NetworkFailure _:
        return '网络连接失败，请检查网络设置';
      case ServerFailure _:
        return failure.message;
      case AuthFailure _:
        return '请先登录后再发表评论';
      case CacheFailure _:
        return '本地数据错误';
      default:
        return '发送评论失败，请稍后重试';
    }
  }
} 