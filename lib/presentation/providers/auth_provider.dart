import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../domain/entities/user_entity.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseDatasource _datasource;

  AuthProvider(this._datasource);

  User? _currentUser;
  UserEntity? _currentUserProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserEntity? get currentUserProfile => _currentUserProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Инициализация - проверка текущей сессии
  Future<void> init() async {
    _currentUser = _datasource.currentUser;
    if (_currentUser != null) {
      await _loadUserProfile();
    }
    notifyListeners();
  }

  /// Загрузить профиль пользователя
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final profile = await _datasource.getUserProfile(_currentUser!.id);
      _currentUserProfile = profile.toEntity();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Регистрация
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _datasource.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      _currentUser = response.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Вход
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _datasource.signIn(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Выход
  Future<void> signOut() async {
    await _datasource.signOut();
    _currentUser = null;
    _currentUserProfile = null;
    notifyListeners();
  }

  /// Обновить профиль
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _datasource.updateUserProfile(
        userId: _currentUser!.id,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

