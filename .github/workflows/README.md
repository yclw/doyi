# GitHub Actions 工作流说明

本项目包含以下GitHub Actions工作流，用于自动化构建、测试和发布流程。

## 📋 工作流列表

### 1. 🚀 Build and Release (`build-and-release.yml`)
**触发条件：**
- 推送到 `main` 或 `master` 分支
- 创建以 `v` 开头的标签（如 `v1.0.0`）
- Pull Request 到 `main` 或 `master` 分支

**功能：**
- 代码质量检查和测试
- 构建多平台应用：
  - 🤖 Android (APK + AAB)
  - 🍎 iOS (IPA)
  - 🖥️ macOS (DMG)
  - 🪟 Windows (ZIP)
  - 🐧 Linux (TAR.GZ)
  - 🌐 Web
- 自动发布Release（仅在创建标签时）

### 2. 🔍 Code Quality (`code-quality.yml`)
**触发条件：**
- 推送到 `main`、`master` 或 `develop` 分支
- Pull Request 到这些分支

**功能：**
- 代码格式检查
- 静态代码分析
- 运行测试并生成覆盖率报告
- 检查过时的依赖项

### 3. 🌐 Deploy Web (`deploy-web-pages.yml`)
**触发条件：**
- 推送到 `main` 或 `master` 分支
- 手动触发

**功能：**
- 构建Web版本
- 自动部署到GitHub Pages

### 4. 📦 Dependency Update (`dependency-update.yml`)
**触发条件：**
- 每周一早上8点自动运行
- 手动触发

**功能：**
- 自动更新Flutter依赖项
- 运行测试确保更新不会破坏功能
- 创建Pull Request包含更新

## 🚀 如何发布新版本

1. **准备发布：**
   ```bash
   # 确保代码已提交并推送
   git add .
   git commit -m "feat: 准备发布 v1.0.0"
   git push origin main
   ```

2. **创建标签：**
   ```bash
   # 创建并推送标签
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **自动构建：**
   - GitHub Actions会自动触发构建流程
   - 构建完成后会自动创建Release
   - 所有平台的安装包会自动上传到Release

## 📱 支持的平台

| 平台 | 输出格式 | 说明 |
|------|----------|------|
| Android | APK, AAB | 可直接安装或上传到Google Play |
| iOS | IPA | 需要重新签名才能安装 |
| macOS | DMG | macOS安装包 |
| Windows | ZIP | Windows可执行文件压缩包 |
| Linux | TAR.GZ | Linux可执行文件压缩包 |
| Web | 静态文件 | 部署到GitHub Pages |

## ⚙️ 配置说明

### 必需的Secrets
目前所有工作流都使用默认的 `GITHUB_TOKEN`，无需额外配置。

### 可选配置
- **Codecov**: 如需代码覆盖率报告，可在Codecov注册并添加 `CODECOV_TOKEN`
- **签名**: iOS和macOS应用需要Apple开发者证书进行签名

## 🔧 自定义配置

### 修改Flutter版本
在所有工作流文件中找到以下部分并修改版本号：
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # 修改这里
    channel: 'stable'
```

### 修改构建配置
可以在各个构建步骤中添加自定义参数：
```yaml
- name: Build APK
  run: flutter build apk --release --target-platform android-arm64
```

## 📝 注意事项

1. **首次运行**: 第一次运行可能需要较长时间，后续运行会利用缓存加速
2. **并行构建**: 多个平台会并行构建，节省时间
3. **失败处理**: 如果某个平台构建失败，不会影响其他平台
4. **存储空间**: 构建产物会占用GitHub Actions存储空间，建议定期清理旧的artifacts

## 🆘 故障排除

### 常见问题
1. **构建失败**: 检查Flutter版本兼容性和依赖项
2. **iOS构建问题**: 确保iOS项目配置正确
3. **Web部署失败**: 检查GitHub Pages设置

### 调试方法
1. 查看Actions日志获取详细错误信息
2. 在本地运行相同的构建命令进行测试
3. 检查依赖项版本兼容性 