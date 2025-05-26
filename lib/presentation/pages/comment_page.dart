import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_provider.dart';
import '../widgets/comment_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'comment_reply_page.dart';

/// 评论页面
class CommentPage extends StatefulWidget {
  final int oid; // 视频ID
  final int type; // 视频类型
  final String title; // 视频标题
  
  const CommentPage({
    super.key,
    required this.oid,
    required this.type,
    required this.title,
  });
  
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentSort = 0; // 0: 按时间, 1: 按点赞数, 2: 按回复数
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().reset();
      context.read<CommentProvider>().getCommentList(
        type: widget.type,
        oid: widget.oid,
      );
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final provider = context.read<CommentProvider>();
    
    // 当滚动到距离底部100像素时，且不在加载状态，且还有更多页面时，触发加载更多
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100 &&
        !provider.isLoading &&
        provider.hasMorePages) {
      provider.loadMoreComments();
    }
  }
  
  /// 导航到回复页面
  void _navigateToReplyPage(comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentReplyPage(
          type: widget.type,
          oid: widget.oid,
          root: comment.rpid,
          title: '评论回复',
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              if (sort != _currentSort) {
                setState(() {
                  _currentSort = sort;
                });
                context.read<CommentProvider>().changeSortType(sort);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _currentSort == 0 ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '按时间',
                      style: TextStyle(
                        color: _currentSort == 0 ? Colors.blue : null,
                        fontWeight: _currentSort == 0 ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: _currentSort == 1 ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '按点赞数',
                      style: TextStyle(
                        color: _currentSort == 1 ? Colors.blue : null,
                        fontWeight: _currentSort == 1 ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                      Icons.comment,
                      color: _currentSort == 2 ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '按回复数',
                      style: TextStyle(
                        color: _currentSort == 2 ? Colors.blue : null,
                        fontWeight: _currentSort == 2 ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CommentProvider>(
        builder: (context, commentProvider, child) {
          return RefreshIndicator(
            onRefresh: () => commentProvider.refreshComments(),
            child: _buildBody(commentProvider),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(CommentProvider commentProvider) {
    switch (commentProvider.state) {
      case CommentState.loading:
        if (!commentProvider.hasData) {
          return const Center(
            child: LoadingWidget(message: '加载评论中...'),
          );
        }
        // 如果已有数据，显示数据并在底部显示加载指示器
        return _buildCommentList(commentProvider);
        
      case CommentState.loaded:
        return _buildCommentList(commentProvider);
        
      case CommentState.loadingMore:
        // 加载更多时，显示评论列表并在底部显示加载指示器
        return _buildCommentList(commentProvider);
        
      case CommentState.error:
        if (!commentProvider.hasData) {
          return Center(
            child: AppErrorWidget(
              message: commentProvider.errorMessage ?? '加载评论失败',
              onRetry: () {
                commentProvider.clearError();
                commentProvider.getCommentList(
                  type: widget.type,
                  oid: widget.oid,
                  sort: _currentSort,
                );
              },
            ),
          );
        }
        // 如果已有数据，显示数据
        return _buildCommentList(commentProvider);
        
      default:
        return const Center(
          child: LoadingWidget(message: '初始化中...'),
        );
    }
  }
  
  Widget _buildCommentList(CommentProvider commentProvider) {
    final hotComments = commentProvider.hotComments;
    final normalComments = commentProvider.normalComments;
    
    if (hotComments.isEmpty && normalComments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无评论',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _calculateItemCount(hotComments, normalComments, commentProvider),
      itemBuilder: (context, index) {
        return _buildListItem(
          context,
          index,
          hotComments,
          normalComments,
          commentProvider,
        );
      },
    );
  }
  
  int _calculateItemCount(List hotComments, List normalComments, CommentProvider commentProvider) {
    int count = 0;
    
    // 热评标题
    if (hotComments.isNotEmpty) count++;
    // 热评内容
    count += hotComments.length;
    
    // 普通评论标题
    if (normalComments.isNotEmpty) count++;
    // 普通评论内容
    count += normalComments.length;
    
    // 底部状态指示器（加载中或没有更多数据）
    if (normalComments.isNotEmpty) count++;
    
    return count;
  }
  
  Widget _buildListItem(
    BuildContext context,
    int index,
    List hotComments,
    List normalComments,
    CommentProvider commentProvider,
  ) {
    int currentIndex = index;
    
    // 热评区域
    if (hotComments.isNotEmpty) {
      if (currentIndex == 0) {
        return _buildSectionHeader('热门评论', hotComments.length);
      }
      currentIndex--;
      
      if (currentIndex < hotComments.length) {
        final comment = hotComments[currentIndex];
        return CommentItem(
          comment: comment,
          onReplyTap: comment.count > 0 ? () => _navigateToReplyPage(comment) : null,
        );
      }
      currentIndex -= hotComments.length;
    }
    
    // 普通评论区域
    if (normalComments.isNotEmpty) {
      if (currentIndex == 0) {
        return _buildSectionHeader(
          '最新评论',
          commentProvider.totalCount,
        );
      }
      currentIndex--;
      
      if (currentIndex < normalComments.length) {
        final comment = normalComments[currentIndex];
        return CommentItem(
          comment: comment,
          onReplyTap: comment.count > 0 ? () => _navigateToReplyPage(comment) : null,
        );
      }
      currentIndex -= normalComments.length;
    }
    
    // 底部状态指示器
    if (currentIndex == 0) {
      return _buildBottomIndicator(commentProvider);
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator(CommentProvider commentProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _getBottomWidget(commentProvider),
      ),
    );
  }

  Widget _getBottomWidget(CommentProvider commentProvider) {
    if (commentProvider.isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            '加载中...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else if (!commentProvider.hasMorePages) {
      return const Text(
        '没有更多评论了',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      );
    } else {
      return const Text(
        '上拉加载更多',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      );
    }
  }
} 