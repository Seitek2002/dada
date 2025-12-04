import '../entities/video_entity.dart';
import '../entities/user_entity.dart';

abstract class VideoRepository {
  Future<List<VideoEntity>> getVideos();
  Future<List<VideoEntity>> getVideosByUser(String userId);
  Future<UserEntity> getUserById(String userId);
  Future<List<UserEntity>> searchUsers(String query);
  Future<List<VideoEntity>> searchVideos(String query);
  
  // Future methods for analytics (будет использоваться позже)
  Future<void> trackVideoView(String videoId);
  Future<void> trackVideoCompletion(String videoId, double watchPercentage);
  Future<void> trackLike(String videoId);
  Future<void> trackComment(String videoId);
  Future<void> trackShare(String videoId);
}

