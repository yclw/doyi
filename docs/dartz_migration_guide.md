# Dartz 迁移指南

## 概述

本指南将帮助你将项目从 `dartz` 库迁移到自定义的 `Result` 类型。

## 迁移步骤

### 1. 替换类型定义

#### 之前 (dartz)
```dart
import 'package:dartz/dartz.dart';

Future<Either<Failure, UserEntity>> getUserInfo();
```

#### 之后 (Result)
```dart
import '../../core/utils/result.dart';

Future<Result<UserEntity>> getUserInfo();
```

### 2. 替换返回值构造

#### 之前 (dartz)
```dart
// 成功情况
return Right(user);

// 失败情况
return Left(NetworkFailure('网络错误'));
```

#### 之后 (Result)
```dart
// 成功情况
return Result.success(user);
// 或者使用扩展方法
return user.success;

// 失败情况
return Result.failure(NetworkFailure('网络错误'));
// 或者使用扩展方法
return NetworkFailure('网络错误').failed<UserEntity>();
```

### 3. 替换结果处理

#### 之前 (dartz)
```dart
result.fold(
  (failure) => print('失败: ${failure.message}'),
  (data) => print('成功: $data'),
);
```

#### 之后 (Result)
```dart
// 方式1: 使用 fold 方法（完全兼容）
result.fold(
  (failure) => print('失败: ${failure.message}'),
  (data) => print('成功: $data'),
);

// 方式2: 使用 switch 表达式（推荐）
switch (result) {
  case Success(data: final data):
    print('成功: $data');
  case Failed(failure: final failure):
    print('失败: ${failure.message}');
}

// 方式3: 使用 getter
if (result.isSuccess) {
  print('成功: ${result.data}');
} else {
  print('失败: ${result.failure?.message}');
}
```

## 需要修改的文件列表

### Repository 接口
- `lib/domain/repositories/auth_repository.dart`

### Repository 实现
- `lib/data/repositories/auth_repository_impl.dart`

### UseCase 类
- `lib/domain/usecases/get_user_info_usecase.dart`
- `lib/domain/usecases/poll_qr_status_usecase.dart`
- `lib/domain/usecases/get_comment_replies_usecase.dart`
- `lib/domain/usecases/generate_qr_code_usecase.dart`
- `lib/domain/usecases/get_comment_list_usecase.dart`
- `lib/domain/usecases/logout_usecase.dart`

### Provider 类
- `lib/presentation/providers/auth_provider.dart`
- `lib/presentation/providers/comment_provider.dart`
- `lib/presentation/providers/comment_reply_provider.dart`

## 迁移优势

1. **更好的类型安全**: 使用 sealed class 提供编译时的完整性检查
2. **现代 Dart 语法**: 利用 Dart 3.0+ 的 pattern matching 特性
3. **减少依赖**: 移除对第三方库的依赖
4. **更好的性能**: 避免额外的库开销
5. **更好的调试**: 更清晰的错误信息和堆栈跟踪

## 注意事项

1. 确保你的项目使用 Dart 3.0+ 版本
2. 所有使用 `Either` 的地方都需要替换为 `Result`
3. 导入语句需要从 `package:dartz/dartz.dart` 改为 `../../core/utils/result.dart`
4. 可以逐步迁移，新的 `Result` 类型提供了与 dartz 兼容的 `fold` 方法

## 自动化迁移脚本

你可以使用以下正则表达式进行批量替换：

1. 替换导入:
   - 查找: `import 'package:dartz/dartz.dart';`
   - 替换: `import '../../core/utils/result.dart';`

2. 替换类型:
   - 查找: `Either<Failure, ([^>]+)>`
   - 替换: `Result<$1>`

3. 替换构造函数:
   - 查找: `Right\(([^)]+)\)`
   - 替换: `Result.success($1)`
   - 查找: `Left\(([^)]+)\)`
   - 替换: `Result.failure($1)` 