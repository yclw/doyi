import 'package:dio/dio.dart';

void main() async {
  print('开始测试B站API连接...');
  
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
          headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
        'Origin': 'https://www.bilibili.com',
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        // 移除Accept-Encoding，让Dio自动处理
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'DNT': '1',
      },
    validateStatus: (status) {
      return status != null && status < 500;
    },
  ));
  
  try {
    print('正在请求二维码生成API...');
    final response = await dio.get(
      'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
      options: Options(
        headers: {
          'Referer': 'https://www.bilibili.com/',
        },
        responseType: ResponseType.json, // 让Dio自动解析JSON
      ),
    );
    
    print('响应状态码: ${response.statusCode}');
    print('响应数据类型: ${response.data.runtimeType}');
    print('响应数据: ${response.data}');
    
    if (response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final code = data['code'] as int?;
      
      if (code == 0) {
        print('✅ 二维码生成成功！');
        final qrData = data['data'] as Map<String, dynamic>?;
        if (qrData != null) {
          print('二维码URL: ${qrData['url']}');
          print('二维码Key: ${qrData['qrcode_key']}');
        }
      } else {
        print('❌ 二维码生成失败: code=$code, message=${data['message']}');
      }
    } else {
      print('❌ 响应数据为空');
    }
    
  } catch (e) {
    print('❌ 请求失败: $e');
    print('异常类型: ${e.runtimeType}');
    
    if (e is DioException) {
      print('DioException详情:');
      print('  - 错误类型: ${e.type}');
      print('  - 错误消息: ${e.message}');
      print('  - 错误对象: ${e.error}');
      print('  - 堆栈跟踪: ${e.stackTrace}');
      
      final response = e.response;
      if (response != null) {
        print('  - 响应状态码: ${response.statusCode}');
        print('  - 响应头: ${response.headers}');
        print('  - 响应数据类型: ${response.data.runtimeType}');
        print('  - 响应数据: ${response.data}');
      }
      
      final requestOptions = e.requestOptions;
      print('  - 请求URL: ${requestOptions.uri}');
      print('  - 请求方法: ${requestOptions.method}');
      print('  - 请求头: ${requestOptions.headers}');
    }
  }
  
  print('测试完成');
} 