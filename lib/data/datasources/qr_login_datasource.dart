import 'package:dio/dio.dart';
import '../models/qr_code_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';

/// 二维码登录数据源接口
abstract class QrLoginDatasource {
  Future<QrCodeModel> generateQrCode();
  Future<QrStatusModel> pollQrStatus(String qrcodeKey);
}

/// 二维码登录数据源实现
class QrLoginDatasourceImpl implements QrLoginDatasource {
  final ApiClient _apiClient;
  
  QrLoginDatasourceImpl(this._apiClient);
  
  @override
  Future<QrCodeModel> generateQrCode() async {
    try {
      Logger.d('开始申请二维码');
      
      final response = await _apiClient.get(
        AppConstants.qrGenerateUrl,
        options: Options(
          headers: {
            'Referer': 'https://www.bilibili.com/',
          },
        ),
      );
      
      Logger.d('二维码申请响应: ${response.statusCode}');
      
      if (response.data == null) {
        Logger.e('二维码申请响应数据为空');
        throw const ServerException('二维码申请响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      Logger.d('二维码申请响应数据: $data');
      
      final code = data['code'] as int?;
      
      if (code != 0) {
        final message = data['message'] as String? ?? '申请二维码失败';
        Logger.e('二维码申请失败: code=$code, message=$message');
        throw ServerException(message);
      }
      
      Logger.d('二维码申请成功');
      return QrCodeModel.fromBilibiliApiResponse(data);
    } on DioException catch (e) {
      Logger.e('申请二维码网络错误: ${e.message}');
      Logger.e('DioException详情: ${e.toString()}');
      throw NetworkException('申请二维码失败: ${e.message ?? '网络连接错误'}');
    } on AppException catch (e) {
      Logger.e('申请二维码应用异常: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.e('申请二维码未知异常: ${e.toString()}');
      Logger.e('异常类型: ${e.runtimeType}');
      throw ServerException('申请二维码失败: ${e?.toString() ?? '未知错误'}');
    }
  }
  
  @override
  Future<QrStatusModel> pollQrStatus(String qrcodeKey) async {
    try {
      Logger.d('轮询二维码状态: $qrcodeKey');
      
      final response = await _apiClient.get(
        AppConstants.qrPollUrl,
        queryParameters: {
          'qrcode_key': qrcodeKey,
        },
        options: Options(
          headers: {
            'Referer': 'https://www.bilibili.com/',
          },
        ),
      );
      
      Logger.d('轮询响应: ${response.statusCode}');
      
      if (response.data == null) {
        Logger.e('轮询响应数据为空');
        throw const ServerException('轮询响应为空');
      }
      
      final data = response.data as Map<String, dynamic>;
      Logger.d('轮询响应数据: $data');
      
      final rootCode = data['code'] as int?;
      
      if (rootCode != 0) {
        final message = data['message'] as String? ?? '轮询失败';
        Logger.e('轮询失败: code=$rootCode, message=$message');
        throw ServerException(message);
      }
      
      final statusModel = QrStatusModel.fromBilibiliApiResponse(data);
      Logger.d('轮询状态: ${statusModel.code} - ${statusModel.message}');
      
      return statusModel;
    } on DioException catch (e) {
      Logger.e('轮询二维码状态网络错误: ${e.message}');
      Logger.e('DioException详情: ${e.toString()}');
      throw NetworkException('轮询二维码状态失败: ${e.message ?? '网络连接错误'}');
    } on AppException catch (e) {
      Logger.e('轮询二维码状态应用异常: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.e('轮询二维码状态未知异常: ${e.toString()}');
      Logger.e('异常类型: ${e.runtimeType}');
      throw ServerException('轮询二维码状态失败: ${e?.toString() ?? '未知错误'}');
    }
  }
} 