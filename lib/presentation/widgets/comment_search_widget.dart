import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_search_provider.dart';
import '../../domain/entities/comment_entity.dart';
import 'comment_item.dart';

/// 评论搜索组件
class CommentSearchWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(CommentEntity comment)? onCommentTap;
  
  const CommentSearchWidget({
    super.key,
    this.onClose,
    this.onCommentTap,
  });
  
  @override
  State<CommentSearchWidget> createState() => _CommentSearchWidgetState();
}

class _CommentSearchWidgetState extends State<CommentSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CommentSearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(context, searchProvider),
              _buildSearchBar(context, searchProvider),
              _buildSearchTypeSelector(context, searchProvider),
              Expanded(
                child: _buildSearchResults(context, searchProvider),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 构建头部
  Widget _buildHeader(BuildContext context, CommentSearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text(
            '搜索评论',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (searchProvider.isSearchActive) ...[
            Text(
              '找到 ${searchProvider.searchResults.length} 条结果',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () {
              searchProvider.clearSearch();
              widget.onClose?.call();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
  
  /// 构建搜索栏
  Widget _buildSearchBar(BuildContext context, CommentSearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '输入关键词搜索评论...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    searchProvider.clearSearch();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.trim().isNotEmpty) {
            searchProvider.search(value);
          } else {
            searchProvider.clearSearch();
          }
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            searchProvider.search(value);
          }
        },
      ),
    );
  }
  
  /// 构建搜索类型选择器
  Widget _buildSearchTypeSelector(BuildContext context, CommentSearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            '搜索范围：',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          _buildSearchTypeChip('all', '全部', searchProvider),
          const SizedBox(width: 8),
          _buildSearchTypeChip('username', '用户名', searchProvider),
          const SizedBox(width: 8),
          _buildSearchTypeChip('content', '评论内容', searchProvider),
        ],
      ),
    );
  }
  
  /// 构建搜索类型选择芯片
  Widget _buildSearchTypeChip(String type, String label, CommentSearchProvider searchProvider) {
    final isSelected = searchProvider.searchType == type;
    return GestureDetector(
      onTap: () {
        searchProvider.setSearchType(type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
  
  /// 构建搜索结果
  Widget _buildSearchResults(BuildContext context, CommentSearchProvider searchProvider) {
    if (!searchProvider.isSearchActive) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '输入关键词开始搜索',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    if (searchProvider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (searchProvider.state == CommentSearchState.notFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到包含 "${searchProvider.searchKeyword}" 的评论',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    if (searchProvider.state == CommentSearchState.error) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              '搜索出错，请重试',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }
    
    // 显示搜索结果
    return Column(
      children: [
        _buildSearchStats(searchProvider),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final comment = searchProvider.searchResults[index];
                             return GestureDetector(
                 onTap: () {
                   if (widget.onCommentTap != null) {
                     widget.onCommentTap!(comment);
                   }
                 },
                 child: Container(
                   margin: const EdgeInsets.only(bottom: 12),
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                     borderRadius: BorderRadius.circular(8),
                     color: Colors.blue.withValues(alpha: 0.05),
                   ),
                   child: CommentItem(
                     comment: comment,
                     onReplyTap: null, // 搜索结果中不显示回复功能
                     onReplyToComment: null,
                     highlightKeyword: searchProvider.searchKeyword,
                   ),
                 ),
               );
            },
          ),
        ),
      ],
    );
  }
  
  /// 构建搜索统计信息
  Widget _buildSearchStats(CommentSearchProvider searchProvider) {
    final stats = searchProvider.getSearchStats();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '搜索结果：共 ${stats['total']} 条',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              if (stats['username']! > 0) ...[
                Text(
                  '用户名匹配：${stats['username']}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const SizedBox(width: 8),
              ],
              if (stats['content']! > 0) ...[
                Text(
                  '内容匹配：${stats['content']}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.touch_app,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '点击评论可定位到原始位置',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 