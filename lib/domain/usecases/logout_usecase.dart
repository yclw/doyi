import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 退出登录用例
class LogoutUsecase {
  final AuthRepository _repository;
  
  LogoutUsecase(this._repository);
  
  Future<Either<Failure, bool>> call() async {
    return await _repository.logout();
  }
} 