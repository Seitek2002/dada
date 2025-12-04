-- ⚡ Дополнительные функции для Supabase

-- ============================================
-- ФУНКЦИИ ДЛЯ СЧЕТЧИКОВ
-- ============================================

-- Увеличить просмотры
CREATE OR REPLACE FUNCTION increment_view_count(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET views_count = views_count + 1 
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Увеличить шеринги
CREATE OR REPLACE FUNCTION increment_share_count(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET shares_count = shares_count + 1 
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Увеличить сохранения
CREATE OR REPLACE FUNCTION increment_save_count(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET saves_count = saves_count + 1 
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Уменьшить сохранения
CREATE OR REPLACE FUNCTION decrement_save_count(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET saves_count = GREATEST(0, saves_count - 1)
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ФУНКЦИЯ ДЛЯ РЕКОМЕНДАЦИЙ
-- ============================================

-- Получить рекомендованные посты для пользователя
CREATE OR REPLACE FUNCTION get_recommended_posts(
  user_id UUID,
  limit_count INT DEFAULT 20
)
RETURNS TABLE (
  post_id UUID,
  score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as post_id,
    (
      -- Факторы ранжирования
      (p.likes_count::float / NULLIF(p.views_count, 0)::float) * 100 + -- engagement
      (p.comments_count::float * 2) + -- комментарии важнее
      (CASE WHEN ui.user_id IS NOT NULL THEN 50 ELSE 0 END) + -- интересы пользователя
      (EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 * -0.1) -- свежесть
    ) as score
  FROM posts p
  LEFT JOIN user_interests ui ON p.category_id = ui.category_id AND ui.user_id = user_id
  WHERE p.is_published = true
    AND p.is_private = false
    AND p.author_id != user_id -- не показываем свои посты
  ORDER BY score DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ФУНКЦИЯ ДЛЯ ТРЕНДОВЫХ ТЕГОВ
-- ============================================

CREATE OR REPLACE FUNCTION update_trending_tags()
RETURNS void AS $$
BEGIN
  -- Обновить trending_score на основе активности за последние 24 часа
  UPDATE tags t
  SET 
    is_trending = (
      SELECT COUNT(*)
      FROM post_tags pt
      JOIN posts p ON pt.post_id = p.id
      WHERE pt.tag_id = t.id
        AND p.created_at > NOW() - INTERVAL '24 hours'
    ) > 10,
    trending_score = (
      SELECT COALESCE(SUM(p.views_count), 0)
      FROM post_tags pt
      JOIN posts p ON pt.post_id = p.id
      WHERE pt.tag_id = t.id
        AND p.created_at > NOW() - INTERVAL '24 hours'
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ ЛЕНТЫ "FOLLOWING"
-- ============================================

CREATE OR REPLACE FUNCTION get_following_feed(
  user_id UUID,
  limit_count INT DEFAULT 20,
  offset_count INT DEFAULT 0
)
RETURNS SETOF posts AS $$
BEGIN
  RETURN QUERY
  SELECT p.*
  FROM posts p
  JOIN follows f ON p.author_id = f.following_id
  WHERE f.follower_id = user_id
    AND p.is_published = true
  ORDER BY p.created_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- АВТОМАТИЧЕСКОЕ СОЗДАНИЕ УВЕДОМЛЕНИЙ
-- ============================================

-- При новом лайке
CREATE OR REPLACE FUNCTION create_like_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications (user_id, actor_id, post_id, type, message)
  SELECT 
    p.author_id,
    NEW.user_id,
    NEW.post_id,
    'like',
    u.display_name || ' liked your post'
  FROM posts p
  JOIN users u ON u.id = NEW.user_id
  WHERE p.id = NEW.post_id
    AND p.author_id != NEW.user_id; -- не уведомлять себя
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_like_notification AFTER INSERT ON likes
  FOR EACH ROW EXECUTE FUNCTION create_like_notification();

-- При новом комментарии
CREATE OR REPLACE FUNCTION create_comment_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications (user_id, actor_id, post_id, comment_id, type, message)
  SELECT 
    p.author_id,
    NEW.author_id,
    NEW.post_id,
    NEW.id,
    'comment',
    u.display_name || ' commented on your post'
  FROM posts p
  JOIN users u ON u.id = NEW.author_id
  WHERE p.id = NEW.post_id
    AND p.author_id != NEW.author_id; -- не уведомлять себя
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_notification AFTER INSERT ON comments
  FOR EACH ROW EXECUTE FUNCTION create_comment_notification();

-- При новой подписке
CREATE OR REPLACE FUNCTION create_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications (user_id, actor_id, type, message)
  SELECT 
    NEW.following_id,
    NEW.follower_id,
    'follow',
    u.display_name || ' started following you'
  FROM users u
  WHERE u.id = NEW.follower_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_follow_notification AFTER INSERT ON follows
  FOR EACH ROW EXECUTE FUNCTION create_follow_notification();

-- ============================================
-- ФУНКЦИИ ДЛЯ СТАТИСТИКИ
-- ============================================

-- Получить топ посты за период
CREATE OR REPLACE FUNCTION get_top_posts(
  time_period INTERVAL DEFAULT INTERVAL '7 days',
  limit_count INT DEFAULT 20
)
RETURNS TABLE (
  post_id UUID,
  likes_count INT,
  views_count BIGINT,
  engagement_rate FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as post_id,
    p.likes_count,
    p.views_count,
    (p.likes_count::float + p.comments_count::float + p.shares_count::float) / NULLIF(p.views_count, 0)::float as engagement_rate
  FROM posts p
  WHERE p.created_at > NOW() - time_period
    AND p.is_published = true
  ORDER BY engagement_rate DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Получить статистику пользователя
CREATE OR REPLACE FUNCTION get_user_stats(user_id UUID)
RETURNS TABLE (
  total_posts INT,
  total_likes BIGINT,
  total_views BIGINT,
  total_comments INT,
  avg_engagement_rate FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INT as total_posts,
    COALESCE(SUM(p.likes_count), 0)::BIGINT as total_likes,
    COALESCE(SUM(p.views_count), 0)::BIGINT as total_views,
    COALESCE(SUM(p.comments_count), 0)::INT as total_comments,
    COALESCE(AVG((p.likes_count::float + p.comments_count::float) / NULLIF(p.views_count, 0)::float), 0) as avg_engagement_rate
  FROM posts p
  WHERE p.author_id = user_id;
END;
$$ LANGUAGE plpgsql;

