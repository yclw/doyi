import '../errors/failures.dart';

/// 替代 dartz Either 的结果类型
sealed class Result<T> {
  const Result();
  
  /// 创建成功结果
  const factory Result.success(T data) = Success<T>;
  
  /// 创建失败结果
  const factory Result.failure(Failure failure) = Failed<T>;
  
  /// 是否为成功
  bool get isSuccess => this is Success<T>;
  
  /// 是否为失败
  bool get isFailure => this is Failed<T>;
  
  /// 获取成功数据（如果是成功的话）
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failed<T> _ => null,
  };
  
  /// 获取失败信息（如果是失败的话）
  Failure? get failure => switch (this) {
    Success<T> _ => null,
    Failed<T> failed => failed.failure,
  };
  
  /// 类似 dartz 的 fold 方法
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T> success => onSuccess(success.data),
      Failed<T> failed => onFailure(failed.failure),
    };
  }
  
  /// 映射成功值
  Result<R> map<R>(R Function(T) mapper) {
    return switch (this) {
      Success<T> success => Result.success(mapper(success.data)),
      Failed<T> failed => Result.failure(failed.failure),
    };
  }
  
  /// 异步映射
  Future<Result<R>> mapAsync<R>(Future<R> Function(T) mapper) async {
    return switch (this) {
      Success<T> success => Result.success(await mapper(success.data)),
      Failed<T> failed => Result.failure(failed.failure),
    };
  }
}

/// 成功结果
final class Success<T> extends Result<T> {
  @override
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

/// 失败结果
final class Failed<T> extends Result<T> {
  @override
  final Failure failure;
  
  const Failed(this.failure);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failed<T> && runtimeType == other.runtimeType && failure == other.failure;
  
  @override
  int get hashCode => failure.hashCode;
  
  @override
  String toString() => 'Failed($failure)';
}

/// 扩展方法，方便使用
extension ResultExtensions<T> on T {
  /// 将值包装为成功结果
  Result<T> get success => Result.success(this);
}

extension FailureExtensions on Failure {
  /// 将失败包装为失败结果
  Result<T> failed<T>() => Result.failure(this);
} 