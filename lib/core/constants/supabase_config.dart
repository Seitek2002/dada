/// Конфигурация Supabase
/// 
/// ⚠️ ВАЖНО: Эти ключи должны быть в .env файле в production!
/// Сейчас для разработки они здесь.
class SupabaseConfig {
  // Project URL
  static const String supabaseUrl = 'https://bdoprpriusqgnybdvppc.supabase.co';
  
  // Anon/Public Key (безопасно использовать в клиенте)
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkb3BycHJpdXNxZ255YmR2cHBjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTIyMDUsImV4cCI6MjA4MDQyODIwNX0.zaxptIOD5ddP8J5zWPFjLEHp93zanCeBndotRa-pw8o';
  
  // ⚠️ Service Role Key - НЕ ИСПОЛЬЗУЙТЕ в клиенте! Только для backend/admin операций
  // static const String supabaseServiceKey = 
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkb3BycHJpdXNxZ255YmR2cHBjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDg1MjIwNSwiZXhwIjoyMDgwNDI4MjA1fQ.LwuvBGI1jmmQYFcUCJS4GwedlN8hbaQpCmUq9Du8jFM';
  
  // Storage buckets
  static const String avatarsBucket = 'avatars';
  static const String coversBucket = 'covers';
  static const String postsVideosBucket = 'posts-videos';
  static const String postsImagesBucket = 'posts-images';
  static const String postsThumbnailsBucket = 'posts-thumbnails';
  static const String musicBucket = 'music';
  static const String chatMediaBucket = 'chat-media';
}

