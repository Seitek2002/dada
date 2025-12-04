import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock current user
  static const UserEntity _currentUser = UserEntity(
    id: 'current',
    username: 'myusername',
    displayName: 'My Display Name',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=current',
    bio: 'Welcome to my profile! 🎉\nContent creator | Dancer | Musician',
    followersCount: 125000,
    followingCount: 450,
    likesCount: 2500000,
    isVerified: false,
  );

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
              '@${_currentUser.username}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_currentUser.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: AppColors.secondary,
                size: 18,
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
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
                image: _currentUser.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_currentUser.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _currentUser.avatarUrl == null
                  ? const Icon(Icons.person, size: 48, color: AppColors.textPrimary)
                  : null,
            ),

            const SizedBox(height: 16),

            // Display name
            Text(
              _currentUser.displayName,
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
                  count: _formatCount(_currentUser.followingCount),
                  label: 'Following',
                  onTap: () {},
                ),
                const SizedBox(width: 32),
                _StatItem(
                  count: _formatCount(_currentUser.followersCount),
                  label: 'Followers',
                  onTap: () {},
                ),
                const SizedBox(width: 32),
                _StatItem(
                  count: _formatCount(_currentUser.likesCount),
                  label: 'Likes',
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
                        // TODO: Edit profile
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Share profile
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Icon(Icons.share),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bio
            if (_currentUser.bio != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _currentUser.bio!,
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
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.textPrimary,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.favorite_border)),
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
                          itemCount: 12,
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
                        // Liked videos
                        const Center(
                          child: Text(
                            'Liked videos',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
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

