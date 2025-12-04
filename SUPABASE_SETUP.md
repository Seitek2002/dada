# 🗄️ Структура базы данных Supabase для TikTok Clone

## 📋 Таблицы

### 1. 👤 users (Пользователи)

Основная таблица пользователей (расширяет auth.users от Supabase)

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  cover_url TEXT, -- обложка профиля
  bio TEXT,
  website TEXT,
  location TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),

  -- Счетчики
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  posts_count INT DEFAULT 0,

  -- Статус
  is_verified BOOLEAN DEFAULT false,
  is_private BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,

  -- Настройки
  allow_comments BOOLEAN DEFAULT true,
  allow_duet BOOLEAN DEFAULT true,
  allow_stitch BOOLEAN DEFAULT true,
  allow_downloads BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE
);

-- Индексы
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

---

### 2. 📁 categories (Категории)

Категории для контента

```sql
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  emoji TEXT,
  description TEXT,
  color TEXT, -- hex color
  icon_url TEXT,

  -- Статистика
  posts_count INT DEFAULT 0,
  followers_count INT DEFAULT 0,

  is_active BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_display_order ON categories(display_order);

-- Начальные данные
INSERT INTO categories (name, slug, emoji, color) VALUES
  ('Comedy', 'comedy', '🤣', '#FFD93D'),
  ('Music', 'music', '🎵', '#FF6B9D'),
  ('Dance', 'dance', '💃', '#C65BCF'),
  ('DIY', 'diy', '✂️', '#6BCF7F'),
  ('Beauty', 'beauty', '💄', '#FF8FAB'),
  ('Fitness', 'fitness', '🏋️', '#FF6B6B'),
  ('Food', 'food', '🍔', '#FFB84D'),
  ('Art', 'art', '🎨', '#9B88FA'),
  ('Animals', 'animals', '🐶', '#8BC34A'),
  ('Travel', 'travel', '🌍', '#4DB6AC'),
  ('Fashion', 'fashion', '👗', '#E91E63'),
  ('Technology', 'technology', '📱', '#2196F3'),
  ('Education', 'education', '📚', '#009688'),
  ('Lifestyle', 'lifestyle', '☀️', '#FFCA28'),
  ('Gaming', 'gaming', '🎮', '#9C27B0'),
  ('Sports', 'sports', '⚽', '#FF5722');
```

---

### 3. 🏷️ tags (Теги/Хештеги)

Теги для контента

```sql
CREATE TABLE public.tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL, -- без #
  normalized_name TEXT UNIQUE NOT NULL, -- lowercase for search

  -- Статистика
  posts_count INT DEFAULT 0,
  views_count BIGINT DEFAULT 0,

  -- Трендовость
  is_trending BOOLEAN DEFAULT false,
  trending_score FLOAT DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_normalized_name ON tags(normalized_name);
CREATE INDEX idx_tags_trending ON tags(is_trending, trending_score DESC);
CREATE INDEX idx_tags_posts_count ON tags(posts_count DESC);
```

---

### 4. 📱 posts (Посты - видео/изображения)

Основная таблица контента

```sql
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Тип контента
  media_type TEXT NOT NULL CHECK (media_type IN ('video', 'image', 'carousel')),

  -- Медиа файлы
  media_url TEXT NOT NULL, -- основное видео/изображение
  thumbnail_url TEXT,
  preview_url TEXT, -- для превью в ленте

  -- Для карусели (несколько изображений)
  media_urls TEXT[], -- массив URL для carousel

  -- Метаданные медиа
  duration INT, -- длительность видео в секундах
  width INT,
  height INT,
  aspect_ratio FLOAT,
  file_size BIGINT,
  format TEXT, -- mp4, jpg, png и т.д.

  -- Контент
  caption TEXT, -- описание
  category_id UUID REFERENCES categories(id),

  -- Музыка/аудио
  music_id UUID REFERENCES music(id),
  music_name TEXT,
  music_author TEXT,
  original_sound_id UUID, -- если это оригинальный звук

  -- Счетчики
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  saves_count INT DEFAULT 0,
  views_count BIGINT DEFAULT 0,

  -- Engagement метрики
  engagement_rate FLOAT DEFAULT 0,
  completion_rate FLOAT DEFAULT 0, -- процент досмотров

  -- Настройки
  allow_comments BOOLEAN DEFAULT true,
  allow_duet BOOLEAN DEFAULT true,
  allow_stitch BOOLEAN DEFAULT true,
  is_private BOOLEAN DEFAULT false,

  -- Модерация
  is_published BOOLEAN DEFAULT true,
  is_flagged BOOLEAN DEFAULT false,
  moderation_status TEXT DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),

  -- Геолокация
  location TEXT,
  latitude FLOAT,
  longitude FLOAT,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_media_type ON posts(media_type);
CREATE INDEX idx_posts_published_at ON posts(published_at DESC);
CREATE INDEX idx_posts_views_count ON posts(views_count DESC);
CREATE INDEX idx_posts_likes_count ON posts(likes_count DESC);
CREATE INDEX idx_posts_is_published ON posts(is_published);
```

