import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import 'geolocation_screen.dart';

class SalarySelectionScreen extends StatefulWidget {
  const SalarySelectionScreen({super.key});

  @override
  State<SalarySelectionScreen> createState() => _SalarySelectionScreenState();
}

class _SalarySelectionScreenState extends State<SalarySelectionScreen> {
  double _salary = 45000;
  final double _minSalary = 20000;
  final double _maxSalary = 200000;

  String _formatSalary(double salary) {
    return '${salary.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} ₽';
  }

  Future<void> _continue() async {
    // Сохраняем выбранную зарплату в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_min_salary', _salary.toInt());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeolocationScreen(),
      ),
    );
  }

  void _skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeolocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Heading
              const Text(
                'Сколько ты хочешь зарабатывать',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Выбери сумму, с которой тебе будет комфортно рассматривать предложения',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Salary display
              Center(
                child: Column(
                  children: [
                    Text(
                      'от ${_formatSalary(_salary)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'в месяц',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withAlpha(51),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withAlpha(51),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: _salary,
                  min: _minSalary,
                  max: _maxSalary,
                  divisions: 36,
                  onChanged: (value) {
                    setState(() {
                      _salary = (value / 5000).round() * 5000;
                    });
                  },
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Пропустить пока',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

