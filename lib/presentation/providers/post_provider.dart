import 'package:flutter/foundation.dart';
import '../../core/services/video_cache_service.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/user_entity.dart';

/// Provider для работы с вакансиями (постами)
class PostProvider with ChangeNotifier {
  final SupabaseDatasource _datasource;
  final VideoCacheService _cacheService = VideoCacheService();

  PostProvider(this._datasource);

  List<VideoEntity> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<VideoEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Загрузить персонализированную ленту вакансий
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📱 Loading posts from Supabase...');
      final postsData = await _datasource.getPersonalizedFeed();
      debugPrint('📱 Loaded ${postsData.length} posts');

      _posts = postsData.map((postData) {
        return _mapPostToVideoEntity(postData);
      }).toList();

      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Posts loaded successfully');

      // Предзагружаем первые 3 видео в фоне
      if (_posts.isNotEmpty) {
        _preloadInitialVideos();
      }
    } catch (e) {
      debugPrint('❌ Error loading posts: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Предзагрузить первые видео при загрузке ленты
  Future<void> _preloadInitialVideos() async {
    final videoUrls = _posts.map((post) => post.videoUrl).toList();
    await _cacheService.preloadNextVideos(videoUrls, count: 3);
  }

  /// Предзагрузить следующие видео (вызывается при переключении на новое видео)
  Future<void> preloadNextVideos(int currentIndex) async {
    if (currentIndex >= _posts.length - 1) return;

    // Берем следующие 3 видео
    final nextVideos = _posts
        .skip(currentIndex + 1)
        .take(3)
        .map((post) => post.videoUrl)
        .toList();

    await _cacheService.preloadNextVideos(nextVideos, count: 3);
  }

  /// Получить закешированный URL видео или оригинальный
  Future<String> getCachedVideoUrl(String url) async {
    return await _cacheService.getCachedVideoUrl(url);
  }

  /// Преобразовать данные поста из Supabase в VideoEntity
  VideoEntity _mapPostToVideoEntity(Map<String, dynamic> postData) {
    final authorData = postData['author'] as Map<String, dynamic>?;

    // Создаем автора
    final author = UserEntity(
      id: authorData?['id'] ?? '',
      username: authorData?['username'] ?? 'unknown',
      displayName: authorData?['display_name'] ?? 'Пользователь',
      avatarUrl: authorData?['avatar_url'],
      bio: null,
      followersCount: 0,
      followingCount: 0,
      likesCount: 0,
      isVerified: false,
    );

    // Формируем описание вакансии
    String description = postData['caption'] ?? '';
    
    // Добавляем дополнительную информацию если есть
    if (postData['job_title'] != null) {
      description = '${postData['job_title']}\n\n$description';
    }

    // Создаем VideoEntity из поста
    return VideoEntity(
      id: postData['id'] ?? '',
      videoUrl: postData['media_url'] ?? '',
      thumbnailUrl: postData['thumbnail_url'] ?? '',
      description: description,
      author: author,
      likesCount: postData['likes_count'] ?? 0,
      commentsCount: postData['comments_count'] ?? 0,
      sharesCount: postData['shares_count'] ?? 0,
      viewsCount: postData['views_count'] ?? 0,
      createdAt: DateTime.tryParse(postData['created_at'] ?? '') ?? DateTime.now(),
      tags: (postData['tags'] as List?)?.cast<String>() ?? [],
      musicName: postData['music_name'],
      musicAuthor: postData['music_author'],
      isLiked: false, // TODO: Проверять через отдельный запрос
    );
  }

  /// Поставить/убрать лайк
  Future<void> toggleLike(String postId) async {
    try {
      await _datasource.toggleLike(postId);

      // Обновляем локально
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  /// Отследить просмотр
  Future<void> trackView(String postId) async {
    try {
      // TODO: Реализовать аналитику просмотров
      debugPrint('📊 Track view: $postId');
    } catch (e) {
      debugPrint('Error tracking view: $e');
    }
  }

  /// Отследить завершение просмотра
  Future<void> trackCompletion(String postId, double percentage) async {
    try {
      // TODO: Реализовать аналитику завершения
      debugPrint('📊 Track completion: $postId - ${percentage.toStringAsFixed(0)}%');
    } catch (e) {
      debugPrint('Error tracking completion: $e');
    }
  }

  /// Отследить комментарий
  Future<void> trackComment(String postId) async {
    try {
      // TODO: Реализовать аналитику комментариев
      debugPrint('📊 Track comment: $postId');
    } catch (e) {
      debugPrint('Error tracking comment: $e');
    }
  }

  /// Отследить шер
  Future<void> trackShare(String postId) async {
    try {
      // TODO: Реализовать аналитику шеров
      debugPrint('📊 Track share: $postId');
    } catch (e) {
      debugPrint('Error tracking share: $e');
    }
  }

  /// Откликнуться на вакансию
  Future<bool> applyToJob(String postId) async {
    try {
      await _datasource.applyToJob(postId);
      
      // Обновляем локально
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      debugPrint('Error applying to job: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Проверить откликался ли на вакансию
  Future<bool> hasAppliedToJob(String postId) async {
    try {
      return await _datasource.hasAppliedToJob(postId);
    } catch (e) {
      debugPrint('Error checking application: $e');
      return false;
    }
  }

  /// Добавить комментарий
  Future<bool> addComment(String postId, String text) async {
    try {
      await _datasource.addComment(postId, text);
      
      // Обновляем счетчик комментариев локально
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  /// Получить комментарии
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      return await _datasource.getComments(postId);
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }
}

