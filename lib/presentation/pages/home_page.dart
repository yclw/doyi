import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_info_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'qr_login_page.dart';
import 'comment_page.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _videoController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }
  
  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B站登录助手'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: '退出登录',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return RefreshIndicator(
            onRefresh: () => authProvider.getUserInfo(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: _buildBody(authProvider),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(AuthProvider authProvider) {
    switch (authProvider.authState) {
      case AuthState.loading:
        return const Center(
          child: LoadingWidget(message: '加载中...'),
        );
        
      case AuthState.authenticated:
        return Column(
          children: [
            UserInfoCard(user: authProvider.user),
            const SizedBox(height: 24),
            _buildVideoInputCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        );
        
      case AuthState.unauthenticated:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                '请先登录B站账号',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToQrLogin(),
                icon: const Icon(Icons.qr_code),
                label: const Text('扫码登录'),
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
        
      case AuthState.error:
        return Center(
          child: AppErrorWidget(
            message: authProvider.errorMessage ?? '未知错误',
            onRetry: () {
              authProvider.clearError();
              authProvider.initialize();
            },
          ),
        );
        
      default:
        return const Center(
          child: LoadingWidget(message: '初始化中...'),
        );
    }
  }
  
  Widget _buildVideoInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '查看视频评论',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _videoController,
              decoration: const InputDecoration(
                labelText: '视频链接或AV号',
                hintText: '输入B站视频链接或AV号，如：av2 或 BV1xx411c7mD',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToComments(),
                icon: const Icon(Icons.comment),
                label: const Text('查看评论'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('刷新用户信息'),
            subtitle: const Text('获取最新的用户数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.read<AuthProvider>().getUserInfo(),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('重新扫码登录'),
            subtitle: const Text('使用新的二维码登录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToQrLogin(),
          ),
        ),
      ],
    );
  }
  
  Future<void> _navigateToQrLogin() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const QrLoginPage(),
      ),
    );
    
    if (result == true && mounted) {
      // 登录成功后，确保刷新用户信息
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        await authProvider.getUserInfo();
      }
    }
  }
  
  Future<void> _navigateToComments() async {
    final input = _videoController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入视频链接或AV号')),
      );
      return;
    }
    
    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final oid = await _parseVideoId(input);
      if (mounted) Navigator.of(context).pop(); // 关闭加载指示器
      
      if (oid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无效的视频链接或AV号')),
          );
        }
        return;
      }
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentPage(
              oid: oid,
              type: 1, // 视频类型
              title: '视频评论',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载指示器
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解析失败: $e')),
        );
      }
    }
  }
  
  Future<int?> _parseVideoId(String input) async {
    // 移除空格和常见的无关字符
    input = input.trim().replaceAll(' ', '');
    
    // 1. 处理AV号格式：av2, AV2, 2
    if (input.toLowerCase().startsWith('av')) {
      final avId = input.substring(2);
      Logger.d('解析AV号: $avId');
      return int.tryParse(avId);
    }
    
    // 2. 处理纯数字（直接是AV号）
    final numId = int.tryParse(input);
    if (numId != null) {
      return numId;
    }
    
    // 3. 处理BV号格式：BV1xx411c7mD
    if (input.toUpperCase().startsWith('BV')) {
      final bvId = input;
      Logger.d('解析BV号: $bvId');
      return await _bvToAvByApi(bvId);
    }
    
    // 4. 处理各种B站链接格式
    final linkPatterns = [
      // 完整链接：https://www.bilibili.com/video/av2
      RegExp(r'bilibili\.com/video/av(\d+)'),
      // 完整链接：https://www.bilibili.com/video/BV1xx411c7mD
      RegExp(r'bilibili\.com/video/BV([a-zA-Z0-9]+)'),
      // 短链接：https://b23.tv/BV1xx411c7mD
      RegExp(r'b23\.tv/BV([a-zA-Z0-9]+)'),
      // 短链接：https://b23.tv/av2
      RegExp(r'b23\.tv/av(\d+)'),
      // 移动端链接：https://m.bilibili.com/video/av2
      RegExp(r'm\.bilibili\.com/video/av(\d+)'),
      // 移动端链接：https://m.bilibili.com/video/BV1xx411c7mD
      RegExp(r'm\.bilibili\.com/video/BV([a-zA-Z0-9]+)'),
    ];
    
    for (final pattern in linkPatterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        final id = match.group(1);
        if (id != null) {
          // 如果匹配到的是数字，说明是AV号
          final avId = int.tryParse(id);
          if (avId != null) {
            return avId;
          }
          // 如果匹配到的是字符串，说明是BV号，需要转换
          return await _bvToAvByApi('BV$id');
        }
      }
    }
    
    return null;
  }
  
  /// 通过API获取BV号对应的AV号
  Future<int?> _bvToAvByApi(String bvId) async {
    try {
      final apiClient = GetIt.instance<ApiClient>();
      final response = await apiClient.get(
        AppConstants.videoInfoUrl,
        queryParameters: {'bvid': bvId},
      );
      Logger.d('视频信息API响应: ${response.statusCode}');
      if (response.data != null && response.data['code'] == 0) {
        final aid = response.data['data']['aid'] as int?;
        Logger.d('BV号 $bvId 转换为 AV号: $aid');
        return aid;
      }
      return null;
    } catch (e) {
      Logger.e('BV号转换失败: $e');
      return null;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      if (context.mounted) {
        context.read<AuthProvider>().logout();
      }
    }
  }
} 