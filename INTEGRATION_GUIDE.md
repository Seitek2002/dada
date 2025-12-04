# 🔌 Руководство по интеграции

Этот документ объясняет как подключить реальные сервисы к приложению.

## 📊 Supabase - База данных

### Шаг 1: Установка

```bash
flutter pub add supabase_flutter
```

### Шаг 2: Инициализация

В `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // ... остальной код
}
```

### Шаг 3: Создание таблиц

Выполните этот SQL в Supabase Dashboard:

```sql
-- Таблица пользователей
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица видео
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  description TEXT NOT NULL,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  tags TEXT[],
  music_name TEXT,
  music_author TEXT
);

-- Таблица лайков
CREATE TABLE video_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(video_id, user_id)
);

-- Таблица комментариев
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  reply_to_id UUID REFERENCES comments(id) ON DELETE CASCADE
);

-- Таблица просмотров (аналитика)
CREATE TABLE video_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Таблица завершений просмотра (аналитика)
CREATE TABLE video_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  watch_percentage FLOAT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Таблица шерингов (аналитика)
CREATE TABLE video_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Функции для инкремента счетчиков
CREATE OR REPLACE FUNCTION increment_likes(video_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE videos SET likes_count = likes_count + 1 WHERE id = video_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_likes(video_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE videos SET likes_count = likes_count - 1 WHERE id = video_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_views(video_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE videos SET views_count = views_count + 1 WHERE id = video_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_comments(video_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE videos SET comments_count = comments_count + 1 WHERE id = video_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_shares(video_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE videos SET shares_count = shares_count + 1 WHERE id = video_id;
END;
$$ LANGUAGE plpgsql;
```

### Шаг 4: Включение Row Level Security (RLS)

```sql
-- Включить RLS для всех таблиц
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Политики для чтения (все могут читать)
CREATE POLICY "Public videos are viewable by everyone"
  ON videos FOR SELECT
  USING (true);

CREATE POLICY "Public users are viewable by everyone"
  ON users FOR SELECT
  USING (true);

-- Политики для записи (только авторизованные пользователи)
CREATE POLICY "Users can insert their own videos"
  ON videos FOR INSERT
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update their own videos"
  ON videos FOR UPDATE
  USING (auth.uid() = author_id);
```

### Шаг 5: Обновление RemoteVideoDatasource

В `lib/data/datasources/remote_video_datasource.dart` раскомментируйте код и добавьте:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteVideoDatasource {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<List<VideoModel>> getVideos() async {
    final response = await _supabase
        .from('videos')
        .select('*, author:users(*)')
        .order('created_at', ascending: false)
        .limit(20);
    
    return (response as List)
        .map((json) => VideoModel.fromJson(json))
        .toList();
  }
  
  // ... остальные методы
}
```

### Шаг 6: Переключение на удаленные данные

В `lib/main.dart`:

```dart
ServiceLocator().init(useRemoteData: true); // Вместо false
```

## 🎥 Mux Video - Потоковое видео

### Шаг 1: Регистрация

1. Зарегистрируйтесь на [mux.com](https://mux.com)
2. Создайте новый проект
3. Получите Access Token и Secret Key

### Шаг 2: Установка

```bash
flutter pub add http dio
```

### Шаг 3: Загрузка видео

```dart
class MuxVideoService {
  final String _accessToken = 'YOUR_MUX_ACCESS_TOKEN';
  final String _secretKey = 'YOUR_MUX_SECRET_KEY';
  
