import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/video_entity.dart';

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
                  '${widget.video.musicName} - ${widget.video.musicAuthor ?? 'Unknown'}',
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
      ],
    );
  }
}

