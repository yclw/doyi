import '../../core/utils/result.dart';
import '../entities/comment_entity.dart';
import '../repositories/auth_repository.dart';

/// 发送评论用例
class AddCommentUsecase {
  final AuthRepository _repository;
  
  const AddCommentUsecase(this._repository);
  
  /// 执行发送评论
  Future<Result<CommentAddResponseEntity>> call({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    int plat = 1,
  }) async {
    return await _repository.addComment(
      type: type,
      oid: oid,
      message: message,
      root: root,
      parent: parent,
      plat: plat,
    );
  }
} 