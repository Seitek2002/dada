# TikTok Clone - Flutter

Полнофункциональная копия TikTok, созданная на Flutter с использованием Clean Architecture.

## 🏗️ Архитектура проекта

Проект построен по принципам **Clean Architecture** для обеспечения масштабируемости и поддерживаемости:

```
lib/
├── core/                      # Ядро приложения
│   ├── constants/            # Константы (цвета, размеры)
│   ├── theme/                # Темы приложения
│   └── utils/                # Утилиты и Service Locator
├── data/                     # Слой данных
│   ├── datasources/          # Источники данных (локальные/удаленные)
│   ├── models/               # Модели данных
│   └── repositories/         # Реализация репозиториев
├── domain/                   # Бизнес-логика
│   ├── entities/             # Сущности
│   └── repositories/         # Интерфейсы репозиториев
└── presentation/             # UI слой
    ├── providers/            # State management (Provider)
    ├── screens/              # Экраны приложения
    └── widgets/              # Переиспользуемые виджеты
```

## ✨ Реализованные функции

### 📱 Основные экраны
- **Home (Лента)** - Вертикальный скролл видео с автовоспроизведением
- **Discover (Поиск)** - Поиск видео и пользователей, трендовые хештеги
- **Create (Создание)** - Экран создания видео (UI готов)
- **Inbox (Сообщения)** - Список чатов
- **Profile (Профиль)** - Профиль пользователя с видео

### 🎥 Видео функционал
- ✅ Вертикальный скролл видео (как в TikTok)
- ✅ Автовоспроизведение при скролле
- ✅ Пауза/воспроизведение по тапу
- ✅ Отслеживание прогресса просмотра (25%, 50%, 75%, 100%)
- ✅ Лайки с анимацией
- ✅ Комментарии (bottom sheet)
- ✅ Шеринг через Share API
- ✅ Информация о музыке

### 📊 Аналитика (готово к интеграции)
- Отслеживание просмотров видео
- Отслеживание завершения просмотра
- Отслеживание лайков
- Отслеживание комментариев
- Отслеживание шеринга

## 🛠️ Технологический стек

### Основные пакеты
- **video_player** - Воспроизведение видео
- **provider** - State management
- **flutter_svg** - SVG иконки
- **share_plus** - Шеринг контента
- **cached_network_image** - Кэширование изображений

### Архитектурные решения
- **Clean Architecture** - Разделение на слои (data, domain, presentation)
- **Repository Pattern** - Абстракция источников данных
- **Provider** - Управление состоянием (аналог React Context + Hooks)
- **Service Locator** - Dependency Injection

## 🚀 Запуск проекта

### Требования
- Flutter SDK 3.10.1 или выше
- Dart 3.0 или выше

### Установка

1. Клонируйте репозиторий
```bash
git clone <repository-url>
cd tiktok_flutter
```

2. Установите зависимости
```bash
flutter pub get
```

3. Запустите приложение
```bash
flutter run
```

## 📁 Добавление видео

Для тестирования добавьте видео файлы в папку `assets/videos/`:
```
assets/
└── videos/
    ├── video1.mp4
    ├── video2.mp4
    ├── video3.mp4
    ├── video4.mp4
    └── video5.mp4
```

## 🔮 Будущая интеграция

### Supabase (Backend)
Проект готов к интеграции с Supabase:

**Структура таблиц:**
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT false
);

-- Videos table
CREATE TABLE videos (
  id UUID PRIMARY KEY,
  video_url TEXT,
  thumbnail_url TEXT,
  description TEXT,
  author_id UUID REFERENCES users(id),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  tags TEXT[],
  music_name TEXT,
  music_author TEXT
);

-- Video views (analytics)
CREATE TABLE video_views (
  id UUID PRIMARY KEY,
  video_id UUID REFERENCES videos(id),
  user_id UUID REFERENCES users(id),
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Video completions (analytics)
CREATE TABLE video_completions (
  id UUID PRIMARY KEY,
  video_id UUID REFERENCES videos(id),
  user_id UUID REFERENCES users(id),
  watch_percentage FLOAT,
  timestamp TIMESTAMP DEFAULT NOW()
);
```

**Для интеграции:**
1. Добавьте пакет `supabase_flutter`
2. Раскомментируйте код в `lib/data/datasources/remote_video_datasource.dart`
3. Переключите `useRemoteData: true` в `main.dart`

### Mux Video
Для потокового видео:
1. Создайте аккаунт на [mux.com](https://mux.com)
2. Получите API ключи
3. Реализуйте `uploadVideo()` в `remote_video_datasource.dart`

### Аналитика
Все методы отслеживания уже готовы в:
- `VideoProvider` - для UI событий
- `VideoRepository` - для бизнес-логики
- `RemoteVideoDatasource` - для сохранения в БД

## 📝 Примечания для React разработчика

Если вы знакомы с React, вот аналогии:

| Flutter | React |
|---------|-------|
| `StatelessWidget` | Functional Component |
| `StatefulWidget` | Component with useState |
| `Provider` | Context API + useContext |
| `ChangeNotifier` | Custom Hook with state |
| `Consumer` | useContext |
| `Navigator` | React Router |
| `ListView.builder` | map() + key |

### State Management
```dart
// Flutter Provider (аналог React Context)
Provider<VideoProvider>(
  create: (_) => VideoProvider(),
  child: Consumer<VideoProvider>(
    builder: (context, provider, child) {
      return Text(provider.videos.length);
    },
  ),
)
```

```javascript
// React Context
const VideoContext = createContext();
const { videos } = useContext(VideoContext);
```

## 🎨 Дизайн система

Все цвета и стили находятся в:
- `lib/core/constants/app_colors.dart` - Цветовая палитра
- `lib/core/theme/app_theme.dart` - Темы приложения

## 📱 Скриншоты

(Добавьте скриншоты после запуска)

## 🤝 Contributing

Pull requests приветствуются!

## 📄 Лицензия

MIT License
