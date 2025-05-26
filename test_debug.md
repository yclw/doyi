# 登录问题调试指南

## 问题描述
登录成功并获取了Cookie，但首页依然显示请登录。

## 已添加的调试信息

### 1. AuthProvider调试日志
- `AuthProvider: 开始Cookie登录`
- `AuthProvider: Cookie登录结果 - true/false`
- `AuthProvider: 开始获取用户信息`
- `AuthProvider: 获取用户信息成功 - UID: xxx, 昵称: xxx`

### 2. HomeScreen状态监听
- `HomeScreen: 状态更新 - AuthState.xxx, 已认证: true/false, 用户UID: xxx`

### 3. BilibiliRemoteDatasource API调试
- `BilibiliRemoteDatasource: 开始获取用户信息`
- `BilibiliRemoteDatasource: API响应码 - 0`
- `BilibiliRemoteDatasource: 用户信息解析成功 - UID: xxx`

### 4. CookieManager登录检查
- `CookieManager: 检查登录Cookie - SESSDATA: true/false, DedeUserID: true/false`

## 调试步骤

1. **运行应用并查看控制台输出**
   ```bash
   flutter run
   ```

2. **进行登录操作**
   - 点击登录按钮
   - 在WebView中完成B站登录
   - 观察控制台输出

3. **检查关键日志**
   - Cookie是否正确提取
   - API调用是否成功
   - 用户信息是否正确解析
   - 状态是否正确更新

## 可能的问题原因

### 1. Cookie提取问题
- WebView中的Cookie格式不正确
- 缺少必要的Cookie字段（SESSDATA, DedeUserID）

### 2. API调用问题
- B站API返回错误码
- 网络请求失败
- Cookie未正确发送到API

### 3. 状态管理问题
- Provider状态未正确更新
- UI未监听到状态变化

### 4. 数据解析问题
- B站API响应格式变化
- 用户信息解析失败

## 修复建议

### 1. 检查Cookie格式
确保提取的Cookie包含必要字段：
```
SESSDATA=xxx; DedeUserID=xxx; bili_jct=xxx
```

### 2. 验证API响应
检查B站API是否返回正确的用户信息：
```json
{
  "code": 0,
  "data": {
    "mid": 123456,
    "uname": "用户名",
    "face": "头像URL",
    ...
  }
}
```

### 3. 确认状态流转
正常的状态流转应该是：
```
initial -> loading -> authenticated
```

## 测试命令

```bash
# 运行应用
flutter run

# 查看详细日志
flutter run --verbose

# 构建调试版本
flutter build apk --debug
``` 