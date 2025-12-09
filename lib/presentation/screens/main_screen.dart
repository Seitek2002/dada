import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import 'home/home_screen.dart';
import 'discover/discover_screen.dart';
import 'create/create_screen.dart';
import 'inbox/inbox_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    HomeScreen(isActive: _currentIndex == 0),
    const DiscoverScreen(),
    const CreateScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Эта функция будет вызываться при изменении состояния приложения
    // (например, при сворачивании или переключении вкладок)
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceLight,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.textPrimary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon('assets/icons/home.svg', 0),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/icons/discover.svg', 1),
              label: 'Поиск',
            ),
            BottomNavigationBarItem(
              icon: _buildAddIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/icons/inbox.svg', 3),
              label: 'Сообщения',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/icons/profile.svg', 4),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, int index) {
    final isSelected = _currentIndex == index;
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildAddIcon() {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF25F4EE),
            Color(0xFFFE2C55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

