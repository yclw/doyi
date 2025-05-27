import '../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 获取用户信息用例
class GetUserInfoUsecase {
  final AuthRepository _repository;
  
  GetUserInfoUsecase(this._repository);
  
  Future<Result<UserEntity>> call() async {
    return await _repository.getUserInfo();
  }
} 