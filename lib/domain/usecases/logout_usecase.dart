import '../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// 退出登录用例
class LogoutUsecase {
  final AuthRepository _repository;
  
  LogoutUsecase(this._repository);
  
  Future<Result<bool>> call() async {
    return await _repository.logout();
  }
} 