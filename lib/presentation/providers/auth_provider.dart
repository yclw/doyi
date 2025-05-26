import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/qr_code_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/generate_qr_code_usecase.dart';
import '../../domain/usecases/get_user_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/poll_qr_status_usecase.dart';

/// 认证状态
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 二维码状态
enum QrState {
  initial,
  generating,
  generated,
  polling,
  scanned,
  success,
  expired,
  error,
}

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  final GenerateQrCodeUsecase _generateQrCodeUsecase;
  final PollQrStatusUsecase _pollQrStatusUsecase;
  final GetUserInfoUsecase _getUserInfoUsecase;
  final LogoutUsecase _logoutUsecase;
  
  AuthProvider(
    this._generateQrCodeUsecase,
    this._pollQrStatusUsecase,
    this._getUserInfoUsecase,
    this._logoutUsecase,
  );
  
  // 认证状态
  AuthState _authState = AuthState.initial;
  UserEntity _user = UserEntity.empty;
  String? _errorMessage;
  
  // 二维码状态
  QrState _qrState = QrState.initial;
  QrCodeEntity? _qrCode;
  String? _qrErrorMessage;
  Timer? _pollTimer;
  
  // Getters
  AuthState get authState => _authState;
  UserEntity get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated && _user.isNotEmpty;
  bool get isLoading => _authState == AuthState.loading;
  
  QrState get qrState => _qrState;
  QrCodeEntity? get qrCode => _qrCode;
  String? get qrErrorMessage => _qrErrorMessage;
  bool get isQrLoading => _qrState == QrState.generating || _qrState == QrState.polling;
  
  /// 初始化
  Future<void> initialize() async {
    Logger.d('AuthProvider: 开始初始化');
    _setAuthState(AuthState.loading);
    
    try {
      await getUserInfo();
    } catch (e) {
      Logger.e('AuthProvider: 初始化失败 - $e');
      _setAuthState(AuthState.unauthenticated);
    }
  }
  
  /// 生成二维码
  Future<void> generateQrCode() async {
    Logger.d('AuthProvider: 开始生成二维码');
    _setQrState(QrState.generating);
    
    final result = await _generateQrCodeUsecase();
    
    result.fold(
      (failure) {
        Logger.e('AuthProvider: 生成二维码失败 - ${failure.message}');
        _qrErrorMessage = failure.message;
        _setQrState(QrState.error);
      },
      (qrCode) {
        Logger.d('AuthProvider: 二维码生成成功');
        _qrCode = qrCode;
        _setQrState(QrState.generated);
        _startPolling();
      },
    );
  }
  
  /// 开始轮询二维码状态
  void _startPolling() {
    if (_qrCode == null) return;
    
    Logger.d('AuthProvider: 开始轮询二维码状态');
    _setQrState(QrState.polling);
    
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConstants.qrPollInterval, (timer) async {
      await _pollQrStatus();
    });
  }
  
  /// 轮询二维码状态
  Future<void> _pollQrStatus() async {
    if (_qrCode == null) return;
    
    final result = await _pollQrStatusUsecase(_qrCode!.qrcodeKey);
    
    result.fold(
      (failure) {
        Logger.e('AuthProvider: 轮询失败 - ${failure.message}');
        _stopPolling();
        _qrErrorMessage = failure.message;
        _setQrState(QrState.error);
      },
      (status) {
        Logger.d('AuthProvider: 轮询状态 - ${status.code}: ${status.message}');
        
        if (status.isNotScanned) {
          // 未扫码，继续轮询
          return;
        } else if (status.isScanned) {
          // 已扫码未确认
          _setQrState(QrState.scanned);
        } else if (status.isExpired) {
          // 二维码过期
          _stopPolling();
          _qrErrorMessage = '二维码已过期，请重新生成';
          _setQrState(QrState.expired);
        } else if (status.isSuccess) {
          // 登录成功
          _stopPolling();
          _setQrState(QrState.success);
          _handleLoginSuccess();
        }
      },
    );
  }
  
  /// 处理登录成功
  Future<void> _handleLoginSuccess() async {
    Logger.d('AuthProvider: 处理登录成功');
    try {
      await getUserInfo();
    } catch (e) {
      Logger.e('AuthProvider: 登录成功后获取用户信息失败 - $e');
      // 即使获取用户信息失败，也要确保状态正确
      _setAuthState(AuthState.unauthenticated);
    }
  }
  
  /// 停止轮询
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
  
  /// 获取用户信息
  Future<void> getUserInfo() async {
    Logger.d('AuthProvider: 开始获取用户信息');
    _setAuthState(AuthState.loading);
    
    try {
      final result = await _getUserInfoUsecase();
      
      result.fold(
        (failure) {
          Logger.e('AuthProvider: 获取用户信息失败 - ${failure.message}');
          _errorMessage = failure.message;
          _setAuthState(AuthState.unauthenticated);
        },
        (user) {
          Logger.d('AuthProvider: 获取用户信息成功 - ${user.nickname}');
          _user = user;
          _setAuthState(AuthState.authenticated);
          _errorMessage = null; // 清除之前的错误信息
        },
      );
    } catch (e) {
      Logger.e('AuthProvider: 获取用户信息异常 - $e');
      _errorMessage = '网络连接异常，请检查网络设置';
      _setAuthState(AuthState.unauthenticated);
    }
  }
  
  /// 退出登录
  Future<void> logout() async {
    Logger.d('AuthProvider: 开始退出登录');
    _setAuthState(AuthState.loading);
    
    final result = await _logoutUsecase();
    
    result.fold(
      (failure) {
        Logger.e('AuthProvider: 退出登录失败 - ${failure.message}');
        _errorMessage = failure.message;
        _setAuthState(AuthState.error);
      },
      (_) {
        Logger.d('AuthProvider: 退出登录成功');
        _user = UserEntity.empty;
        _setAuthState(AuthState.unauthenticated);
        _resetQrState();
      },
    );
  }
  
  /// 重置二维码状态
  void resetQrState() {
    _resetQrState();
  }
  
  void _resetQrState() {
    _stopPolling();
    _qrCode = null;
    _qrErrorMessage = null;
    _setQrState(QrState.initial);
  }
  
  /// 清除错误
  void clearError() {
    _errorMessage = null;
    if (_authState == AuthState.error) {
      _setAuthState(AuthState.unauthenticated);
    }
  }
  
  /// 清除二维码错误
  void clearQrError() {
    _qrErrorMessage = null;
    if (_qrState == QrState.error) {
      _setQrState(QrState.initial);
    }
  }
  
  /// 设置认证状态
  void _setAuthState(AuthState state) {
    if (_authState != state) {
      _authState = state;
      notifyListeners();
    }
  }
  
  /// 设置二维码状态
  void _setQrState(QrState state) {
    if (_qrState != state) {
      _qrState = state;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
} 