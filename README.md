# B站登录助手 (Doyi)

一个Flutter应用，用于通过WebView登录B站并获取Cookie，然后使用API获取个人信息。

## 功能特性

- 🌐 **WebView登录**: 使用内置WebView安全登录B站
- 🍪 **Cookie管理**: 自动提取和管理登录Cookie
- 👤 **用户信息**: 获取并展示B站个人信息
- 💾 **本地缓存**: 支持用户信息本地缓存
- 🔄 **状态管理**: 使用Provider进行状态管理
- 🏗️ **企业架构**: 采用Clean Architecture架构

## 项目架构

```
lib/
├── core/                    # 核心模块
│   ├── constants/          # 常量定义
│   ├── errors/             # 错误处理
│   ├── network/            # 网络层
│   ├── utils/              # 工具类
│   └── di/                 # 依赖注入
├── data/                   # 数据层
│   ├── datasources/        # 数据源
│   ├── models/             # 数据模型
│   └── repositories/       # 仓库实现
├── domain/                 # 业务层
│   ├── entities/           # 实体类
│   ├── repositories/       # 仓库接口
│   └── usecases/           # 用例
└── presentation/           # 表现层
    ├── providers/          # 状态管理
    ├── screens/            # 页面
    └── widgets/            # 组件
```

## 技术栈

- **Flutter**: 跨平台UI框架
- **Provider**: 状态管理
- **Dio**: HTTP客户端
- **WebView**: 网页视图
- **SharedPreferences**: 本地存储
- **Dartz**: 函数式编程
- **JSON Annotation**: JSON序列化

## 核心功能

### 1. Cookie管理
参考legado项目的Cookie管理机制：
- 内存缓存和持久化存储
- 会话Cookie和持久Cookie分离管理
- Cookie合并和长度限制
- 自动Cookie提取和验证

### 2. WebView登录
- 自定义User-Agent
- 自动Cookie检测
- 登录状态实时监控
- 手动Cookie提取功能

### 3. API集成
- B站用户信息API
- 登录状态检查API
- 错误处理和重试机制
- 网络异常处理

## 使用方法

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 生成代码
```bash
flutter packages pub run build_runner build
```

### 3. 运行应用
```bash
flutter run
```

### 4. 登录流程
1. 点击"登录B站"按钮
2. 在WebView中完成B站登录
3. 应用自动提取Cookie
4. 获取并展示用户信息

## 主要文件说明

### 核心文件
- `lib/main.dart` - 应用入口
- `lib/core/di/injection.dart` - 依赖注入配置
- `lib/core/network/cookie_manager.dart` - Cookie管理器
- `lib/core/network/api_client.dart` - API客户端

### 业务逻辑
- `lib/domain/entities/user_entity.dart` - 用户实体
- `lib/domain/repositories/bilibili_repository.dart` - 仓库接口
- `lib/data/repositories/bilibili_repository_impl.dart` - 仓库实现

### 界面组件
- `lib/presentation/screens/home_screen.dart` - 主页面
- `lib/presentation/screens/webview_login_screen.dart` - 登录页面
- `lib/presentation/providers/auth_provider.dart` - 认证状态管理

## 配置说明

### B站API端点
- 用户信息: `/x/web-interface/nav`
- 登录检查: `/x/web-interface/nav/stat`

### Cookie字段
- `SESSDATA`: 会话数据
- `bili_jct`: CSRF令牌
- `DedeUserID`: 用户ID

## 注意事项

1. **网络权限**: 确保应用有网络访问权限
2. **WebView支持**: 需要设备支持WebView
3. **Cookie安全**: Cookie仅用于获取用户信息，不会上传到第三方
4. **API限制**: 遵守B站API使用规范

## 开发说明

### 添加新功能
1. 在`domain/usecases/`中添加用例
2. 在`data/datasources/`中添加数据源
3. 在`presentation/`中添加UI组件
4. 更新依赖注入配置

### 错误处理
- 网络错误自动重试
- 认证失败清除缓存
- 用户友好的错误提示

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！
