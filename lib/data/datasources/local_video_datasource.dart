import '../models/user_model.dart';
import '../models/video_model.dart';

class LocalVideoDatasource {
  // Mock users
  static final List<UserModel> _mockUsers = [
    const UserModel(
      id: '1',
      username: 'charlidamelio',
      displayName: 'Charli D\'Amelio',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=charli',
      bio: 'Dancer 💃 | 150M+ followers',
      followersCount: 151000000,
      followingCount: 1500,
      likesCount: 11000000000,
      isVerified: true,
    ),
    const UserModel(
      id: '2',
      username: 'khaby.lame',
      displayName: 'Khabane Lame',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=khaby',
      bio: 'Life is simple 😌',
      followersCount: 161000000,
      followingCount: 200,
      likesCount: 2500000000,
      isVerified: true,
    ),
    const UserModel(
      id: '3',
      username: 'bellapoarch',
      displayName: 'Bella Poarch',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=bella',
      bio: 'Build a B*tch 🎵',
      followersCount: 93000000,
      followingCount: 800,
      likesCount: 2200000000,
      isVerified: true,
    ),
    const UserModel(
      id: '4',
      username: 'addisonre',
      displayName: 'Addison Rae',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=addison',
      bio: 'Actress & Dancer ✨',
      followersCount: 88000000,
      followingCount: 1200,
      likesCount: 5800000000,
      isVerified: true,
    ),
    const UserModel(
      id: '5',
      username: 'zachking',
      displayName: 'Zach King',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=zach',
      bio: 'Digital Sleight of Hand 🎩',
      followersCount: 70000000,
      followingCount: 300,
      likesCount: 900000000,
      isVerified: true,
    ),
  ];

  // Mock videos - используем локальные видео из assets
  static final List<VideoModel> _mockVideos = [
    VideoModel(
      id: '1',
      videoUrl: 'assets/videos/video1.mp4',
      description: 'Amazing dance moves! 💃 #dance #viral #fyp',
      author: _mockUsers[0],
      likesCount: 2500000,
      commentsCount: 45000,
      sharesCount: 120000,
      viewsCount: 15000000,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      tags: ['dance', 'viral', 'fyp'],
      musicName: 'Original Sound',
      musicAuthor: 'Charli D\'Amelio',
    ),
    VideoModel(
      id: '2',
      videoUrl: 'assets/videos/video2.mp4',
      description: 'Life hack that actually works 😂 #lifehack #comedy',
      author: _mockUsers[1],
      likesCount: 5200000,
      commentsCount: 89000,
      sharesCount: 340000,
      viewsCount: 28000000,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      tags: ['lifehack', 'comedy'],
      musicName: 'Funny Sound',
      musicAuthor: 'Khabane Lame',
    ),
    VideoModel(
      id: '3',
      videoUrl: 'assets/videos/video3.MP4',
      description: 'New song out now! 🎵 Link in bio #music #newmusic',
      author: _mockUsers[2],
      likesCount: 3800000,
      commentsCount: 67000,
      sharesCount: 210000,
      viewsCount: 19000000,
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      tags: ['music', 'newmusic'],
      musicName: 'Build a B*tch',
      musicAuthor: 'Bella Poarch',
    ),
    VideoModel(
      id: '4',
      videoUrl: 'assets/videos/video4.MP4',
      description: 'Get ready with me! ✨ #grwm #makeup #beauty',
      author: _mockUsers[3],
      likesCount: 1900000,
      commentsCount: 34000,
      sharesCount: 95000,
      viewsCount: 12000000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['grwm', 'makeup', 'beauty'],
      musicName: 'Trending Sound',
      musicAuthor: 'Various Artists',
    ),
    VideoModel(
      id: '5',
      videoUrl: 'assets/videos/video5.mp4',
      description: 'Magic trick revealed! 🎩✨ #magic #illusion #mindblown',
      author: _mockUsers[4],
      likesCount: 4100000,
      commentsCount: 78000,
      sharesCount: 280000,
      viewsCount: 22000000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['magic', 'illusion', 'mindblown'],
      musicName: 'Epic Music',
      musicAuthor: 'Zach King',
    ),
    VideoModel(
      id: '6',
      videoUrl: 'assets/videos/video6.mp4',
      description: 'Behind the scenes! 🎬 #bts #content #creator',
      author: _mockUsers[0],
      likesCount: 1500000,
      commentsCount: 28000,
      sharesCount: 75000,
      viewsCount: 9000000,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['bts', 'content', 'creator'],
      musicName: 'Upbeat Track',
      musicAuthor: 'Various Artists',
    ),
  ];

  Future<List<VideoModel>> getVideos() async {
    // Симулируем задержку сети
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockVideos;
  }

  Future<List<VideoModel>> getVideosByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockVideos.where((video) => video.author.id == userId).toList();
  }

  Future<UserModel> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => _mockUsers[0],
    );
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers
        .where(
          (user) =>
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.displayName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<VideoModel>> searchVideos(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockVideos
        .where(
          (video) =>
              video.description.toLowerCase().contains(query.toLowerCase()) ||
              video.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }
}
