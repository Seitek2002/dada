import '../../data/datasources/local_video_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import '../../presentation/providers/video_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/post_provider.dart';

/// Service Locator для Dependency Injection
///
/// Управляет всеми зависимостями приложения
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Datasources
  late final LocalVideoDatasource _localDatasource;
  late final SupabaseDatasource _supabaseDatasource;

  // Repositories
  late final VideoRepository _videoRepository;

  // Providers
  VideoProvider? _videoProvider;
  late final AuthProvider _authProvider;
  late final PostProvider _postProvider;

  // Configuration
  bool _useRemoteData = false;

  void init({bool useRemoteData = false}) {
    _useRemoteData = useRemoteData;

    // Initialize datasources
    _supabaseDatasource = SupabaseDatasource();

    if (!_useRemoteData) {
      // Локальный режим - используем VideoProvider
      _localDatasource = LocalVideoDatasource();
      _videoRepository = VideoRepositoryImpl(_localDatasource);
      _videoProvider = VideoProvider(_videoRepository);
    } else {
      // Supabase режим - используем только PostProvider
      _videoProvider = null;
    }

    // Initialize providers (работают в обоих режимах)
    _authProvider = AuthProvider(_supabaseDatasource);
    _postProvider = PostProvider(_supabaseDatasource);
  }

  // Getters
  VideoProvider get videoProvider {
    if (_videoProvider == null) {
      throw Exception('VideoProvider доступен только в локальном режиме');
    }
    return _videoProvider!;
  }

  VideoRepository get videoRepository => _videoRepository;
  AuthProvider get authProvider => _authProvider;
  PostProvider get postProvider => _postProvider;
  SupabaseDatasource get supabaseDatasource => _supabaseDatasource;

  /// Переключить на Supabase данные
  void switchToRemoteData() {
    _useRemoteData = true;
    // Reinitialize with Supabase
    init(useRemoteData: true);
  }

  /// Переключить на локальные данные
  void switchToLocalData() {
    _useRemoteData = false;
    init(useRemoteData: false);
  }
}
