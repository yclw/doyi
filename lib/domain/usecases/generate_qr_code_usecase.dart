import 'package:dartz/dartz.dart';
import '../entities/qr_code_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

/// 生成二维码用例
class GenerateQrCodeUsecase {
  final AuthRepository _repository;
  
  GenerateQrCodeUsecase(this._repository);
  
  Future<Either<Failure, QrCodeEntity>> call() async {
    return await _repository.generateQrCode();
  }
} 