  Future<String> uploadVideo(File videoFile) async {
    // 1. Создать Direct Upload URL
    final uploadResponse = await http.post(
      Uri.parse('https://api.mux.com/video/v1/uploads'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_accessToken:$_secretKey'))}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'new_asset_settings': {
          'playback_policy': ['public'],
        },
      }),
    );
    
    final uploadData = jsonDecode(uploadResponse.body);
    final uploadUrl = uploadData['data']['url'];
    final assetId = uploadData['data']['asset_id'];
    
    // 2. Загрузить файл
    await _uploadFile(videoFile, uploadUrl);
    
    // 3. Дождаться обработки и получить playback URL
    final playbackId = await _waitForAsset(assetId);
    
    return 'https://stream.mux.com/$playbackId.m3u8';
  }
  
  Future<void> _uploadFile(File file, String url) async {
    final dio = Dio();
    await dio.put(
      url,
      data: file.openRead(),
      options: Options(
        headers: {
          'Content-Type': 'video/mp4',
          'Content-Length': file.lengthSync(),
        },
      ),
    );
  }
  
  Future<String> _waitForAsset(String assetId) async {
    while (true) {
      final response = await http.get(
        Uri.parse('https://api.mux.com/video/v1/assets/$assetId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_accessToken:$_secretKey'))}',
        },
      );
      
      final data = jsonDecode(response.body);
      final status = data['data']['status'];
      
      if (status == 'ready') {
        return data['data']['playback_ids'][0]['id'];
      }
      
      await Future.delayed(Duration(seconds: 2));
    }
  }
}
```

### Шаг 4: Использование в приложении

```dart
// В CreateScreen
final muxService = MuxVideoService();
final playbackUrl = await muxService.uploadVideo(videoFile);

// Сохранить в Supabase
await supabase.from('videos').insert({
  'video_url': playbackUrl,
  'author_id': currentUserId,
  // ... другие поля
});
```

## 📈 Аналитика - Отслеживание действий

### Вариант 1: Использование Supabase (уже готово)

Все методы аналитики уже реализованы в `RemoteVideoDatasource`. Просто раскомментируйте код!

### Вариант 2: Firebase Analytics

```bash
flutter pub add firebase_core firebase_analytics
```

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logVideoView(String videoId) async {
    await _analytics.logEvent(
      name: 'video_view',
      parameters: {
        'video_id': videoId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logVideoCompletion(String videoId, double percentage) async {
    await _analytics.logEvent(
      name: 'video_completion',
      parameters: {
        'video_id': videoId,
        'watch_percentage': percentage,
      },
    );
  }
  
  // ... другие события
}
```

### Вариант 3: Mixpanel

```bash
flutter pub add mixpanel_flutter
```

```dart
class AnalyticsService {
  late Mixpanel _mixpanel;
  
  Future<void> init() async {
    _mixpanel = await Mixpanel.init('YOUR_MIXPANEL_TOKEN');
  }
  
  Future<void> trackVideoView(String videoId) async {
    _mixpanel.track('Video View', properties: {
      'video_id': videoId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## 🔐 Аутентификация

### С Supabase Auth

```dart
// Регистрация
final response = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
);

// Вход
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Получить текущего пользователя
final user = Supabase.instance.client.auth.currentUser;

// Выход
await Supabase.instance.client.auth.signOut();
```

### Добавить в приложение

Создайте `lib/presentation/providers/auth_provider.dart`:

```dart
class AuthProvider with ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _currentUser = response.user;
    notifyListeners();
  }
  
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
```

## 🎨 Дополнительные улучшения

### 1. Кэширование видео

```bash
flutter pub add flutter_cache_manager
```

### 2. Оптимизация изображений

```bash
flutter pub add cached_network_image
```

### 3. Push уведомления

```bash
flutter pub add firebase_messaging
```

### 4. Deep Links

```bash
flutter pub add uni_links
```

## 📝 Чеклист интеграции

- [ ] Создать аккаунт Supabase
- [ ] Создать таблицы в базе данных
- [ ] Настроить Row Level Security
- [ ] Добавить Supabase в проект
- [ ] Протестировать подключение
- [ ] Создать аккаунт Mux (опционально)
- [ ] Настроить загрузку видео
- [ ] Добавить аналитику
- [ ] Реализовать аутентификацию
- [ ] Протестировать все функции

## 🆘 Помощь

Если возникли проблемы:
1. Проверьте документацию Supabase: https://supabase.com/docs
2. Проверьте документацию Mux: https://docs.mux.com
3. Все TODO комментарии в коде указывают что нужно сделать
4. Структура уже готова, нужно только подключить сервисы!

