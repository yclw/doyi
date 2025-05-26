# Cookie登录问题修复总结

## 问题描述
用户反馈：在WebView中成功登录B站并获取了Cookie，但首页依然显示"请先登录B站账号"。

## 根本原因分析
通过日志分析发现，B站API返回了`{"code":-101,"message":"账号未登录","ttl":1}`，说明Cookie没有正确发送到API请求中。

**核心问题**：域名不匹配导致Cookie无法正确传递
- WebView登录页面域名：`www.bilibili.com`
- API请求域名：`api.bilibili.com`
- Cookie保存时使用的域名：`www.bilibili.com`
- API请求时获取Cookie的域名：`api.bilibili.com`

由于域名不匹配，Cookie管理器无法为API请求提供正确的Cookie。

## 修复方案

### 1. 修复Cookie保存逻辑
在`CookieManager.setCookie()`方法中：
- 添加详细的调试日志
- 对于B站域名，同时保存到`bilibili.com`通用域名下
- 确保内存缓存和持久化存储都包含通用域名的Cookie

### 2. 修复Cookie获取逻辑
在`CookieManager.getCookieNoSession()`方法中：
- 添加详细的调试日志
- 优先从请求的域名获取Cookie
- 如果没有找到，尝试从`bilibili.com`通用域名获取
- 支持内存缓存和持久化存储的回退机制

### 3. 修复API客户端Cookie处理
在`ApiClient`的请求拦截器中：
- 优先从`bilibili.com`域名获取Cookie
- 如果没有找到，回退到`www.bilibili.com`
- 添加详细的Cookie长度和内容日志

## 修复的文件

1. **lib/core/network/cookie_manager.dart**
   - `setCookie()`: 添加通用域名支持
   - `getCookieNoSession()`: 添加域名回退机制
   - 增强调试日志

2. **lib/core/network/api_client.dart**
   - 请求拦截器：优化Cookie获取策略
   - 增强调试日志

## 调试日志增强

### Cookie保存时的日志
```
CookieManager: 保存Cookie - URL: https://www.bilibili.com, 域名: bilibili.com
CookieManager: Cookie保存成功
```

### Cookie获取时的日志
```
CookieManager: 获取Cookie - URL: https://bilibili.com, 解析域名: bilibili.com
CookieManager: 从内存缓存获取到Cookie，长度: 1234
```

### API请求时的日志
```
ApiClient: 添加Cookie到请求 - SESSDATA=xxx; DedeUserID=xxx; bili_jct=xxx...
请求: GET https://api.bilibili.com/x/web-interface/nav
请求头Cookie长度: 1234
```

## 预期效果

修复后的登录流程：
1. 用户在WebView中登录B站
2. Cookie被保存到`bilibili.com`通用域名下
3. API请求时能正确获取并发送Cookie
4. B站API返回用户信息而不是未登录错误
5. 首页正确显示用户信息

## 测试验证

运行应用后，观察控制台日志：
1. 确认Cookie保存成功
2. 确认API请求包含正确的Cookie
3. 确认B站API返回用户信息（code: 0）
4. 确认首页显示用户信息而不是登录提示

## 技术要点

1. **域名匹配**：确保Cookie能在相关子域名间共享
2. **回退机制**：多层次的Cookie获取策略
3. **调试友好**：详细的日志帮助问题定位
4. **兼容性**：保持与现有代码的兼容性

这个修复解决了跨域名Cookie传递的核心问题，确保了登录状态的正确维护。 