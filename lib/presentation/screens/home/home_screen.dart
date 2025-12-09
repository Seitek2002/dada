import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import 'video_feed_item.dart';

class HomeScreen extends StatefulWidget {
  final bool isActive;
  
  const HomeScreen({super.key, this.isActive = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Load posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show following feed
              },
              child: const Text(
                'Избранное',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '|',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // Already on For You
              },
              child: const Text(
                'Для тебя',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (postProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${postProvider.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => postProvider.loadPosts(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (postProvider.posts.isEmpty) {
            return const Center(
              child: Text(
                'Нет доступных вакансий',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: postProvider.posts.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              
              // Предзагружаем следующие видео при переключении
              postProvider.preloadNextVideos(index);
            },
            itemBuilder: (context, index) {
              return VideoFeedItem(
                video: postProvider.posts[index],
                isCurrentPage: index == _currentPage && widget.isActive,
              );
            },
          );
        },
      ),
    );
  }
}

