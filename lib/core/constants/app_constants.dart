/// 应用常量
class AppConstants {
  // 应用信息
  static const String appName = 'doyi';
  static const String appVersion = '1.0.0';
  
  // API端点
  static const String bilibiliBaseUrl = 'https://api.bilibili.com';
  static const String passportBaseUrl = 'https://passport.bilibili.com';
  
  // 二维码登录相关
  static const String qrGenerateUrl = '$passportBaseUrl/x/passport-login/web/qrcode/generate';
  static const String qrPollUrl = '$passportBaseUrl/x/passport-login/web/qrcode/poll';
  
  // 用户API
  static const String userInfoUrl = '$bilibiliBaseUrl/x/web-interface/nav';
  static const String loginStatusUrl = '$bilibiliBaseUrl/x/web-interface/nav/stat';
  
  // 视频信息API
  static const String videoInfoUrl = '$bilibiliBaseUrl/x/web-interface/view';
  
  // 评论API
  static const String commentListUrl = '$bilibiliBaseUrl/x/v2/reply';
  static const String commentReplyUrl = '$bilibiliBaseUrl/x/v2/reply/reply';
  static const String commentAddUrl = '$bilibiliBaseUrl/x/v2/reply/add';
  
  // 本地存储键
  static const String cookieKey = 'bilibili_cookie';
  static const String userInfoKey = 'user_info';
  static const String loginStatusKey = 'login_status';
  
  // 网络配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // 二维码配置
  static const Duration qrPollInterval = Duration(seconds: 2);
  static const Duration qrExpireTime = Duration(minutes: 3);
  
  // 用户代理
  static const String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';
} 