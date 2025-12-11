import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../domain/entities/video_entity.dart';
import '../../providers/post_provider.dart';
import '../../widgets/mux_video_player_widget.dart';
import '../../widgets/video_actions.dart';
import '../../widgets/video_description.dart';
import '../../widgets/comments_sheet.dart';
import '../../widgets/video_progress_bar.dart';

class VideoFeedItem extends StatefulWidget {
  final VideoEntity video;
  final bool isCurrentPage;

  const VideoFeedItem({
    super.key,
    required this.video,
    required this.isCurrentPage,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  bool _hasTrackedView = false;
  double _lastProgress = 0;
  bool _isZoomed = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  VideoPlayerController? _videoController;

  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Track view when video becomes current
    if (widget.isCurrentPage && !oldWidget.isCurrentPage && !_hasTrackedView) {
      _trackView();
    }
  }

  void _trackView() {
    if (!_hasTrackedView) {
      _hasTrackedView = true;
      context.read<PostProvider>().trackView(widget.video.id);
    }
  }

  void _onProgressUpdate(double progress) {
    // Track completion at 25%, 50%, 75%, 100%
    if (progress >= 25 && _lastProgress < 25) {
      context.read<PostProvider>().trackCompletion(widget.video.id, 25);
    } else if (progress >= 50 && _lastProgress < 50) {
      context.read<PostProvider>().trackCompletion(widget.video.id, 50);
    } else if (progress >= 75 && _lastProgress < 75) {
      context.read<PostProvider>().trackCompletion(widget.video.id, 75);
    } else if (progress >= 100 && _lastProgress < 100) {
      context.read<PostProvider>().trackCompletion(widget.video.id, 100);
    }
    _lastProgress = progress;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player with zoom support
        MuxVideoPlayerWidget(
          videoUrl: widget.video.videoUrl,
          isPlaying: widget.isCurrentPage,
          onProgressUpdate: _onProgressUpdate,
          onPositionUpdate: (position, duration) {
            setState(() {
              _position = position;
              _duration = duration;
            });
          },
          onZoomChanged: (isZoomed) {
            setState(() {
              _isZoomed = isZoomed;
            });
          },
          onControllerReady: (controller) {
            setState(() {
              _videoController = controller;
            });
          },
        ),

        // Gradient overlay (скрывается при зуме)
        if (!_isZoomed)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // Content overlay (скрывается при зуме)
        if (!_isZoomed)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Description
                  Expanded(child: VideoDescription(video: widget.video)),
                  const SizedBox(width: 16),

                  // Actions
                  VideoActions(
                    video: widget.video,
                    onLike: () {
                      context.read<PostProvider>().toggleLike(widget.video.id);
                    },
                    onComment: () {
                      context.read<PostProvider>().trackComment(
                        widget.video.id,
                      );
                      _showCommentsSheet(context);
                    },
                    onShare: () {
                      context.read<PostProvider>().trackShare(widget.video.id);
                    },
                  ),
                ],
              ),
            ),
          ),

        // Hint для зума (показывается только первые 3 секунды)
        if (!_isZoomed && widget.isCurrentPage)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 0.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  if (value < 0.1) return const SizedBox.shrink();
                  return Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_out_map,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Увеличить видео',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Ползунок прогресса видео (скрывается при зуме)
        // Расположен максимально низко, частично под navbar
        if (!_isZoomed && _duration.inMilliseconds > 0)
          Positioned(
            bottom: -20, // Отрицательный отступ - частично под navbar!
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: VideoProgressBar(
                position: _position,
                duration: _duration,
                onSeek: (position) {
                  _videoController?.seekTo(position);
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(video: widget.video),
    );
  }
}
