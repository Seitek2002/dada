import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/video_entity.dart';
import '../providers/post_provider.dart';

class VideoDescription extends StatefulWidget {
  final VideoEntity video;

  const VideoDescription({
    super.key,
    required this.video,
  });

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  bool _isExpanded = false;
  bool _hasApplied = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final hasApplied = await context.read<PostProvider>().hasAppliedToJob(widget.video.id);
    if (mounted) {
      setState(() {
        _hasApplied = hasApplied;
      });
    }
  }

  Future<void> _applyToJob() async {
    setState(() {
      _isApplying = true;
    });

    final success = await context.read<PostProvider>().applyToJob(widget.video.id);

    if (mounted) {
      setState(() {
        _isApplying = false;
        if (success) {
          _hasApplied = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Отклик отправлен!' : '❌ Ошибка отправки отклика',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        Row(
          children: [
            Text(
              '@${widget.video.author.username}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.video.author.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: AppColors.secondary,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Description
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            widget.video.description,
            maxLines: _isExpanded ? null : 2,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),

        // Tags
        if (widget.video.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.video.tags.map((tag) {
              return Text(
                '#$tag',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],

        // Music info
        if (widget.video.musicName != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.music_note,
                color: AppColors.textPrimary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${widget.video.musicName} - ${widget.video.musicAuthor ?? 'Неизвестно'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Кнопка "Откликнуться"
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _hasApplied || _isApplying ? null : _applyToJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasApplied 
                  ? Colors.grey.shade800 
                  : const Color(0xFF25F4EE),
              foregroundColor: _hasApplied ? Colors.grey : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.grey,
            ),
            child: _isApplying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasApplied ? Icons.check_circle : Icons.work,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasApplied ? 'Вы откликнулись' : 'Откликнуться',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

