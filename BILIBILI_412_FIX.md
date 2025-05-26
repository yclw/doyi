# B站API -412错误解决方案

## 问题描述
在调用B站API时遇到 `-412` 状态码，返回信息为：
```json
{
  "code": -412,
  "message": "request was banned",
  "ttl": 1
}
```

## 原因分析
-412错误是B站的风控机制，主要原因包括：
1. **请求头不完整**：缺少必要的浏览器标识头
2. **请求频率过高**：短时间内发起过多请求
3. **IP被风控**：使用的IP地址被识别为异常
4. **缺少Cookie**：某些API需要登录状态

## 解决方案

### 1. 完善请求头
确保所有API请求包含以下关键请求头：

```dart
headers: {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'Referer': 'https://www.bilibili.com/',
  'Origin': 'https://www.bilibili.com',
  'Accept': 'application/json, text/plain, */*',
  'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
  'Accept-Encoding': 'gzip, deflate, br',
  'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="131", "Google Chrome";v="131"',
  'Sec-Ch-Ua-Mobile': '?0',
  'Sec-Ch-Ua-Platform': '"Windows"',
  'Sec-Fetch-Dest': 'empty',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'same-site',
  'DNT': '1',
}
```

### 2. 控制请求频率
- 在请求之间添加延迟（建议至少500ms）
- 使用请求队列管理并发数量
- 避免短时间内大量请求同一接口

### 3. 使用有效Cookie
对于需要登录的API，确保：
- 使用有效的登录Cookie
- 定期检查Cookie是否过期
- 在请求头中正确设置Cookie

### 4. 网络环境优化
- 避免使用数据中心IP（VPS、云服务器等）
- 优先使用家庭宽带IP
- 必要时使用代理池轮换IP

## 项目中的实现

### 已实现的优化
1. **完整请求头**：在 `ApiClient` 中设置了完整的浏览器模拟头
2. **频率限制**：使用 `RateLimiter` 控制请求间隔
3. **错误处理**：专门处理-412错误并提供友好提示
4. **Cookie管理**：自动在请求中添加登录Cookie

### 使用建议
1. **登录后使用**：尽量在登录状态下调用API
2. **合理间隔**：避免频繁调用同一接口
3. **错误重试**：遇到-412错误时，等待一段时间后重试
4. **监控日志**：关注API调用日志，及时发现风控问题

## 常见问题

### Q: 为什么有些账号正常，有些账号返回-412？
A: 不同账号的风控等级不同，新账号或异常行为账号更容易触发风控。

### Q: 换IP后仍然-412怎么办？
A: 可能是账号级别的风控，建议：
- 检查Cookie是否有效
- 降低请求频率
- 使用不同的User-Agent

### Q: 如何判断是否需要登录？
A: 大部分B站API都需要登录状态，建议先完成登录再调用其他API。

## 参考资料
- [GitHub Issue讨论](https://github.com/SocialSisterYi/bilibili-API-collect/issues/872)
- [B站API文档](https://github.com/SocialSisterYi/bilibili-API-collect) 