import '../../domain/entities/video_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/local_video_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final LocalVideoDatasource _localDatasource;

  VideoRepositoryImpl(this._localDatasource);

  @override
  Future<List<VideoEntity>> getVideos() async {
    final videos = await _localDatasource.getVideos();
    return videos.map((video) => video.toEntity()).toList();
  }

  @override
  Future<List<VideoEntity>> getVideosByUser(String userId) async {
    final videos = await _localDatasource.getVideosByUser(userId);
    return videos.map((video) => video.toEntity()).toList();
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    final user = await _localDatasource.getUserById(userId);
    return user.toEntity();
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    final users = await _localDatasource.searchUsers(query);
    return users.map((user) => user.toEntity()).toList();
  }

  @override
  Future<List<VideoEntity>> searchVideos(String query) async {
    final videos = await _localDatasource.searchVideos(query);
    return videos.map((video) => video.toEntity()).toList();
  }

  // Analytics methods - пока заглушки, но готовы для интеграции
  @override
  Future<void> trackVideoView(String videoId) async {
    // TODO: Implement with Supabase/Analytics service
    // ignore: avoid_print
    print('📊 Track video view: $videoId');
  }

  @override
  Future<void> trackVideoCompletion(String videoId, double watchPercentage) async {
    // TODO: Implement with Supabase/Analytics service
    // ignore: avoid_print
    print('📊 Track video completion: $videoId - ${watchPercentage.toStringAsFixed(1)}%');
  }

  @override
  Future<void> trackLike(String videoId) async {
    // TODO: Implement with Supabase/Analytics service
    // ignore: avoid_print
    print('📊 Track like: $videoId');
  }

  @override
  Future<void> trackComment(String videoId) async {
    // TODO: Implement with Supabase/Analytics service
    // ignore: avoid_print
    print('📊 Track comment: $videoId');
  }

  @override
  Future<void> trackShare(String videoId) async {
    // TODO: Implement with Supabase/Analytics service
    // ignore: avoid_print
    print('📊 Track share: $videoId');
  }
}

