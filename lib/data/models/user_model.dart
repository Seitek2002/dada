import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.followersCount,
    required super.followingCount,
    required super.likesCount,
    super.isVerified,
    super.isFollowing,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int,
      followingCount: json['following_count'] as int,
      likesCount: json['likes_count'] as int,
      isVerified: json['is_verified'] as bool? ?? false,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'likes_count': likesCount,
      'is_verified': isVerified,
      'is_following': isFollowing,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      followersCount: followersCount,
      followingCount: followingCount,
      likesCount: likesCount,
      isVerified: isVerified,
      isFollowing: isFollowing,
    );
  }
}

