import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'new_final_screen.dart';

class NewGeolocationScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final int? minSalary;

  const NewGeolocationScreen({
    super.key,
    required this.selectedInterests,
    this.minSalary,
  });

  @override
  State<NewGeolocationScreen> createState() => _NewGeolocationScreenState();
}

class _NewGeolocationScreenState extends State<NewGeolocationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _allowLocation() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewFinalScreen(
          selectedInterests: widget.selectedInterests,
          minSalary: widget.minSalary,
          locationGranted: true,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _skip() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewFinalScreen(
          selectedInterests: widget.selectedInterests,
          minSalary: widget.minSalary,
          locationGranted: false,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кнопка назад
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 16),

            // Заголовок
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Найдем работу рядом\nс твоим домом',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Подзаголовок
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Геолокация нужна, чтобы сначала показывать\nработу в твоем районе. Мы не передаем\nданные третьим лицам',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyDark,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3D иконка геолокации с анимацией
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.buttonYellow
                                  .withValues(alpha: 0.3 * _glowAnimation.value),
                              AppColors.buttonYellow
                                  .withValues(alpha: 0.1 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Внешнее свечение
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF6B4EFF),
                                    const Color(0xFF8B7FFF)
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6B4EFF)
                                        .withValues(alpha: 0.4 * _glowAnimation.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            // Иконка пина
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.buttonYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 50,
                                color: AppColors.black,
                              ),
                            ),
                            // Блик
                            Positioned(
                              top: 40,
                              left: 40,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white
                                          .withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Кнопка "Не сейчас"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Не сейчас',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonYellow,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка "Разрешить"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _allowLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonYellow,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Разрешить',
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
    );
  }
}

