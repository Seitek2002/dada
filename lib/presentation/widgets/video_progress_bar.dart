import 'package:flutter/material.dart';

class VideoProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const VideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    final displayProgress = _isDragging ? _dragValue : progress;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
          _dragValue = progress;
        });
      },
      onHorizontalDragUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final newValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);

        setState(() {
          _dragValue = newValue;
        });
      },
      onHorizontalDragEnd: (details) {
        final newPosition = Duration(
          milliseconds: (_dragValue * widget.duration.inMilliseconds).round(),
        );
        widget.onSeek(newPosition);

        setState(() {
          _isDragging = false;
        });
      },
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.localPosition);
        final tapValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);

        final newPosition = Duration(
          milliseconds: (tapValue * widget.duration.inMilliseconds).round(),
        );
        widget.onSeek(newPosition);
      },
      child: Container(
        height: 40, // Увеличенная область для удобного тапа
        alignment: Alignment.center,
        child: Stack(
          children: [
            // Фон ползунка (серая линия)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),

            // Прогресс (белая линия)
            FractionallySizedBox(
              widthFactor: displayProgress.clamp(0.0, 1.0),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),

            // Точка-ползунок (видна только при драге)
            if (_isDragging)
              Positioned(
                left: (MediaQuery.of(context).size.width - 32) *
                    displayProgress.clamp(0.0, 1.0),
                top: 14,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

