import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_reply_provider.dart';
import '../providers/comment_add_provider.dart';
import '../widgets/comment_item.dart';
import '../widgets/comment_reply_input.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../../domain/entities/comment_entity.dart';

/// 评论回复页面（楼中楼）
class CommentReplyPage extends StatefulWidget {
  final int type;
  final int oid;
  final int root;
  final String title;
  
  const CommentReplyPage({
    super.key,
    required this.type,
    required this.oid,
    required this.root,
    required this.title,
  });
  
  @override
  State<CommentReplyPage> createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {
  late ScrollController _scrollController;
  CommentEntity? _replyToComment; // 当前要回复的评论
  bool _showReplyInput = false; // 是否显示回复输入框
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentReplyProvider>().initialize(
        type: widget.type,
        oid: widget.oid,
        root: widget.root,
      );
    });
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CommentReplyProvider>().loadMore();
    }
  }
  
  /// 显示回复输入框
  void _showReplyInputDialog(CommentEntity comment) {
    setState(() {
      _replyToComment = comment;
      _showReplyInput = true;
    });
  }
  
  /// 隐藏回复输入框
  void _hideReplyInput() {
    setState(() {
      _replyToComment = null;
      _showReplyInput = false;
    });
  }
  
  /// 发送回复
  Future<void> _sendReply(String message) async {
    if (_replyToComment == null) return;
    
    final addProvider = context.read<CommentAddProvider>();
    final success = await addProvider.addComment(
      type: widget.type,
      oid: widget.oid,
      message: message,
      root: widget.root,
      parent: _replyToComment!.rpid,
    );
    
    if (success) {
      _hideReplyInput();
      // 刷新回复列表
      if (mounted) {
        context.read<CommentReplyProvider>().refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('回复发送成功')),
        );
      }
    } else {
      // 显示错误信息
      if (mounted && addProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(addProvider.errorMessage!)),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Consumer<CommentReplyProvider>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: _buildBody(provider),
              );
            },
          ),
          if (_showReplyInput)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<CommentAddProvider>(
                builder: (context, addProvider, child) {
                  return CommentReplyInput(
                    replyToUser: _replyToComment?.member.uname,
                    placeholder: '回复 @${_replyToComment?.member.uname}',
                    isLoading: addProvider.isLoading,
                    onSubmit: _sendReply,
                    onCancel: _hideReplyInput,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildBody(CommentReplyProvider provider) {
    switch (provider.state) {
      case CommentReplyState.loading:
        return const Center(
          child: LoadingWidget(message: '加载回复中...'),
        );
        
      case CommentReplyState.error:
        return Center(
          child: AppErrorWidget(
            message: provider.errorMessage ?? '加载失败',
            onRetry: () {
              provider.clearError();
              provider.refresh();
            },
          ),
        );
        
      case CommentReplyState.loaded:
      case CommentReplyState.loadingMore:
        return _buildReplyList(provider);
        
      default:
        return const Center(
          child: LoadingWidget(message: '初始化中...'),
        );
    }
  }
  
  Widget _buildReplyList(CommentReplyProvider provider) {
    final rootComment = provider.rootComment;
    final replies = provider.replies;
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 根评论
        if (rootComment != null) ...[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '原评论',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  CommentItem(
                    comment: rootComment,
                    onReplyToComment: _showReplyInputDialog,
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
          
          // 回复标题
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '全部回复',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${provider.totalCount})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // 回复列表
        if (replies.isEmpty && provider.state == CommentReplyState.loaded)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '暂无回复',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < replies.length) {
                  return CommentItem(
                    comment: replies[index],
                    onReplyToComment: _showReplyInputDialog,
                  );
                } else if (provider.state == CommentReplyState.loadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (!provider.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '没有更多回复了',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              childCount: replies.length + 
                  (provider.state == CommentReplyState.loadingMore ? 1 : 0) +
                  (!provider.hasMore && replies.isNotEmpty ? 1 : 0),
            ),
          ),
        
        // 底部空间，为回复输入框留出位置
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: _showReplyInput ? 120 : 16,
          ),
        ),
      ],
    );
  }
} 