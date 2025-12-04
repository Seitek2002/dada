import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/video_entity.dart';
import '../../providers/video_provider.dart';
import '../../widgets/mux_video_player_widget.dart';
import '../../widgets/video_actions.dart';
import '../../widgets/video_description.dart';

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
      context.read<VideoProvider>().trackVideoView(widget.video.id);
    }
  }

  void _onProgressUpdate(double progress) {
    // Track completion at 25%, 50%, 75%, 100%
    if (progress >= 25 && _lastProgress < 25) {
      context.read<VideoProvider>().trackVideoCompletion(widget.video.id, 25);
    } else if (progress >= 50 && _lastProgress < 50) {
      context.read<VideoProvider>().trackVideoCompletion(widget.video.id, 50);
    } else if (progress >= 75 && _lastProgress < 75) {
      context.read<VideoProvider>().trackVideoCompletion(widget.video.id, 75);
    } else if (progress >= 100 && _lastProgress < 100) {
      context.read<VideoProvider>().trackVideoCompletion(widget.video.id, 100);
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
          onZoomChanged: (isZoomed) {
            setState(() {
              _isZoomed = isZoomed;
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
                  Expanded(
                    child: VideoDescription(video: widget.video),
                  ),
                  const SizedBox(width: 16),

                  // Actions
                  VideoActions(
                    video: widget.video,
                    onLike: () {
                      context.read<VideoProvider>().toggleLike(widget.video.id);
                    },
                    onComment: () {
                      context.read<VideoProvider>().trackComment(widget.video.id);
                      _showCommentsSheet(context);
                    },
                    onShare: () {
                      context.read<VideoProvider>().trackShare(widget.video.id);
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
                            'Pinch to zoom video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.video.commentsCount} comments',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 10,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      child: Text('U${index + 1}'),
                    ),
                    title: Text('User ${index + 1}'),
                    subtitle: const Text('This is a comment'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

