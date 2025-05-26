import '../../domain/entities/comment_entity.dart';

/// 评论数据模型
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.rpid,
    required super.oid,
    required super.type,
    required super.mid,
    required super.root,
    required super.parent,
    required super.count,
    required super.rcount,
    required super.state,
    required super.ctime,
    required super.like,
    required super.action,
    required super.member,
    required super.content,
    super.replies,
  });
  
  /// 从B站API响应创建评论模型
  factory CommentModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentModel(
      rpid: json['rpid'] as int? ?? 0,
      oid: json['oid'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      mid: json['mid'] as int? ?? 0,
      root: json['root'] as int? ?? 0,
      parent: json['parent'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      rcount: json['rcount'] as int? ?? 0,
      state: json['state'] as int? ?? 0,
      ctime: json['ctime'] as int? ?? 0,
      like: json['like'] as int? ?? 0,
      action: json['action'] as int? ?? 0,
      member: CommentMemberModel.fromBilibiliApiResponse(
        json['member'] as Map<String, dynamic>? ?? {},
      ),
      content: CommentContentModel.fromBilibiliApiResponse(
        json['content'] as Map<String, dynamic>? ?? {},
      ),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromBilibiliApiResponse(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 评论用户信息数据模型
class CommentMemberModel extends CommentMemberEntity {
  const CommentMemberModel({
    required super.mid,
    required super.uname,
    required super.sex,
    required super.sign,
    required super.avatar,
    required super.levelInfo,
    required super.vip,
  });
  
  /// 从B站API响应创建用户模型
  factory CommentMemberModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentMemberModel(
      mid: json['mid']?.toString() ?? '',
      uname: json['uname'] as String? ?? '',
      sex: json['sex'] as String? ?? '',
      sign: json['sign'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      levelInfo: CommentLevelModel.fromBilibiliApiResponse(
        json['level_info'] as Map<String, dynamic>? ?? {},
      ),
      vip: CommentVipModel.fromBilibiliApiResponse(
        json['vip'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// 评论等级信息数据模型
class CommentLevelModel extends CommentLevelEntity {
  const CommentLevelModel({
    required super.currentLevel,
  });
  
  /// 从B站API响应创建等级模型
  factory CommentLevelModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentLevelModel(
      currentLevel: json['current_level'] as int? ?? 0,
    );
  }
}

/// 评论VIP信息数据模型
class CommentVipModel extends CommentVipEntity {
  const CommentVipModel({
    required super.vipType,
    required super.vipStatus,
    required super.nicknameColor,
  });
  
  /// 从B站API响应创建VIP模型
  factory CommentVipModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentVipModel(
      vipType: json['vipType'] as int? ?? 0,
      vipStatus: json['vipStatus'] as int? ?? 0,
      nicknameColor: json['nickname_color'] as String? ?? '',
    );
  }
}

/// 评论内容数据模型
class CommentContentModel extends CommentContentEntity {
  const CommentContentModel({
    required super.message,
    required super.emote,
  });
  
  /// 从B站API响应创建内容模型
  factory CommentContentModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    List<CommentEmoteModel> emotes = [];
    final emoteData = json['emote'];
    
    if (emoteData is Map<String, dynamic>) {
      emotes = emoteData.values
          .map((e) => CommentEmoteModel.fromBilibiliApiResponse(e as Map<String, dynamic>))
          .toList();
    }
    
    return CommentContentModel(
      message: json['message'] as String? ?? '',
      emote: emotes,
    );
  }
}

/// 评论表情数据模型
class CommentEmoteModel extends CommentEmoteEntity {
  const CommentEmoteModel({
    required super.id,
    required super.packageId,
    required super.state,
    required super.type,
    required super.attr,
    required super.text,
    required super.url,
    required super.meta,
  });
  
  /// 从B站API响应创建表情模型
  factory CommentEmoteModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentEmoteModel(
      id: json['id'] as int? ?? 0,
      packageId: json['package_id']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      attr: json['attr']?.toString() ?? '',
      text: json['text'] as String? ?? '',
      url: json['url'] as String? ?? '',
      meta: json['meta'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 评论列表数据模型
class CommentListModel extends CommentListEntity {
  const CommentListModel({
    required super.page,
    required super.replies,
    required super.hots,
  });
  
  /// 从B站API响应创建评论列表模型
  factory CommentListModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return CommentListModel(
      page: CommentPageModel.fromBilibiliApiResponse(
        data['page'] as Map<String, dynamic>? ?? {},
      ),
      replies: (data['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromBilibiliApiResponse(e as Map<String, dynamic>))
          .toList() ?? [],
      hots: (data['hots'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromBilibiliApiResponse(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// 评论分页信息数据模型
class CommentPageModel extends CommentPageEntity {
  const CommentPageModel({
    required super.num,
    required super.size,
    required super.count,
    required super.acount,
  });
  
  /// 从B站API响应创建分页模型
  factory CommentPageModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentPageModel(
      num: json['num'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
      count: json['count'] as int? ?? 0,
      acount: json['acount'] as int? ?? 0,
    );
  }
}

/// 评论回复列表数据模型
class CommentReplyListModel extends CommentReplyListEntity {
  const CommentReplyListModel({
    required super.page,
    required super.replies,
    required super.root,
  });
  
  /// 从B站API响应创建回复列表模型
  factory CommentReplyListModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return CommentReplyListModel(
      page: CommentReplyPageModel.fromBilibiliApiResponse(
        data['page'] as Map<String, dynamic>? ?? {},
      ),
      replies: (data['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromBilibiliApiResponse(e as Map<String, dynamic>))
          .toList() ?? [],
      root: CommentModel.fromBilibiliApiResponse(
        data['root'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// 评论回复分页信息数据模型
class CommentReplyPageModel extends CommentReplyPageEntity {
  const CommentReplyPageModel({
    required super.num,
    required super.size,
    required super.count,
  });
  
  /// 从B站API响应创建回复分页模型
  factory CommentReplyPageModel.fromBilibiliApiResponse(Map<String, dynamic> json) {
    return CommentReplyPageModel(
      num: json['num'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
      count: json['count'] as int? ?? 0,
    );
  }
} 