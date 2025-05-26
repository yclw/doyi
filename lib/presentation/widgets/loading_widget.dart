import 'package:flutter/material.dart';

/// 加载组件
class LoadingWidget extends StatelessWidget {
  final String message;
  
  const LoadingWidget({
    super.key,
    this.message = '加载中...',
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
} 