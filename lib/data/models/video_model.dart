import '../../domain/entities/video_entity.dart';
import 'user_model.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.videoUrl,
    super.thumbnailUrl,
    required super.description,
    required super.author,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.viewsCount,
    super.isLiked,
    super.isFavorite,
    required super.createdAt,
    super.tags,
    super.musicName,
    super.musicAuthor,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      likesCount: json['likes_count'] as int,
      commentsCount: json['comments_count'] as int,
      sharesCount: json['shares_count'] as int,
      viewsCount: json['views_count'] as int,
      isLiked: json['is_liked'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      musicName: json['music_name'] as String?,
      musicAuthor: json['music_author'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'description': description,
      'author': (author as UserModel).toJson(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'is_liked': isLiked,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'tags': tags,
      'music_name': musicName,
      'music_author': musicAuthor,
    };
  }

  VideoEntity toEntity() {
    return VideoEntity(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      author: author,
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      viewsCount: viewsCount,
      isLiked: isLiked,
      isFavorite: isFavorite,
      createdAt: createdAt,
      tags: tags,
      musicName: musicName,
      musicAuthor: musicAuthor,
    );
  }
}

