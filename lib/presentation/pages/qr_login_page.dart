import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr/qr.dart';
import '../providers/auth_provider.dart';

/// 二维码登录页面
class QrLoginPage extends StatefulWidget {
  const QrLoginPage({super.key});
  
  @override
  State<QrLoginPage> createState() => _QrLoginPageState();
}

class _QrLoginPageState extends State<QrLoginPage> {
  Timer? _successTimeoutTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().resetQrState();
    });
  }
  
  @override
  void dispose() {
    _successTimeoutTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码登录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 监听登录成功状态
          if (authProvider.qrState == QrState.success) {
            if (authProvider.isAuthenticated) {
              // 用户信息获取成功，立即返回
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop(true);
              });
            } else {
              // 开始超时计时器，防止一直卡在登录成功状态
              _successTimeoutTimer?.cancel();
              _successTimeoutTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              });
            }
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBody(authProvider),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(AuthProvider authProvider) {
    switch (authProvider.qrState) {
      case QrState.initial:
        return _buildInitialState();
        
      case QrState.generating:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在生成二维码...'),
            ],
          ),
        );
        
      case QrState.generated:
      case QrState.polling:
        return _buildQrCodeState(authProvider);
        
      case QrState.scanned:
        return _buildScannedState();
        
      case QrState.success:
        return _buildSuccessState();
        
      case QrState.expired:
        return _buildExpiredState(authProvider);
        
      case QrState.error:
        return _buildErrorState(authProvider);
    }
  }
  
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '点击下方按钮生成登录二维码',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<AuthProvider>().generateQrCode(),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('生成二维码'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQrCodeState(AuthProvider authProvider) {
    final qrCode = authProvider.qrCode;
    if (qrCode == null) return _buildInitialState();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildQrCode(qrCode.url),
                  const SizedBox(height: 16),
                  Text(
                    _getQrStatusText(authProvider.qrState),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '请使用B站手机客户端扫描二维码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (authProvider.qrState == QrState.polling)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('等待扫码...'),
              ],
            ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.read<AuthProvider>().generateQrCode(),
            child: const Text('重新生成'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScannedState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.orange,
          ),
          SizedBox(height: 16),
          Text(
            '扫码成功！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请在手机上确认登录',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildSuccessState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          SizedBox(height: 16),
          Text(
            '登录成功！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '正在获取用户信息...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildExpiredState(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            '二维码已过期',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.qrErrorMessage ?? '请重新生成二维码',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<AuthProvider>().generateQrCode(),
            icon: const Icon(Icons.refresh),
            label: const Text('重新生成'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            authProvider.qrErrorMessage ?? '二维码生成失败',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              authProvider.clearQrError();
              authProvider.generateQrCode();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  String _getQrStatusText(QrState state) {
    switch (state) {
      case QrState.generated:
        return '请扫描二维码';
      case QrState.polling:
        return '等待扫码...';
      default:
        return '二维码已生成';
    }
  }
  
  /// 构建二维码组件
  Widget _buildQrCode(String data) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      
      final qrImage = QrImage(qrCode);
      
      return Container(
        width: 200.0,
        height: 200.0,
        color: Colors.white,
        child: CustomPaint(
          size: const Size(200.0, 200.0),
          painter: QrPainter(qrImage),
        ),
      );
    } catch (e) {
      return Container(
        width: 200.0,
        height: 200.0,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            '二维码生成失败',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}

/// 二维码绘制器
class QrPainter extends CustomPainter {
  final QrImage qrImage;
  
  QrPainter(this.qrImage);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;
    
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            x * moduleSize,
            y * moduleSize,
            moduleSize,
            moduleSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 