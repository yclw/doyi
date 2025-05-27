import '../../core/utils/result.dart';
import '../entities/qr_code_entity.dart';
import '../repositories/auth_repository.dart';

/// 生成二维码用例
class GenerateQrCodeUsecase {
  final AuthRepository _repository;
  
  GenerateQrCodeUsecase(this._repository);
  
  Future<Result<QrCodeEntity>> call() async {
    return await _repository.generateQrCode();
  }
} 