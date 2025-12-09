import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';

class UserProfileScreen extends StatelessWidget {
  final UserEntity user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@${user.username}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: AppColors.secondary,
                size: 18,
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSecondary, width: 2),
                image: user.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 48, color: AppColors.textPrimary)
                  : null,
            ),

            const SizedBox(height: 16),

            // Display name
            Text(
              user.displayName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(
                  count: _formatCount(user.followingCount),
                  label: 'Подписки',
                  onTap: () {},
                ),
                const SizedBox(width: 32),
                _StatItem(
                  count: _formatCount(user.followersCount),
                  label: 'Подписчики',
                  onTap: () {},
                ),
                const SizedBox(width: 32),
                _StatItem(
                  count: _formatCount(user.likesCount),
                  label: 'Лайки',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Follow/Unfollow
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25F4EE),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Подписаться'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Message
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Icon(Icons.message),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bio
            if (user.bio != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Tabs
            DefaultTabController(
              length: 1,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.textPrimary,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.grid_on),
                        text: 'Вакансии',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        // Videos grid
                        GridView.builder(
                          padding: const EdgeInsets.all(2),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 9 / 16,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return Container(
                              color: AppColors.surfaceLight,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: AppColors.textPrimary,
                                      size: 32,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.play_arrow,
                                          color: AppColors.textPrimary,
                                          size: 12,
                                        ),
                                        Text(
                                          '${(index + 1) * 125}K',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;

  const _StatItem({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

