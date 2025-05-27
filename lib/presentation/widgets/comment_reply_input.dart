import 'package:flutter/material.dart';

/// 评论回复输入组件
class CommentReplyInput extends StatefulWidget {
  final String? replyToUser; // 回复的用户名
  final String? placeholder; // 占位符文本
  final Function(String message)? onSubmit; // 提交回调
  final VoidCallback? onCancel; // 取消回调
  final bool isLoading; // 是否正在发送
  
  const CommentReplyInput({
    super.key,
    this.replyToUser,
    this.placeholder,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });
  
  @override
  State<CommentReplyInput> createState() => _CommentReplyInputState();
}

class _CommentReplyInputState extends State<CommentReplyInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // 自动聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleSubmit() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && widget.onSubmit != null) {
      widget.onSubmit!(message);
    }
  }
  
  void _handleCancel() {
    _controller.clear();
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom, // 适配键盘高度
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.replyToUser != null) ...[
            Row(
              children: [
                Text(
                  '回复 @${widget.replyToUser}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _handleCancel,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  maxLength: 1000,
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? '发表你的看法...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[400]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: widget.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('发送'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 