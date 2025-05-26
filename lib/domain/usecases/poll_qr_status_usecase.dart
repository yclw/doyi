import 'package:dartz/dartz.dart';
import '../entities/qr_code_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 轮询二维码状态用例
class PollQrStatusUsecase {
  final AuthRepository _repository;
  
  PollQrStatusUsecase(this._repository);
  
  Future<Either<Failure, QrStatusEntity>> call(String qrcodeKey) async {
    return await _repository.pollQrStatus(qrcodeKey);
  }
} 