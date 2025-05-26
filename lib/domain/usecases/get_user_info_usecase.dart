import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 获取用户信息用例
class GetUserInfoUsecase {
  final AuthRepository _repository;
  
  GetUserInfoUsecase(this._repository);
  
  Future<Either<Failure, UserEntity>> call() async {
    return await _repository.getUserInfo();
  }
} 