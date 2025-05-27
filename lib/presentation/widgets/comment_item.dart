import 'package:flutter/material.dart';
import '../../domain/entities/comment_entity.dart';

/// 评论项组件
class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback? onReplyTap;
  final Function(CommentEntity comment)? onReplyToComment; // 回复评论回调
  final String? highlightKeyword; // 高亮关键词
  
  const CommentItem({
    super.key,
    required this.comment,
    this.onReplyTap,
    this.onReplyToComment,
    this.highlightKeyword,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 12),
            _buildContent(),
            const SizedBox(height: 12),
            _buildActions(),
            if (comment.replies != null && comment.replies!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReplies(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[300],
          child: Text(
            comment.member.uname.isNotEmpty 
                ? comment.member.uname[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildHighlightedText(
                    comment.member.uname.isNotEmpty 
                        ? comment.member.uname 
                        : '匿名用户',
                    highlightKeyword,
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: comment.member.vip.nicknameColor.isNotEmpty
                          ? _parseColor(comment.member.vip.nicknameColor)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (comment.member.levelInfo.currentLevel > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(comment.member.levelInfo.currentLevel),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LV${comment.member.levelInfo.currentLevel}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (comment.member.vip.vipStatus == 1) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(comment.ctime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContent() {
    return _buildHighlightedText(
      comment.content.message,
      highlightKeyword,
      const TextStyle(
        fontSize: 14,
        height: 1.4,
      ),
    );
  }
  
  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.thumb_up_outlined,
          count: comment.like,
          onTap: () {
            // TODO: 实现点赞功能
          },
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.comment_outlined,
          count: comment.rcount,
          onTap: () {
            if (onReplyToComment != null) {
              onReplyToComment!(comment);
            }
          },
        ),
        const Spacer(),
        if (comment.count > 0)
          InkWell(
            onTap: onReplyTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '${comment.count}条回复',
                style: TextStyle(
                  fontSize: 12,
                  color: onReplyTap != null ? Colors.blue : Colors.grey[600],
                  decoration: onReplyTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildReplies() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: comment.replies!.take(3).map((reply) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '${reply.member.uname}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: reply.member.vip.nicknameColor.isNotEmpty
                          ? _parseColor(reply.member.vip.nicknameColor)
                          : Colors.blue,
                    ),
                  ),
                  TextSpan(text: reply.content.message),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }
  
  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      case 6:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.black;
    } catch (e) {
      return Colors.black;
    }
  }
  
  /// 构建高亮文本
  Widget _buildHighlightedText(String text, String? keyword, TextStyle style) {
    if (keyword == null || keyword.isEmpty) {
      return Text(text, style: style);
    }
    
    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    
    if (!lowerText.contains(lowerKeyword)) {
      return Text(text, style: style);
    }
    
    final spans = <TextSpan>[];
    int start = 0;
    
    while (start < text.length) {
      final index = lowerText.indexOf(lowerKeyword, start);
      if (index == -1) {
        // 没有更多匹配，添加剩余文本
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      
      // 添加匹配前的文本
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      
      // 添加高亮的匹配文本
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: style.copyWith(
                     backgroundColor: Colors.yellow.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ));
      
      start = index + keyword.length;
    }
    
    return RichText(
      text: TextSpan(
        style: style,
        children: spans,
      ),
    );
  }
} 