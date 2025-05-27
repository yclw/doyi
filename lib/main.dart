import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/comment_provider.dart';
import 'presentation/providers/comment_reply_provider.dart';
import 'presentation/providers/comment_add_provider.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await initDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<CommentProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<CommentReplyProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<CommentAddProvider>(),
        ),
      ],
      child: MaterialApp(
        title: 'doyi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}