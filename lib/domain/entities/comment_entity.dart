import 'user_entity.dart';

class CommentEntity {
  final String id;
  final UserEntity author;
  final String text;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final String? replyToId;
  final int repliesCount;

  const CommentEntity({
    required this.id,
    required this.author,
    required this.text,
    required this.likesCount,
    this.isLiked = false,
    required this.createdAt,
    this.replyToId,
    this.repliesCount = 0,
  });

  CommentEntity copyWith({
    String? id,
    UserEntity? author,
    String? text,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    String? replyToId,
    int? repliesCount,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      replyToId: replyToId ?? this.replyToId,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }
}

