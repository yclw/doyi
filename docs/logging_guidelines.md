# 日志使用规范

## 概述

本项目使用统一的 `Logger` 类进行日志输出，**禁止使用 `print()` 或 `debugPrint()` 函数**。

## 导入方式

```dart
import '../../core/utils/logger.dart';
```

## 日志级别

### 1. 调试日志 - `Logger.d()`
用于开发调试信息，如方法调用、参数值等。

```dart
Logger.d('开始获取用户信息');
Logger.d('解析AV号: $avId');
```

### 2. 信息日志 - `Logger.i()`
用于记录重要的业务流程信息。

```dart
Logger.i('用户登录成功');
Logger.i('Cookie保存成功');
```

### 3. 警告日志 - `Logger.w()`
用于记录可能的问题或异常情况。

```dart
Logger.w('网络连接不稳定');
Logger.w('缓存数据过期');
```

### 4. 错误日志 - `Logger.e()`
用于记录错误和异常信息。

```dart
Logger.e('获取用户信息失败: ${failure.message}');
Logger.e('网络请求异常', error: e, stackTrace: stackTrace);
```

## 专用日志方法

### 网络请求日志
```dart
Logger.network('请求: GET /api/user/info');
Logger.network('响应: 200 OK');
```

### 用户行为日志
```dart
Logger.user('用户点击登录按钮');
Logger.user('用户切换到评论页面');
```

### 性能日志
```dart
Logger.performance('页面加载耗时: ${duration.inMilliseconds}ms');
Logger.performance('图片解码完成');
```

## 使用规范

### ✅ 正确使用

```dart
// 基本使用
Logger.d('开始处理数据');
Logger.i('处理完成');
Logger.e('处理失败: $errorMessage');

// 带自定义标签
Logger.d('数据库操作完成', tag: 'DATABASE');

// 错误日志带异常信息
try {
  // 业务代码
} catch (e, stackTrace) {
  Logger.e('操作失败', error: e, stackTrace: stackTrace);
}
```

### ❌ 错误使用

```dart
// 禁止使用 print
print('这是错误的用法');

// 禁止使用 debugPrint
debugPrint('这也是错误的用法');

// 避免在生产环境输出敏感信息
Logger.d('用户密码: $password'); // 错误！
```

## 最佳实践

1. **日志内容要有意义**：避免无用的日志信息
2. **包含上下文**：记录足够的上下文信息便于调试
3. **避免敏感信息**：不要记录密码、token等敏感数据
4. **使用合适的级别**：根据信息重要性选择合适的日志级别
5. **异常处理**：错误日志要包含异常对象和堆栈信息

## 日志输出控制

- 日志仅在 Debug 模式下输出
- Release 模式下自动禁用所有日志
- 使用 `dart:developer` 的 `log` 函数，支持 Flutter DevTools

## 示例

```dart
class UserService {
  Future<User> getUser(String userId) async {
    Logger.d('开始获取用户信息: $userId');
    
    try {
      final response = await apiClient.get('/user/$userId');
      Logger.network('用户信息API响应: ${response.statusCode}');
      
      final user = User.fromJson(response.data);
      Logger.i('用户信息获取成功: ${user.nickname}');
      
      return user;
    } on NetworkException catch (e) {
      Logger.e('获取用户信息网络错误: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.e('获取用户信息异常', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
``` 