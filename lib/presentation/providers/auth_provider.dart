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

  /// Анонимный вход (для онбординга)
  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _datasource.signInAnonymously();
      _currentUser = response.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in signInAnonymously: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Сохранить интересы из онбординга
  Future<bool> saveInterests(List<String> categoryNames) async {
    try {
      await _datasource.saveUserInterests(categoryNames);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Сохранить минимальную зарплату из онбординга
  Future<bool> saveMinSalary(int minSalary) async {
    try {
      await _datasource.saveMinSalary(minSalary);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Сохранить локацию пользователя
  Future<bool> saveLocation({
    required double latitude,
    required double longitude,
    String? city,
  }) async {
    try {
      await _datasource.saveUserLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Проверить, анонимный ли пользователь
  Future<bool> isAnonymous() async {
    try {
      return await _datasource.isAnonymousUser();
    } catch (e) {
      return false;
    }
  }

  /// Вход через email/пароль
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

  /// Отправить магическую ссылку / OTP
  Future<bool> sendMagicLink({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _datasource.sendMagicLink(email: email);

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

  /// Подтвердить OTP
  Future<bool> verifyOTP({
    required String email,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _datasource.verifyOTP(
        email: email,
        token: token,
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

