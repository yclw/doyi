import 'package:dartz/dartz.dart';
import '../entities/comment_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 获取评论回复用例
class GetCommentRepliesUsecase {
  final AuthRepository _repository;
  
  const GetCommentRepliesUsecase(this._repository);
  
  /// 执行获取评论回复
  Future<Either<Failure, CommentReplyListEntity>> call({
    required int type,
    required int oid,
    required int root,
    int ps = 20,
    int pn = 1,
  }) async {
    return await _repository.getCommentReplies(
      type: type,
      oid: oid,
      root: root,
      ps: ps,
      pn: pn,
    );
  }
} 