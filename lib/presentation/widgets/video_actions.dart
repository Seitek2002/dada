import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import '../../core/constants/app_colors.dart';
import '../../domain/entities/video_entity.dart';
import '../screens/profile/user_profile_screen.dart';

class VideoActions extends StatelessWidget {
  final VideoEntity video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const VideoActions({
    super.key,
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  String _formatCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(user: video.author),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textPrimary, width: 1),
              image: video.author.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(video.author.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: video.author.avatarUrl == null
                ? const Icon(Icons.person, color: AppColors.textPrimary)
                : null,
          ),
        ),
        const SizedBox(height: 24),

        // Like button
        _ActionButton(
          icon: video.isLiked ? 'assets/icons/heart_filled.svg' : 'assets/icons/heart.svg',
          count: _formatCount(video.likesCount),
          onTap: onLike,
          color: video.isLiked ? AppColors.like : AppColors.textPrimary,
        ),
        const SizedBox(height: 24),

        // Comment button
        _ActionButton(
          icon: 'assets/icons/comment.svg',
          count: _formatCount(video.commentsCount),
          onTap: onComment,
        ),
        const SizedBox(height: 24),

        // Share button
        _ActionButton(
          icon: 'assets/icons/share.svg',
          count: _formatCount(video.sharesCount),
          onTap: () async {
            onShare();
            // ignore: deprecated_member_use
            await share_plus.Share.share(
              'Посмотри эту вакансию в DaDa! ${video.description}',
              subject: 'Вакансия DaDa',
            );
          },
        ),
        const SizedBox(height: 24),

        // Music disc (rotating animation)
        GestureDetector(
          onTap: () {
            // TODO: Navigate to music page
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/music.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String count;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

