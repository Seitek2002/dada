import 'user_entity.dart';

class VideoEntity {
  final String id;
  final String videoUrl;
  final String? thumbnailUrl;
  final String description;
  final UserEntity author;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isFavorite;
  final DateTime createdAt;
  final List<String> tags;
  final String? musicName;
  final String? musicAuthor;

  const VideoEntity({
    required this.id,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.description,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    this.isLiked = false,
    this.isFavorite = false,
    required this.createdAt,
    this.tags = const [],
    this.musicName,
    this.musicAuthor,
  });

  VideoEntity copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
    UserEntity? author,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? isLiked,
    bool? isFavorite,
    DateTime? createdAt,
    List<String>? tags,
    String? musicName,
    String? musicAuthor,
  }) {
    return VideoEntity(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      musicName: musicName ?? this.musicName,
      musicAuthor: musicAuthor ?? this.musicAuthor,
    );
  }
}

