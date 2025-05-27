import '../../core/utils/result.dart';
import '../entities/qr_code_entity.dart';
import '../repositories/auth_repository.dart';

/// 轮询二维码状态用例
class PollQrStatusUsecase {
  final AuthRepository _repository;
  
  PollQrStatusUsecase(this._repository);
  
  Future<Result<QrStatusEntity>> call(String qrcodeKey) async {
    return await _repository.pollQrStatus(qrcodeKey);
  }
} 