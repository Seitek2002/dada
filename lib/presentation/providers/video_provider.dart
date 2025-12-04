import 'package:flutter/foundation.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';

class VideoProvider with ChangeNotifier {
  final VideoRepository _repository;

  VideoProvider(this._repository);

  List<VideoEntity> _videos = [];
  bool _isLoading = false;
  String? _error;

  List<VideoEntity> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _repository.getVideos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String videoId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      _videos[index] = video.copyWith(
        isLiked: !video.isLiked,
        likesCount: video.isLiked ? video.likesCount - 1 : video.likesCount + 1,
      );
      notifyListeners();

      // Track analytics
      if (_videos[index].isLiked) {
        await _repository.trackLike(videoId);
      }
    }
  }

  Future<void> trackVideoView(String videoId) async {
    await _repository.trackVideoView(videoId);
  }

  Future<void> trackVideoCompletion(String videoId, double watchPercentage) async {
    await _repository.trackVideoCompletion(videoId, watchPercentage);
  }

  Future<void> trackComment(String videoId) async {
    await _repository.trackComment(videoId);
  }

  Future<void> trackShare(String videoId) async {
    await _repository.trackShare(videoId);
  }
}