---

### 5. 🎵 music (Музыка/Звуки)

Аудио треки для постов

```sql
CREATE TABLE public.music (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  artist TEXT,
  album TEXT,

  -- Файл
  audio_url TEXT NOT NULL,
  cover_url TEXT,

  -- Метаданные
  duration INT,
  genre TEXT,

  -- Статистика
  posts_count INT DEFAULT 0,

  -- Тип
  is_original BOOLEAN DEFAULT false, -- оригинальный звук от пользователя
  original_author_id UUID REFERENCES users(id),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_music_title ON music(title);
CREATE INDEX idx_music_artist ON music(artist);
CREATE INDEX idx_music_posts_count ON music(posts_count DESC);
```

---

### 6. 🏷️ post_tags (Связь постов и тегов)

Many-to-many связь

```sql
CREATE TABLE public.post_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(post_id, tag_id)
);

-- Индексы
CREATE INDEX idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX idx_post_tags_tag_id ON post_tags(tag_id);
```

---

### 7. ❤️ likes (Лайки)

Лайки на посты

```sql
CREATE TABLE public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, post_id)
);

-- Индексы
CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_created_at ON likes(created_at DESC);
```

---

### 8. 💬 comments (Комментарии)

Комментарии к постам

```sql
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  text TEXT NOT NULL,

  -- Вложенные комментарии
  parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  reply_to_user_id UUID REFERENCES users(id),

  -- Счетчики
  likes_count INT DEFAULT 0,
  replies_count INT DEFAULT 0,

  -- Модерация
  is_pinned BOOLEAN DEFAULT false,
  is_flagged BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_author_id ON comments(author_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
```

---

### 9. 💬 comment_likes (Лайки комментариев)

```sql
CREATE TABLE public.comment_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, comment_id)
);

-- Индексы
CREATE INDEX idx_comment_likes_user_id ON comment_likes(user_id);
CREATE INDEX idx_comment_likes_comment_id ON comment_likes(comment_id);
```

---

### 10. 👥 follows (Подписки)

Система подписок

```sql
CREATE TABLE public.follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Настройки уведомлений
  notifications_enabled BOOLEAN DEFAULT true,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- Индексы
CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);
CREATE INDEX idx_follows_created_at ON follows(created_at DESC);
```

---

### 11. 💾 saves (Сохраненные посты)

Закладки пользователей

```sql
CREATE TABLE public.saves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,

  -- Коллекции/папки
  collection_name TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, post_id)
);

-- Индексы
CREATE INDEX idx_saves_user_id ON saves(user_id);
CREATE INDEX idx_saves_post_id ON saves(post_id);
CREATE INDEX idx_saves_collection_name ON saves(collection_name);
```

---

### 12. 🔔 notifications (Уведомления)

```sql
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Тип уведомления
  type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'mention', 'system')),

  -- Контент
  title TEXT,
  message TEXT NOT NULL,

  -- Связанные объекты
  actor_id UUID REFERENCES users(id), -- кто сделал действие
  post_id UUID REFERENCES posts(id),
  comment_id UUID REFERENCES comments(id),

  -- Статус
  is_read BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

---

### 13. 💬 messages (Сообщения в чатах)

```sql
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Контент
  text TEXT,
  media_url TEXT,
  media_type TEXT CHECK (media_type IN ('image', 'video', 'audio', 'file')),

  -- Статус
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
```

---

### 14. 📊 analytics_events (Аналитика)

События для отслеживания поведения пользователей

```sql
CREATE TABLE public.analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,

  -- Тип события
  event_type TEXT NOT NULL CHECK (event_type IN (
    'view', 'watch_25', 'watch_50', 'watch_75', 'watch_100',
    'like', 'comment', 'share', 'save', 'profile_visit'
  )),

  -- Метаданные
  watch_duration INT, -- в секундах
  device_type TEXT,
  platform TEXT,
  ip_address INET,
  user_agent TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы
