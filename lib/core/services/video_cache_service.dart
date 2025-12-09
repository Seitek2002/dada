import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Сервис для предзагрузки и кеширования видео
class VideoCacheService {
  static final VideoCacheService _instance = VideoCacheService._internal();
  factory VideoCacheService() => _instance;
  VideoCacheService._internal();

  // Кеш менеджер для видео
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'video_cache',
      stalePeriod: const Duration(days: 7), // Видео хранятся 7 дней
      maxNrOfCacheObjects: 50, // Максимум 50 видео в кеше
      repo: JsonCacheInfoRepository(databaseName: 'video_cache'),
      fileService: HttpFileService(),
    ),
  );

  // Список URL которые сейчас загружаются
  final Set<String> _currentlyDownloading = {};

  /// Конвертировать Mux HLS URL в MP4 URL для кеширования
  String _convertToMp4Url(String url) {
    if (url.contains('stream.mux.com') && url.endsWith('.m3u8')) {
      // Преобразуем HLS в MP4 среднего качества
      return url.replaceAll('.m3u8', '/medium.mp4');
    }
    return url;
  }

  /// Получить закешированное видео или начать загрузку
  Future<String> getCachedVideoUrl(String url) async {
    try {
      // Для Mux используем MP4 версию для кеширования
      final cacheUrl = _convertToMp4Url(url);
      
      // Проверяем есть ли в кеше
      final fileInfo = await _cacheManager.getFileFromCache(cacheUrl);
      
      if (fileInfo != null) {
        debugPrint('✅ Mux видео из кеша: ${cacheUrl.substring(0, 50)}...');
        return fileInfo.file.path;
      }

      // Если нет - загружаем MP4 версию в фоне
      debugPrint('📥 Загружаем Mux MP4: ${cacheUrl.substring(0, 50)}...');
      _downloadInBackground(cacheUrl);
      
      // Возвращаем HLS URL для первого просмотра (адаптивное качество)
      return url;
    } catch (e) {
      debugPrint('❌ Ошибка кеширования: $e');
      return url;
    }
  }

  /// Предзагрузить видео в фоне
  Future<void> preloadVideo(String url) async {
    // Для Mux используем MP4 версию для кеширования
    final cacheUrl = _convertToMp4Url(url);
    
    if (_currentlyDownloading.contains(cacheUrl)) {
      debugPrint('⏳ Видео уже загружается: ${cacheUrl.substring(0, 50)}...');
      return;
    }

    try {
      // Проверяем есть ли уже в кеше
      final fileInfo = await _cacheManager.getFileFromCache(cacheUrl);
      if (fileInfo != null) {
        debugPrint('✅ Видео уже в кеше: ${cacheUrl.substring(0, 50)}...');
        return;
      }

      _downloadInBackground(cacheUrl);
    } catch (e) {
      debugPrint('❌ Ошибка предзагрузки: $e');
    }
  }

  /// Загрузить видео в фоне
  void _downloadInBackground(String url) {
    if (_currentlyDownloading.contains(url)) return;

    _currentlyDownloading.add(url);
    debugPrint('🚀 Начинаем фоновую загрузку: ${url.substring(0, 50)}...');

    _cacheManager.downloadFile(url).then((fileInfo) {
      _currentlyDownloading.remove(url);
      debugPrint('✅ Видео загружено: ${url.substring(0, 50)}...');
      debugPrint('📦 Размер: ${fileInfo.file.lengthSync() / 1024 / 1024} MB');
    }).catchError((error) {
      _currentlyDownloading.remove(url);
      debugPrint('❌ Ошибка загрузки: $error');
    });
  }

  /// Предзагрузить несколько следующих видео
  Future<void> preloadNextVideos(List<String> urls, {int count = 3}) async {
    debugPrint('🎬 Предзагружаем $count следующих видео');
    
    final videosToPreload = urls.take(count).toList();
    
    for (final url in videosToPreload) {
      await preloadVideo(url);
    }
  }

  /// Очистить весь кеш
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      _currentlyDownloading.clear();
      debugPrint('🗑️ Кеш очищен');
    } catch (e) {
      debugPrint('❌ Ошибка очистки кеша: $e');
    }
  }

  /// Получить информацию о кеше
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // Получаем список файлов из кеша
      int filesCount = 0;
      double totalSizeMb = 0;

      // CacheManager не предоставляет прямого метода getFilesFromCache
      // Поэтому возвращаем базовую информацию
      return {
        'files_count': filesCount,
        'total_size_mb': totalSizeMb,
        'downloading_count': _currentlyDownloading.length,
      };
    } catch (e) {
      debugPrint('❌ Ошибка получения информации о кеше: $e');
      return {
        'files_count': 0,
        'total_size_mb': 0,
        'downloading_count': 0,
      };
    }
  }

  /// Проверить есть ли видео в кеше
  Future<bool> isVideoCached(String url) async {
    try {
      // Для Mux используем MP4 версию для кеширования
      final cacheUrl = _convertToMp4Url(url);
      final fileInfo = await _cacheManager.getFileFromCache(cacheUrl);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }
}

