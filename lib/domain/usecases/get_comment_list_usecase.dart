import 'package:dartz/dartz.dart';
import '../entities/comment_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 获取评论列表用例
class GetCommentListUsecase {
  final AuthRepository _repository;
  
  GetCommentListUsecase(this._repository);
  
  Future<Either<Failure, CommentListEntity>> call({
    required int type,
    required int oid,
    int sort = 0,
    int nohot = 0,
    int ps = 20,
    int pn = 1,
  }) async {
    return await _repository.getCommentList(
      type: type,
      oid: oid,
      sort: sort,
      nohot: nohot,
      ps: ps,
      pn: pn,
    );
  }
} 