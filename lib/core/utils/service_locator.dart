import '../../data/datasources/local_video_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import '../../presentation/providers/video_provider.dart';
import '../../presentation/providers/auth_provider.dart';

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
  late final VideoProvider _videoProvider;
  late final AuthProvider _authProvider;

  // Configuration
  bool _useRemoteData = false;

  void init({bool useRemoteData = false}) {
    _useRemoteData = useRemoteData;

    // Initialize datasources
    _localDatasource = LocalVideoDatasource();
    _supabaseDatasource = SupabaseDatasource();

    // Initialize repository
    _videoRepository = VideoRepositoryImpl(
      _useRemoteData ? _supabaseDatasource as dynamic : _localDatasource,
    );

    // Initialize providers
    _videoProvider = VideoProvider(_videoRepository);
    _authProvider = AuthProvider(_supabaseDatasource);
  }

  // Getters
  VideoProvider get videoProvider => _videoProvider;
  VideoRepository get videoRepository => _videoRepository;
  AuthProvider get authProvider => _authProvider;
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

