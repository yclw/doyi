# 移除 Dartz 依赖迁移指南

## 快速开始

### 1. 运行迁移脚本
```bash
dart run scripts/migrate_from_dartz.dart
```

### 2. 更新 pubspec.yaml
移除以下依赖：
```yaml
# 删除这一行
dartz: ^0.10.1
```

### 3. 更新依赖
```bash
flutter pub get
```

### 4. 验证迁移
```bash
flutter analyze
flutter test
```

## 手动迁移（如果需要）

如果自动脚本有问题，可以手动替换：

1. **替换导入**：
   ```dart
   // 之前
   import 'package:dartz/dartz.dart';
   
   // 之后
   import '../../core/utils/result.dart';
   ```

2. **替换类型**：
   ```dart
   // 之前
   Future<Either<Failure, UserEntity>> getUserInfo();
   
   // 之后
   Future<Result<UserEntity>> getUserInfo();
   ```

3. **替换返回值**：
   ```dart
   // 之前
   return Right(data);
   return Left(failure);
   
   // 之后
   return Result.success(data);
   return Result.failure(failure);
   ```

## 新的 Result 类型优势

- ✅ 使用 Dart 3.0+ 的 sealed class
- ✅ 支持 pattern matching
- ✅ 完全兼容原有的 `fold()` 方法
- ✅ 更好的类型安全
- ✅ 减少外部依赖

## 需要修改的文件

总共需要修改 **11 个文件**：
- 1 个 Repository 接口
- 1 个 Repository 实现  
- 6 个 UseCase 类
- 3 个 Provider 类 