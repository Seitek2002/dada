import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class NewFinalScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final int? minSalary;
  final bool locationGranted;

  const NewFinalScreen({
    super.key,
    required this.selectedInterests,
    this.minSalary,
    required this.locationGranted,
  });

  @override
  State<NewFinalScreen> createState() => _NewFinalScreenState();
}

class _NewFinalScreenState extends State<NewFinalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  final List<CategoryCard> _cards = [
    CategoryCard(
      emoji: '☕',
      title: 'Кафе и\nрестораны',
      gradient: const LinearGradient(
        colors: [Color(0xFFFFB84D), Color(0xFFFF9843)],
      ),
    ),
    CategoryCard(
      emoji: '📦',
      title: 'Склад и\nлогистика',
      gradient: const LinearGradient(
        colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
      ),
    ),
    CategoryCard(
      emoji: '🚴',
      title: 'Курьер',
      gradient: const LinearGradient(
        colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
      ),
    ),
    CategoryCard(
      emoji: '💼',
      title: 'Офис',
      gradient: const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Сетка карточек
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_cards[index], index);
                    },
                  ),
                ),
              ),

              // Текст и кнопка
              Expanded(
                flex: 4,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Заголовок
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Теперь поиск работы одно\nудовольствие!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Кнопка
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonYellow,
                              foregroundColor: AppColors.black,
                              disabledBackgroundColor:
                                  AppColors.greyDark.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.black,
                                    ),
                                  )
                                : const Text(
                                    'Далее',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(CategoryCard card, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: card.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(
              card.emoji,
              style: const TextStyle(fontSize: 64),
            ),

            const SizedBox(height: 16),

            // Текст
            Text(
              card.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final prefs = await SharedPreferences.getInstance();

      // Создаем анонимного пользователя
      final success = await authProvider.signInAnonymously();

      if (!success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка создания аккаунта. Попробуй еще раз.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Сохраняем выбранные интересы
      await authProvider.saveInterests(widget.selectedInterests);

      // Сохраняем минимальную зарплату
      if (widget.minSalary != null) {
        await authProvider.saveMinSalary(widget.minSalary!);
      }

      // Сохраняем информацию о геолокации
      if (widget.locationGranted) {
        // TODO: В будущем здесь будет сохранение реальных координат
      }

      // Сохраняем что онбординг пройден
      await prefs.setBool('has_seen_onboarding', true);

      if (!mounted) return;

      // Переходим на главный экран
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error during onboarding: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class CategoryCard {
  final String emoji;
  final String title;
  final Gradient gradient;

  CategoryCard({
    required this.emoji,
    required this.title,
    required this.gradient,
  });
}

