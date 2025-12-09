-- ============================================
-- СХЕМА БД ДЛЯ DaDa! (Платформа поиска работы через видео)
-- ============================================

-- 0. ВКЛЮЧЕНИЕ РАСШИРЕНИЙ ДЛЯ ГЕОЛОКАЦИИ
-- Эти расширения нужны для расчета расстояний между координатами
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- 1. ОБНОВЛЕНИЕ ТАБЛИЦЫ USERS (поддержка анонимных пользователей)
-- Добавляем поля для анонимных пользователей и их предпочтений
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS min_salary_preference INTEGER,
ADD COLUMN IF NOT EXISTS location_lat DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS location_lng DECIMAL(11, 8),
ADD COLUMN IF NOT EXISTS location_city VARCHAR(100);

-- Индексы для быстрого поиска пользователей
CREATE INDEX IF NOT EXISTS idx_users_is_anonymous ON users(is_anonymous);

-- Геопространственный индекс (создается только если есть координаты)
-- Используем ll_to_earth из расширения earthdistance
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM users WHERE location_lat IS NOT NULL AND location_lng IS NOT NULL) THEN
    CREATE INDEX IF NOT EXISTS idx_users_location ON users USING gist(
      ll_to_earth(location_lat::float, location_lng::float)
    );
  END IF;
END $$;

-- 2. ОБНОВЛЕНИЕ ТАБЛИЦЫ POSTS (видео-вакансии)
-- Добавляем специфичные для вакансий поля
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS job_title VARCHAR(200),              -- Название вакансии
ADD COLUMN IF NOT EXISTS company_name VARCHAR(200),           -- Название компании
ADD COLUMN IF NOT EXISTS salary_min INTEGER,                  -- Минимальная зарплата
ADD COLUMN IF NOT EXISTS salary_max INTEGER,                  -- Максимальная зарплата
ADD COLUMN IF NOT EXISTS salary_currency VARCHAR(10) DEFAULT 'RUB', -- Валюта
ADD COLUMN IF NOT EXISTS salary_period VARCHAR(20) DEFAULT 'monthly', -- month/hour/day
ADD COLUMN IF NOT EXISTS location_city VARCHAR(100),          -- Город
ADD COLUMN IF NOT EXISTS location_address TEXT,               -- Адрес
ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8),             -- Широта
ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8),            -- Долгота
ADD COLUMN IF NOT EXISTS contact_phone VARCHAR(20),           -- Телефон
ADD COLUMN IF NOT EXISTS contact_email VARCHAR(255),          -- Email работодателя
ADD COLUMN IF NOT EXISTS contact_telegram VARCHAR(100),       -- Telegram
ADD COLUMN IF NOT EXISTS contact_whatsapp VARCHAR(20),        -- WhatsApp
ADD COLUMN IF NOT EXISTS employment_type VARCHAR(50),         -- full-time/part-time/freelance
ADD COLUMN IF NOT EXISTS experience_required VARCHAR(50),     -- no-experience/1-3/3-5/5+
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,      -- Вакансия активна
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ,              -- Срок действия вакансии
ADD COLUMN IF NOT EXISTS application_count INTEGER DEFAULT 0; -- Количество откликов

-- Создаем индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_posts_salary_min ON posts(salary_min);
CREATE INDEX IF NOT EXISTS idx_posts_location_city ON posts(location_city);
CREATE INDEX IF NOT EXISTS idx_posts_is_active ON posts(is_active);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category_id);

-- Геопространственный индекс для вакансий (создается условно)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM posts WHERE latitude IS NOT NULL AND longitude IS NOT NULL) THEN
    CREATE INDEX IF NOT EXISTS idx_posts_location ON posts USING gist(
      ll_to_earth(latitude::float, longitude::float)
    );
  END IF;
END $$;

-- ============================================
-- 3. ТАБЛИЦА КАТЕГОРИЙ РАБОТЫ (обновление)
-- ============================================

-- Добавляем колонку icon_emoji если её нет
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS icon_emoji VARCHAR(10);

