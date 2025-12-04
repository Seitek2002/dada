import 'package:flutter/material.dart';
import 'interests_screen.dart';

// Убираем промежуточные страницы onboarding, сразу переходим к интересам
// как в реальном TikTok
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Сразу показываем экран выбора интересов
    return const InterestsScreen();
  }
}

