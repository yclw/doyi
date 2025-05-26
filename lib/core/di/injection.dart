import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/cookie_manager.dart';
import '../../data/datasources/qr_login_datasource.dart';
import '../../data/datasources/user_datasource.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/datasources/comment_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/generate_qr_code_usecase.dart';
import '../../domain/usecases/poll_qr_status_usecase.dart';
import '../../domain/usecases/get_user_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_comment_list_usecase.dart';
import '../../domain/usecases/get_comment_replies_usecase.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/comment_provider.dart';
import '../../presentation/providers/comment_reply_provider.dart';

final GetIt getIt = GetIt.instance;

/// 初始化依赖注入
Future<void> initDependencies() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // 核心服务
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<CookieManager>(
    () => CookieManager(getIt<SharedPreferences>()),
  );
  
  // 数据源
  getIt.registerLazySingleton<QrLoginDatasource>(
    () => QrLoginDatasourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<UserDatasource>(
    () => UserDatasourceImpl(getIt<ApiClient>(), getIt<CookieManager>()),
  );
  getIt.registerLazySingleton<LocalDatasource>(
    () => LocalDatasourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<CommentDatasource>(
    () => CommentDatasourceImpl(getIt<ApiClient>(), getIt<CookieManager>()),
  );
  
  // 仓库
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<QrLoginDatasource>(),
      getIt<UserDatasource>(),
      getIt<LocalDatasource>(),
      getIt<CookieManager>(),
      getIt<CommentDatasource>(),
    ),
  );
  
  // 用例
  getIt.registerLazySingleton<GenerateQrCodeUsecase>(
    () => GenerateQrCodeUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<PollQrStatusUsecase>(
    () => PollQrStatusUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetUserInfoUsecase>(
    () => GetUserInfoUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCommentListUsecase>(
    () => GetCommentListUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCommentRepliesUsecase>(
    () => GetCommentRepliesUsecase(getIt<AuthRepository>()),
  );
  
  // 提供者
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      getIt<GenerateQrCodeUsecase>(),
      getIt<PollQrStatusUsecase>(),
      getIt<GetUserInfoUsecase>(),
      getIt<LogoutUsecase>(),
    ),
  );
  getIt.registerFactory<CommentProvider>(
    () => CommentProvider(getIt<GetCommentListUsecase>()),
  );
  getIt.registerFactory<CommentReplyProvider>(
    () => CommentReplyProvider(getIt<GetCommentRepliesUsecase>()),
  );
} 