-- Убедимся, что категории соответствуют онбордингу
-- Используем slug как транслитерацию названия
INSERT INTO categories (name, slug, icon_emoji, description, created_at) VALUES
  ('Кафе и рестораны', 'kafe-i-restorany', '☕', 'Работа в общепите', NOW()),
  ('Склад', 'sklad', '📦', 'Складские работы', NOW()),
  ('Курьер', 'kurier', '🚴', 'Доставка', NOW()),
  ('Магазин', 'magazin', '🛒', 'Розничная торговля', NOW()),
  ('Офис', 'ofis', '🏢', 'Офисная работа', NOW()),
  ('Производство', 'proizvodstvo', '🔧', 'Производственные специальности', NOW()),
  ('Водитель', 'voditel', '🚗', 'Вождение и логистика', NOW()),
  ('Продажи', 'prodazhi', '💼', 'Активные продажи', NOW()),
  ('Строительство', 'stroitelstvo', '🏗️', 'Строительные работы', NOW()),
  ('Медицина', 'meditsina', '🏥', 'Медицинские услуги', NOW()),
  ('Дизайн', 'dizain', '🎨', 'Креативные профессии', NOW()),
  ('IT', 'it', '💻', 'Информационные технологии', NOW()),
  ('Клининг', 'klining', '🧹', 'Уборка и клининг', NOW()),
  ('Охрана', 'ohrana', '🔒', 'Охранные услуги', NOW()),
  ('Телеком', 'telekom', '📱', 'Телекоммуникации', NOW())
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- 4. ТАБЛИЦА ОТКЛИКОВ НА ВАКАНСИИ
-- ============================================
CREATE TABLE IF NOT EXISTS job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'pending', -- pending/viewed/contacted/rejected
  message TEXT, -- Сообщение от кандидата
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id) -- Один отклик от пользователя на вакансию
);

CREATE INDEX IF NOT EXISTS idx_applications_post ON job_applications(post_id);
CREATE INDEX IF NOT EXISTS idx_applications_user ON job_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON job_applications(status);

-- ============================================
-- 5. VIEW ДЛЯ ПЕРСОНАЛИЗИРОВАННОЙ ЛЕНТЫ ВАКАНСИЙ
-- ============================================
CREATE OR REPLACE VIEW personalized_feed AS
SELECT 
  p.*,
  u.username as author_username,
  u.display_name as author_display_name,
  u.avatar_url as author_avatar,
  c.name as category_name,
  c.icon_emoji as category_icon,
  -- Расчет релевантности для пользователя
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_interests ui 
      WHERE ui.user_id = auth.uid() 
      AND ui.category_id = p.category_id
    ) THEN 10 -- Пользователь выбрал эту категорию
    ELSE 0
  END as relevance_score,
  -- Расстояние от пользователя (если есть геолокация)
  -- Это можно будет использовать для сортировки
  CASE 
    WHEN p.latitude IS NOT NULL AND p.longitude IS NOT NULL
    THEN p.latitude -- Заглушка, реальный расчет расстояния добавим позже
    ELSE NULL
  END as distance_placeholder
FROM posts p
LEFT JOIN users u ON p.author_id = u.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE 
  p.is_published = true 
  AND p.is_private = false
  AND p.is_active = true
  AND (p.expires_at IS NULL OR p.expires_at > NOW());

