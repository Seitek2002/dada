import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class MuxVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;
  final Function(double)? onProgressUpdate;
  final VoidCallback? onVideoEnd;
  final Function(bool)? onZoomChanged;

  const MuxVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.isPlaying = false,
    this.onProgressUpdate,
    this.onVideoEnd,
    this.onZoomChanged,
  });

  @override
  State<MuxVideoPlayerWidget> createState() => _MuxVideoPlayerWidgetState();
}

class _MuxVideoPlayerWidgetState extends State<MuxVideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;
  double _scale = 1.0;
  bool _isZoomed = false;

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

      BetterPlayerDataSource dataSource;

      // Проверяем тип URL
      if (widget.videoUrl.startsWith('assets/')) {
        // Локальный asset файл
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          widget.videoUrl,
        );
      } else if (widget.videoUrl.contains('.m3u8')) {
        // Mux HLS stream
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoUrl,
          videoFormat: BetterPlayerVideoFormat.hls,
        );
      } else {
        // Обычное сетевое видео (MP4)
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoUrl,
        );
      }

      final betterPlayerConfiguration = BetterPlayerConfiguration(
        autoPlay: widget.isPlaying,
        looping: false,
        aspectRatio: 9 / 16,
        fit: BoxFit.contain,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
          enablePlayPause: false,
          enableMute: false,
          enableFullscreen: false,
          enableProgressBar: false,
          enableSkips: false,
          enablePlaybackSpeed: false,
          enablePip: false,
          enableAudioTracks: false,
          enableSubtitles: false,
          enableQualities: false,
          enableRetry: false,
        ),
        eventListener: (BetterPlayerEvent event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
            final progress = _betterPlayerController?.videoPlayerController?.value.position;
            final duration = _betterPlayerController?.videoPlayerController?.value.duration;
            if (progress != null && duration != null && duration.inMilliseconds > 0) {
              final percentage = (progress.inMilliseconds / duration.inMilliseconds) * 100;
              widget.onProgressUpdate?.call(percentage);
            }
          } else if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            widget.onVideoEnd?.call();
          }
        },
      );

      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: dataSource,
      );

      // Устанавливаем максимальную громкость
      await _betterPlayerController?.setVolume(1.0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing Mux video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
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
      _betterPlayerController?.pause();
      _betterPlayerController?.dispose();
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
      _initializeVideo();
      return;
    }

    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized) {
      if (widget.isPlaying) {
        _betterPlayerController?.play();
      } else {
        _betterPlayerController?.pause();
      }
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();
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
                'Failed to load video',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _betterPlayerController == null) {
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
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      onTap: () {
        if (_betterPlayerController!.isPlaying()!) {
          _betterPlayerController?.pause();
        } else {
          _betterPlayerController?.play();
        }
      },
      child: Transform.scale(
        scale: _scale,
        child: BetterPlayer(
          controller: _betterPlayerController!,
        ),
      ),
    );
  }
}

