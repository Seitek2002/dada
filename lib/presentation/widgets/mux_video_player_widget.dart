import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/video_cache_service.dart';

class MuxVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;
  final Function(double)? onProgressUpdate;
  final VoidCallback? onVideoEnd;
  final Function(bool)? onZoomChanged;
  final Function(Duration position, Duration duration)? onPositionUpdate;
  final Function(VideoPlayerController?)? onControllerReady;

  const MuxVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.isPlaying = false,
    this.onProgressUpdate,
    this.onVideoEnd,
    this.onZoomChanged,
    this.onPositionUpdate,
    this.onControllerReady,
  });

  @override
  State<MuxVideoPlayerWidget> createState() => _MuxVideoPlayerWidgetState();
}

class _MuxVideoPlayerWidgetState extends State<MuxVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  double _scale = 1.0;
  bool _isZoomed = false;
  bool _showControls = false;
  final VideoCacheService _cacheService = VideoCacheService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });

      // Create video controller based on URL type
      if (widget.videoUrl.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      } else {
        // Проверяем кеш и получаем URL
        final cachedUrl = await _cacheService.getCachedVideoUrl(widget.videoUrl);
        
        // Если это локальный файл (из кеша) - используем File
        if (cachedUrl.startsWith('/')) {
          debugPrint('🎬 Проигрываем из кеша: $cachedUrl');
          _controller = VideoPlayerController.file(File(cachedUrl));
        } else {
          debugPrint('🌐 Проигрываем из сети: ${cachedUrl.substring(0, 50)}...');
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(cachedUrl),
          );
        }
      }

      await _controller!.initialize();
      
      // Set video to maximum volume
      await _controller!.setVolume(1.0);

      // Add listener for progress updates
      _controller!.addListener(_videoListener);

      if (widget.isPlaying) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Передаем контроллер наружу
        widget.onControllerReady?.call(_controller);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        widget.onControllerReady?.call(null);
      }
    }
  }

  void _videoListener() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (duration.inMilliseconds > 0) {
      final percentage =
          (position.inMilliseconds / duration.inMilliseconds) * 100;
      widget.onProgressUpdate?.call(percentage);
      widget.onPositionUpdate?.call(position, duration);

      // Check if video ended - restart it
      if (position >= duration && duration.inMilliseconds > 0) {
        _controller!.seekTo(Duration.zero);
        _controller!.play();
        widget.onVideoEnd?.call();
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = details.scale;
      final newIsZoomed = _scale > 1.2;

      if (newIsZoomed != _isZoomed) {
        _isZoomed = newIsZoomed;
        widget.onZoomChanged?.call(_isZoomed);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_scale <= 1.2) {
      setState(() {
        _scale = 1.0;
        _isZoomed = false;
      });
      widget.onZoomChanged?.call(false);
    }
  }

  @override
  void didUpdateWidget(MuxVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoUrl != oldWidget.videoUrl) {
      _controller?.pause();
      _controller?.dispose();
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
      _initializeVideo();
      return;
    }

    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized) {
      if (widget.isPlaying) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text(
                'Не удалось загрузить видео',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        // Скрыть контролы через 2 секунды
        if (_showControls) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Видео
            Center(
              child: Transform.scale(
                scale: _scale,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
            
            // Кнопка паузы/плей
            if (_showControls)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller?.pause();
                      } else {
                        _controller?.play();
                      }
                    });
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