-- ============================================
-- 6. ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ ПЕРСОНАЛИЗИРОВАННОЙ ЛЕНТЫ
-- ============================================
CREATE OR REPLACE FUNCTION get_personalized_feed(
  user_location_lat DECIMAL DEFAULT NULL,
  user_location_lng DECIMAL DEFAULT NULL,
  user_min_salary INTEGER DEFAULT NULL,
  feed_limit INTEGER DEFAULT 20,
  feed_offset INTEGER DEFAULT 0
) RETURNS TABLE (
  id UUID,
  job_title VARCHAR,
  company_name VARCHAR,
  salary_min INTEGER,
  salary_max INTEGER,
  location_city VARCHAR,
  media_url TEXT,
  thumbnail_url TEXT,
  caption TEXT,
  category_name VARCHAR,
  category_icon VARCHAR,
  author_username VARCHAR,
  author_display_name VARCHAR,
  author_avatar TEXT,
  likes_count INTEGER,
  comments_count INTEGER,
  views_count INTEGER,
  distance_km DECIMAL,
  relevance_score INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.job_title,
    p.company_name,
    p.salary_min,
    p.salary_max,
    p.location_city,
    p.media_url,
    p.thumbnail_url,
    p.caption,
    c.name as category_name,
    c.icon_emoji as category_icon,
    u.username as author_username,
    u.display_name as author_display_name,
    u.avatar_url as author_avatar,
    p.likes_count,
    p.comments_count,
    p.views_count,
    -- Расчет расстояния в км (если указана геолокация пользователя)
    CASE 
      WHEN user_location_lat IS NOT NULL 
           AND user_location_lng IS NOT NULL
           AND p.latitude IS NOT NULL 
           AND p.longitude IS NOT NULL
      THEN CAST(
        earth_distance(
          ll_to_earth(user_location_lat::float, user_location_lng::float),
          ll_to_earth(p.latitude::float, p.longitude::float)
        ) / 1000 AS DECIMAL(10,2)
      )
      ELSE NULL
    END as distance_km,
    -- Расчет релевантности
    (
      -- Баллы за соответствие интересам пользователя
      CASE WHEN EXISTS (
        SELECT 1 FROM user_interests ui 
        WHERE ui.user_id = auth.uid() 
        AND ui.category_id = p.category_id
      ) THEN 100 ELSE 0 END
      +
      -- Баллы за близость (если в пределах 10км)
      CASE 
        WHEN user_location_lat IS NOT NULL 
             AND user_location_lng IS NOT NULL
             AND p.latitude IS NOT NULL 
             AND p.longitude IS NOT NULL
             AND earth_distance(
               ll_to_earth(user_location_lat::float, user_location_lng::float),
               ll_to_earth(p.latitude::float, p.longitude::float)
             ) / 1000 < 10
        THEN 50
        ELSE 0 
      END
      +
      -- Баллы за соответствие желаемой зарплате
      CASE 
        WHEN user_min_salary IS NOT NULL 
             AND p.salary_min >= user_min_salary
        THEN 30
        ELSE 0
      END
    ) as relevance_score,
    p.created_at
  FROM posts p
  LEFT JOIN users u ON p.author_id = u.id
  LEFT JOIN categories c ON p.category_id = c.id
  WHERE 
    p.is_published = true 
    AND p.is_private = false
    AND p.is_active = true
    AND (p.expires_at IS NULL OR p.expires_at > NOW())
    AND (user_min_salary IS NULL OR p.salary_min >= user_min_salary)
  ORDER BY 
    -- Сортировка по релевантности, затем по дате
    relevance_score DESC,
    distance_km ASC NULLS LAST,
    p.created_at DESC
  LIMIT feed_limit
  OFFSET feed_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. ФУНКЦИЯ ДЛЯ ОТКЛИКА НА ВАКАНСИЮ
-- ============================================
CREATE OR REPLACE FUNCTION apply_to_job(
  job_post_id UUID,
  application_message TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Создаем отклик
  INSERT INTO job_applications (post_id, user_id, message)
  VALUES (job_post_id, current_user_id, application_message)
  ON CONFLICT (post_id, user_id) DO NOTHING;

  -- Увеличиваем счетчик откликов
  UPDATE posts 
  SET application_count = application_count + 1
  WHERE id = job_post_id;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 8. RLS POLICIES для job_applications
-- ============================================
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

-- Пользователи могут видеть свои отклики
CREATE POLICY "Users can view their own applications"
  ON job_applications FOR SELECT
  USING (auth.uid() = user_id);

-- Работодатели могут видеть отклики на свои вакансии
CREATE POLICY "Employers can view applications to their posts"
  ON job_applications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM posts 
      WHERE posts.id = job_applications.post_id 
      AND posts.author_id = auth.uid()
    )
  );

-- Пользователи могут создавать отклики
CREATE POLICY "Users can create applications"
  ON job_applications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Работодатели могут обновлять статус откликов
CREATE POLICY "Employers can update application status"
  ON job_applications FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM posts 
      WHERE posts.id = job_applications.post_id 
      AND posts.author_id = auth.uid()
    )
  );

-- ============================================
-- 9. ТРИГГЕР для обновления updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_job_application_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_application_timestamp
  BEFORE UPDATE ON job_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_job_application_timestamp();

-- ============================================
-- 10. ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ ПОИСКА
-- ============================================

-- Для полнотекстового поиска по названию вакансии и компании
CREATE INDEX IF NOT EXISTS idx_posts_job_search ON posts 
  USING gin(to_tsvector('russian', 
    COALESCE(job_title, '') || ' ' || 
    COALESCE(company_name, '') || ' ' || 
    COALESCE(caption, '')
  ));

-- Композитный индекс для фильтрации активных вакансий
CREATE INDEX IF NOT EXISTS idx_posts_active_filter ON posts(
  is_active, is_published, is_private, expires_at
) WHERE is_active = true AND is_published = true AND is_private = false;

-- ============================================
-- ГОТОВО! Теперь база готова для загрузки видео-вакансий
-- ============================================

-- ПРИМЕР ЗАГРУЗКИ ТЕСТОВОЙ ВАКАНСИИ:
/*
INSERT INTO posts (
  author_id,
  media_url,
  media_type,
  caption,
  category_id,
  job_title,
  company_name,
  salary_min,
  salary_max,
  location_city,
  location_address,
  latitude,
  longitude,
  contact_phone,
  employment_type,
  experience_required,
  is_published,
  is_active
) VALUES (
  'YOUR_USER_ID',
  'https://your-supabase-project.supabase.co/storage/v1/object/public/videos/job1.mp4',
  'video',
  'Требуется бариста в уютное кафе! Дружный коллектив, гибкий график.',
  (SELECT id FROM categories WHERE name = 'Кафе и рестораны' LIMIT 1),
  'Бариста',
  'Кофейня "У друзей"',
  45000,
  60000,
  'Москва',
  'ул. Тверская, 10',
  55.7558,
  37.6173,
  '+7 (999) 123-45-67',
  'full-time',
  'no-experience',
  true,
  true
);
*/

