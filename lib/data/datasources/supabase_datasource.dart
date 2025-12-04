import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_config.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';

/// Supabase Datasource для работы с удаленной БД
/// 
/// Это заменит LocalVideoDatasource когда все будет готово
class SupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  // ============================================
  // ПОЛЬЗОВАТЕЛИ
  // ============================================

  /// Получить текущего пользователя
  User? get currentUser => _client.auth.currentUser;

  /// Проверка авторизации
  bool get isAuthenticated => currentUser != null;

  /// Регистрация нового пользователя
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      // Создаем профиль пользователя
      await _client.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'username': username,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return authResponse;
  }

  /// Вход
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Выход
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Получить профиль пользователя
  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  /// Обновить профиль
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('users').update(updates).eq('id', userId);
  }

  // ============================================
  // ПОСТЫ (ВИДЕО/ИЗОБРАЖЕНИЯ)
  // ============================================

  /// Получить ленту постов (For You)
  Future<List<VideoModel>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('posts')
        .select('''
          *,
          author:users(*)
        ''')
        .eq('is_published', true)
        .eq('is_private', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => VideoModel.fromJson(json))
        .toList();
  }

  /// Получить посты пользователя
  Future<List<VideoModel>> getUserPosts(String userId) async {
    final response = await _client
        .from('posts')
        .select('''
          *,
          author:users(*)
        ''')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => VideoModel.fromJson(json))
        .toList();
  }

  /// Создать пост
  Future<String> createPost({
    required String mediaUrl,
    required String mediaType,
    required String caption,
    String? thumbnailUrl,
    String? categoryId,
    List<String>? tags,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client.from('posts').insert({
      'author_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'caption': caption,
      'thumbnail_url': thumbnailUrl,
      'category_id': categoryId,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    final postId = response['id'] as String;

    // Добавить теги
    if (tags != null && tags.isNotEmpty) {
      await _addTagsToPosts(postId, tags);
    }

    return postId;
  }

  /// Добавить теги к посту
  Future<void> _addTagsToPosts(String postId, List<String> tagNames) async {
    for (final tagName in tagNames) {
      // Найти или создать тег
      final tagResponse = await _client
          .from('tags')
          .select()
          .eq('normalized_name', tagName.toLowerCase())
          .maybeSingle();

      String tagId;
      if (tagResponse == null) {
        // Создать новый тег
        final newTag = await _client.from('tags').insert({
          'name': tagName,
          'normalized_name': tagName.toLowerCase(),
        }).select().single();
        tagId = newTag['id'];
      } else {
        tagId = tagResponse['id'];
      }

      // Связать пост и тег
      await _client.from('post_tags').insert({
        'post_id': postId,
        'tag_id': tagId,
      });
    }
  }

  // ============================================
  // ЛАЙКИ
  // ============================================

  /// Поставить/убрать лайк
  Future<void> toggleLike(String postId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Проверить есть ли лайк
    final existingLike = await _client
        .from('likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    if (existingLike != null) {
      // Убрать лайк
      await _client
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    } else {
      // Поставить лайк
      await _client.from('likes').insert({
        'user_id': userId,
        'post_id': postId,
      });
    }
  }

  /// Проверить лайкнул ли пользователь пост
  Future<bool> isPostLiked(String postId) async {
    final userId = currentUser?.id;
    if (userId == null) return false;

    final like = await _client
        .from('likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    return like != null;
  }

  // ============================================
  // КОММЕНТАРИИ
  // ============================================

  /// Получить комментарии к посту
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('''
          *,
          author:users(*)
        ''')
        .eq('post_id', postId)
        .isFilter('parent_comment_id', null)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Добавить комментарий
  Future<void> addComment(String postId, String text) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      'text': text,
    });
  }

  // ============================================
  // ПОДПИСКИ
  // ============================================

  /// Подписаться/отписаться
  Future<void> toggleFollow(String targetUserId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final existingFollow = await _client
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    if (existingFollow != null) {
      // Отписаться
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId);
    } else {
      // Подписаться
      await _client.from('follows').insert({
        'follower_id': userId,
        'following_id': targetUserId,
      });
    }
  }

  // ============================================
  // ПОИСК
  // ============================================

  /// Поиск пользователей
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _client
        .from('users')
        .select()
        .or('username.ilike.%$query%,display_name.ilike.%$query%')
        .limit(20);

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  /// Поиск постов
  Future<List<VideoModel>> searchPosts(String query) async {
    final response = await _client
        .from('posts')
        .select('''
          *,
          author:users(*)
        ''')
        .textSearch('caption', query)
        .eq('is_published', true)
        .limit(20);

    return (response as List)
        .map((json) => VideoModel.fromJson(json))
        .toList();
  }

  // ============================================
  // STORAGE (Загрузка файлов)
  // ============================================

  /// Загрузить аватар
  Future<String> uploadAvatar(String filePath) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await _client.storage
        .from(SupabaseConfig.avatarsBucket)
        .upload(fileName, File(filePath));

    final url = _client.storage
        .from(SupabaseConfig.avatarsBucket)
        .getPublicUrl(fileName);

    return url;
  }

  /// Загрузить видео
  Future<String> uploadVideo(String filePath) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
    
    await _client.storage
        .from(SupabaseConfig.postsVideosBucket)
        .upload(fileName, File(filePath));

    final url = _client.storage
        .from(SupabaseConfig.postsVideosBucket)
        .getPublicUrl(fileName);

    return url;
  }

  /// Загрузить изображение
  Future<String> uploadImage(String filePath) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await _client.storage
        .from(SupabaseConfig.postsImagesBucket)
        .upload(fileName, File(filePath));

    final url = _client.storage
        .from(SupabaseConfig.postsImagesBucket)
        .getPublicUrl(fileName);

    return url;
  }

  // ============================================
  // АНАЛИТИКА
  // ============================================

  /// Отследить просмотр
  Future<void> trackView(String postId) async {
    await _client.from('analytics_events').insert({
      'user_id': currentUser?.id,
      'post_id': postId,
      'event_type': 'view',
    });

    // Увеличить счетчик просмотров
    await _client.rpc('increment_view_count', params: {'post_id': postId});
  }

  /// Отследить завершение просмотра
  Future<void> trackCompletion(String postId, double percentage) async {
    String eventType;
    if (percentage >= 75) {
      eventType = 'watch_100';
    } else if (percentage >= 50) {
      eventType = 'watch_75';
    } else if (percentage >= 25) {
      eventType = 'watch_50';
    } else {
      eventType = 'watch_25';
    }

    await _client.from('analytics_events').insert({
      'user_id': currentUser?.id,
      'post_id': postId,
      'event_type': eventType,
      'watch_duration': percentage.toInt(),
    });
  }
}

