class UserEntity {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final bool isVerified;
  final bool isFollowing;

  const UserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.likesCount,
    this.isVerified = false,
    this.isFollowing = false,
  });
}

