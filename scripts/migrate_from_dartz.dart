import 'dart:io';

/// Dartz 到 Result 的自动化迁移脚本
void main() async {
  print('开始 Dartz 迁移...');
  
  // 需要迁移的文件列表
  final filesToMigrate = [
    // Repository 接口
    'lib/domain/repositories/auth_repository.dart',
    
    // Repository 实现
    'lib/data/repositories/auth_repository_impl.dart',
    
    // UseCase 类
    'lib/domain/usecases/get_user_info_usecase.dart',
    'lib/domain/usecases/poll_qr_status_usecase.dart',
    'lib/domain/usecases/get_comment_replies_usecase.dart',
    'lib/domain/usecases/generate_qr_code_usecase.dart',
    'lib/domain/usecases/get_comment_list_usecase.dart',
    'lib/domain/usecases/logout_usecase.dart',
    
    // Provider 类
    'lib/presentation/providers/auth_provider.dart',
    'lib/presentation/providers/comment_provider.dart',
    'lib/presentation/providers/comment_reply_provider.dart',
  ];
  
  for (final filePath in filesToMigrate) {
    await migrateFile(filePath);
  }
  
  print('迁移完成！');
  print('请记住：');
  print('1. 从 pubspec.yaml 中移除 dartz 依赖');
  print('2. 运行 flutter pub get');
  print('3. 运行测试确保一切正常');
}

Future<void> migrateFile(String filePath) async {
  final file = File(filePath);
  
  if (!await file.exists()) {
    print('文件不存在: $filePath');
    return;
  }
  
  print('迁移文件: $filePath');
  
  String content = await file.readAsString();
  
  // 1. 替换导入语句
  content = content.replaceAll(
    "import 'package:dartz/dartz.dart';",
    "import '../../core/utils/result.dart';"
  );
  
  // 2. 替换类型定义
  content = content.replaceAllMapped(
    RegExp(r'Either<Failure,\s*([^>]+)>'),
    (match) => 'Result<${match.group(1)}>'
  );
  
  // 3. 替换 Right 构造函数
  content = content.replaceAllMapped(
    RegExp(r'Right\(([^)]+)\)'),
    (match) => 'Result.success(${match.group(1)})'
  );
  
  // 4. 替换 Left 构造函数
  content = content.replaceAllMapped(
    RegExp(r'Left\(([^)]+)\)'),
    (match) => 'Result.failure(${match.group(1)})'
  );
  
  // 5. 替换 const Right
  content = content.replaceAllMapped(
    RegExp(r'const Right\(([^)]+)\)'),
    (match) => 'const Result.success(${match.group(1)})'
  );
  
  // 6. 替换 const Left
  content = content.replaceAllMapped(
    RegExp(r'const Left\(([^)]+)\)'),
    (match) => 'const Result.failure(${match.group(1)})'
  );
  
  // 调整导入路径（根据文件位置）
  if (filePath.contains('domain/')) {
    content = content.replaceAll(
      "import '../../core/utils/result.dart';",
      "import '../../core/utils/result.dart';"
    );
  } else if (filePath.contains('data/')) {
    content = content.replaceAll(
      "import '../../core/utils/result.dart';",
      "import '../../core/utils/result.dart';"
    );
  } else if (filePath.contains('presentation/')) {
    content = content.replaceAll(
      "import '../../core/utils/result.dart';",
      "import '../../core/utils/result.dart';"
    );
  }
  
  await file.writeAsString(content);
  print('✓ 完成: $filePath');
}

/// 验证迁移结果
Future<void> validateMigration() async {
  print('\n验证迁移结果...');
  
  // 检查是否还有 dartz 导入
  final result = await Process.run('grep', ['-r', "import 'package:dartz", 'lib/']);
  
  if (result.stdout.toString().trim().isEmpty) {
    print('✓ 所有 dartz 导入已移除');
  } else {
    print('⚠️ 仍有文件包含 dartz 导入:');
    print(result.stdout);
  }
  
  // 检查是否还有 Either 类型
  final eitherResult = await Process.run('grep', ['-r', 'Either<', 'lib/']);
  
  if (eitherResult.stdout.toString().trim().isEmpty) {
    print('✓ 所有 Either 类型已替换');
  } else {
    print('⚠️ 仍有文件包含 Either 类型:');
    print(eitherResult.stdout);
  }
} 