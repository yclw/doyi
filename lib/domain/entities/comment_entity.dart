import 'package:equatable/equatable.dart';

/// 评论实体
class CommentEntity extends Equatable {
  final int rpid;
  final int oid;
  final int type;
  final int mid;
  final int root;
  final int parent;
  final int count;
  final int rcount;
  final int state;
  final int ctime;
  final int like;
  final int action;
  final CommentMemberEntity member;
  final CommentContentEntity content;
  final List<CommentEntity>? replies;
  
  const CommentEntity({
    required this.rpid,
    required this.oid,
    required this.type,
    required this.mid,
    required this.root,
    required this.parent,
    required this.count,
    required this.rcount,
    required this.state,
    required this.ctime,
    required this.like,
    required this.action,
    required this.member,
    required this.content,
    this.replies,
  });
  
  @override
  List<Object?> get props => [
    rpid,
    oid,
    type,
    mid,
    root,
    parent,
    count,
    rcount,
    state,
    ctime,
    like,
    action,
    member,
    content,
    replies,
  ];
}

/// 评论用户信息实体
class CommentMemberEntity extends Equatable {
  final String mid;
  final String uname;
  final String sex;
  final String sign;
  final String avatar;
  final CommentLevelEntity levelInfo;
  final CommentVipEntity vip;
  
  const CommentMemberEntity({
    required this.mid,
    required this.uname,
    required this.sex,
    required this.sign,
    required this.avatar,
    required this.levelInfo,
    required this.vip,
  });
  
  @override
  List<Object> get props => [
    mid,
    uname,
    sex,
    sign,
    avatar,
    levelInfo,
    vip,
  ];
}

/// 评论等级信息实体
class CommentLevelEntity extends Equatable {
  final int currentLevel;
  
  const CommentLevelEntity({
    required this.currentLevel,
  });
  
  @override
  List<Object> get props => [currentLevel];
}

/// 评论VIP信息实体
class CommentVipEntity extends Equatable {
  final int vipType;
  final int vipStatus;
  final String nicknameColor;
  
  const CommentVipEntity({
    required this.vipType,
    required this.vipStatus,
    required this.nicknameColor,
  });
  
  @override
  List<Object> get props => [vipType, vipStatus, nicknameColor];
}

/// 评论内容实体
class CommentContentEntity extends Equatable {
  final String message;
  final List<CommentEmoteEntity> emote;
  
  const CommentContentEntity({
    required this.message,
    required this.emote,
  });
  
  @override
  List<Object> get props => [message, emote];
}

/// 评论表情实体
class CommentEmoteEntity extends Equatable {
  final int id;
  final String packageId;
  final String state;
  final String type;
  final String attr;
  final String text;
  final String url;
  final Map<String, dynamic> meta;
  
  const CommentEmoteEntity({
    required this.id,
    required this.packageId,
    required this.state,
    required this.type,
    required this.attr,
    required this.text,
    required this.url,
    required this.meta,
  });
  
  @override
  List<Object> get props => [id, packageId, state, type, attr, text, url, meta];
}

/// 评论列表实体
class CommentListEntity extends Equatable {
  final CommentPageEntity page;
  final List<CommentEntity> replies;
  final List<CommentEntity> hots;
  
  const CommentListEntity({
    required this.page,
    required this.replies,
    required this.hots,
  });
  
  @override
  List<Object> get props => [page, replies, hots];
}

/// 评论分页信息实体
class CommentPageEntity extends Equatable {
  final int pageNum;
  final int size;
  final int count;
  final int acount;
  
  const CommentPageEntity({
    required this.pageNum,
    required this.size,
    required this.count,
    required this.acount,
  });
  
  @override
  List<Object> get props => [pageNum, size, count, acount];
}

/// 评论回复列表实体
class CommentReplyListEntity extends Equatable {
  final CommentReplyPageEntity page;
  final List<CommentEntity> replies;
  final CommentEntity root;
  
  const CommentReplyListEntity({
    required this.page,
    required this.replies,
    required this.root,
  });
  
  @override
  List<Object> get props => [page, replies, root];
}

/// 评论回复分页信息实体
class CommentReplyPageEntity extends Equatable {
  final int pageNum;
  final int size;
  final int count;
  
  const CommentReplyPageEntity({
    required this.pageNum,
    required this.size,
    required this.count,
  });
  
  @override
  List<Object> get props => [pageNum, size, count];
} 