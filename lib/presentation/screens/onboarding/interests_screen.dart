import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};
  String? _errorMessage;

  final List<Interest> _interests = [
    Interest(emoji: '☕', name: 'Кафе и рестораны', color: Color(0xFFFFB84D)),
    Interest(emoji: '📦', name: 'Склад', color: Color(0xFF9E9E9E)),
    Interest(emoji: '🚴', name: 'Курьер', color: Color(0xFF4DB6AC)),
    Interest(emoji: '🛒', name: 'Магазин', color: Color(0xFF8BC34A)),
    Interest(emoji: '🏢', name: 'Офис', color: Color(0xFF2196F3)),
    Interest(emoji: '🔧', name: 'Производство', color: Color(0xFF795548)),
    Interest(emoji: '🚗', name: 'Водитель', color: Color(0xFFFF6B6B)),
    Interest(emoji: '💼', name: 'Продажи', color: Color(0xFF9C27B0)),
    Interest(emoji: '🏗️', name: 'Строительство', color: Color(0xFFFF9800)),
    Interest(emoji: '🏥', name: 'Медицина', color: Color(0xFFE91E63)),
    Interest(emoji: '🎨', name: 'Дизайн', color: Color(0xFF9B88FA)),
    Interest(emoji: '💻', name: 'IT', color: Color(0xFF00BCD4)),
    Interest(emoji: '🧹', name: 'Клининг', color: Color(0xFF6BCF7F)),
    Interest(emoji: '🔒', name: 'Охрана', color: Color(0xFF607D8B)),
    Interest(emoji: '📱', name: 'Телеком', color: Color(0xFFFFCA28)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'В какой сфере хочешь работать',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Можно выбрать несколько вариантов, чтобы рекомендации были точнее',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Examples text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Например: кафе, склад, курьер, магазин',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Interests grid - в стиле TikTok
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest.name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest.name);
                        } else {
                          _selectedInterests.add(interest.name);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            interest.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              interest.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_selectedInterests.isEmpty) {
      setState(() {
        _errorMessage = 'Выбери хотя бы одну сферу, чтобы мы подобрали вакансии под тебя';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Показываем загрузку
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();
      final prefs = await SharedPreferences.getInstance();

      // Создаем анонимного пользователя
      final success = await authProvider.signInAnonymously();

      if (!success) {
        if (!mounted) return;
        Navigator.pop(context);
        setState(() {
          _errorMessage = 'Ошибка создания аккаунта. Попробуй еще раз.';
        });
        return;
      }

      // Сохраняем выбранные интересы
      await authProvider.saveInterests(_selectedInterests.toList());

      // Сохраняем минимальную зарплату (если была выбрана)
      final minSalary = prefs.getInt('onboarding_min_salary');
      if (minSalary != null) {
        await authProvider.saveMinSalary(minSalary);
      }

      // Сохраняем геолокацию (если была разрешена)
      final locationGranted = prefs.getBool('onboarding_location_granted') ?? false;
      if (locationGranted) {
        // TODO: В будущем здесь будет сохранение реальных координат
        // final lat = prefs.getDouble('user_lat');
        // final lng = prefs.getDouble('user_lng');
        // if (lat != null && lng != null) {
        //   await authProvider.saveLocation(latitude: lat, longitude: lng);
        // }
      }

      // Сохраняем что онбординг пройден
      await prefs.setBool('has_seen_onboarding', true);

      if (!mounted) return;
      Navigator.pop(context);

      // Переходим на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      debugPrint('Error during onboarding: $e');
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    }
  }
}

class Interest {
  final String emoji;
  final String name;
  final Color color;

  Interest({
    required this.emoji,
    required this.name,
    required this.color,
  });
}