CREATE INDEX idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_post_id ON analytics_events(post_id);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);

-- Партиционирование по времени (опционально, для больших объемов)
-- CREATE INDEX idx_analytics_created_at_brin ON analytics_events USING BRIN (created_at);
```

---

### 15. 🎯 user_interests (Интересы пользователей)

Выбранные категории пользователей

```sql
CREATE TABLE public.user_interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, category_id)
);

-- Индексы
CREATE INDEX idx_user_interests_user_id ON user_interests(user_id);
CREATE INDEX idx_user_interests_category_id ON user_interests(category_id);
```

---

## 🔒 Row Level Security (RLS) Policies

### Включение RLS для всех таблиц

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE music ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE saves ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_interests ENABLE ROW LEVEL SECURITY;
```

### Политики для users

```sql
-- Все могут читать публичные профили
CREATE POLICY "Public profiles are viewable by everyone"
  ON users FOR SELECT
  USING (true);

-- Пользователи могут обновлять свой профиль
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Пользователи могут создавать свой профиль
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Политики для posts

```sql
-- Все могут читать опубликованные посты
CREATE POLICY "Published posts are viewable by everyone"
  ON posts FOR SELECT
  USING (is_published = true AND is_private = false);

-- Авторы могут видеть свои посты
CREATE POLICY "Authors can view own posts"
  ON posts FOR SELECT
  USING (auth.uid() = author_id);

-- Авторизованные пользователи могут создавать посты
CREATE POLICY "Authenticated users can create posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = author_id);

-- Авторы могут обновлять свои посты
CREATE POLICY "Authors can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = author_id);

-- Авторы могут удалять свои посты
CREATE POLICY "Authors can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = author_id);
```

### Политики для likes

```sql
-- Все могут читать лайки
CREATE POLICY "Likes are viewable by everyone"
  ON likes FOR SELECT
  USING (true);

-- Авторизованные могут ставить лайки
CREATE POLICY "Authenticated users can like"
  ON likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Пользователи могут удалять свои лайки
CREATE POLICY "Users can remove own likes"
  ON likes FOR DELETE
  USING (auth.uid() = user_id);
```

### Политики для comments

```sql
-- Все могут читать комментарии
CREATE POLICY "Comments are viewable by everyone"
  ON comments FOR SELECT
  USING (true);

-- Авторизованные могут комментировать
CREATE POLICY "Authenticated users can comment"
  ON comments FOR INSERT
  WITH CHECK (auth.uid() = author_id);

-- Авторы могут обновлять свои комментарии
CREATE POLICY "Authors can update own comments"
  ON comments FOR UPDATE
  USING (auth.uid() = author_id);

-- Авторы могут удалять свои комментарии
CREATE POLICY "Authors can delete own comments"
  ON comments FOR DELETE
  USING (auth.uid() = author_id);
```

### Политики для follows

```sql
-- Все могут читать подписки
CREATE POLICY "Follows are viewable by everyone"
  ON follows FOR SELECT
  USING (true);

-- Пользователи могут подписываться
CREATE POLICY "Users can follow others"
  ON follows FOR INSERT
  WITH CHECK (auth.uid() = follower_id);

-- Пользователи могут отписываться
CREATE POLICY "Users can unfollow"
  ON follows FOR DELETE
  USING (auth.uid() = follower_id);
```

### Политики для notifications

```sql
-- Пользователи видят только свои уведомления
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Пользователи могут обновлять свои уведомления
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);
```

### Политики для messages

```sql
-- Пользователи видят только свои сообщения
CREATE POLICY "Users can view own messages"
  ON messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Пользователи могут отправлять сообщения
CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);
```

---

## ⚡ Триггеры для автоматического обновления счетчиков

### Функция для обновления updated_at

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Применить ко всем таблицам с updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Функции для счетчиков

```sql
-- Обновление likes_count для постов
CREATE OR REPLACE FUNCTION increment_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  UPDATE users SET likes_count = likes_count + 1 WHERE id = (SELECT author_id FROM posts WHERE id = NEW.post_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_post_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
  UPDATE users SET likes_count = likes_count - 1 WHERE id = (SELECT author_id FROM posts WHERE id = OLD.post_id);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_post_likes AFTER INSERT ON likes
  FOR EACH ROW EXECUTE FUNCTION increment_post_likes();

CREATE TRIGGER trigger_decrement_post_likes AFTER DELETE ON likes
  FOR EACH ROW EXECUTE FUNCTION decrement_post_likes();

-- Обновление comments_count для постов
CREATE OR REPLACE FUNCTION increment_post_comments()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_post_comments()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_post_comments AFTER INSERT ON comments
  FOR EACH ROW EXECUTE FUNCTION increment_post_comments();

CREATE TRIGGER trigger_decrement_post_comments AFTER DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION decrement_post_comments();

-- Обновление followers_count
CREATE OR REPLACE FUNCTION increment_followers()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
  UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_followers()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
  UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_followers AFTER INSERT ON follows
  FOR EACH ROW EXECUTE FUNCTION increment_followers();

CREATE TRIGGER trigger_decrement_followers AFTER DELETE ON follows
  FOR EACH ROW EXECUTE FUNCTION decrement_followers();
```

---

## 🔍 Полезные View (представления)

### Лента "For You" (рекомендации)

```sql
CREATE OR REPLACE VIEW for_you_feed AS
SELECT
  p.*,
  u.username,
  u.display_name,
  u.avatar_url,
  u.is_verified,
  COALESCE(l.is_liked, false) as is_liked_by_current_user,
  COALESCE(s.is_saved, false) as is_saved_by_current_user
FROM posts p
JOIN users u ON p.author_id = u.id
LEFT JOIN LATERAL (
  SELECT true as is_liked
  FROM likes
  WHERE post_id = p.id AND user_id = auth.uid()
) l ON true
LEFT JOIN LATERAL (
  SELECT true as is_saved
  FROM saves
  WHERE post_id = p.id AND user_id = auth.uid()
) s ON true
WHERE p.is_published = true
  AND p.is_private = false
ORDER BY p.created_at DESC;
```

---

## 📦 Storage Buckets

Создайте эти bucket'ы в Supabase Storage:

1. **avatars** - аватары пользователей
2. **covers** - обложки профилей
3. **posts-videos** - видео контент
4. **posts-images** - изображения
5. **posts-thumbnails** - превью/миниатюры
6. **music** - аудио файлы
7. **chat-media** - медиа из чатов

### Политики Storage

```sql
-- Аватары доступны всем
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Пользователи могут загружать свои аватары
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Посты доступны всем
CREATE POLICY "Posts media are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id IN ('posts-videos', 'posts-images', 'posts-thumbnails'));

-- Авторизованные могут загружать посты
CREATE POLICY "Authenticated users can upload posts"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id IN ('posts-videos', 'posts-images', 'posts-thumbnails') AND auth.role() = 'authenticated');
```

---

## 🔑 Данные для подключения Supabase

Мне нужны следующие данные из вашего проекта Supabase:

### 1. Project URL

```
Где найти: Supabase Dashboard → Settings → API
Выглядит как: https://xxxxxxxxxxxxx.supabase.co
```

### 2. Anon/Public Key

```
Где найти: Supabase Dashboard → Settings → API → Project API keys
Длинный ключ начинающийся с: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Service Role Key (опционально, для admin операций)

```
Где найти: Supabase Dashboard → Settings → API → Project API keys
⚠️ Держите в секрете! Не коммитьте в git!
```

---

## 📝 Порядок создания

1. Создайте проект в Supabase
2. Скопируйте SQL код выше
3. Выполните в SQL Editor (Supabase Dashboard → SQL Editor)
4. Создайте Storage buckets
5. Настройте Storage policies
6. Дайте мне Project URL и Anon Key
7. Я интегрирую в приложение!

---

## 🎯 Что это даст

✅ Поддержка видео И изображений
✅ Система тегов и категорий
✅ Полная система комментариев
✅ Лайки и сохранения
✅ Подписки между пользователями
✅ Чаты и уведомления
✅ Детальная аналитика
✅ Масштабируемая архитектура
✅ Безопасность через RLS
✅ Автоматические счетчики

Готов к миллионам пользователей! 🚀
