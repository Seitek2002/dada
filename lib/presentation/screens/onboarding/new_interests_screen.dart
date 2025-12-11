import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'new_salary_screen.dart';

class NewInterestsScreen extends StatefulWidget {
  const NewInterestsScreen({super.key});

  @override
  State<NewInterestsScreen> createState() => _NewInterestsScreenState();
}

class _NewInterestsScreenState extends State<NewInterestsScreen> {
  final Set<String> _selectedInterests = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<CategoryItem> _categories = [
    CategoryItem(name: 'Бариста'),
    CategoryItem(name: 'Повар'),
    CategoryItem(name: 'Пекарь'),
    CategoryItem(name: 'Водитель'),
    CategoryItem(name: 'Курьер'),
    CategoryItem(name: 'Менеджер WB'),
    CategoryItem(name: 'Кафе и рестораны'),
    CategoryItem(name: 'Склад'),
    CategoryItem(name: 'Магазин'),
    CategoryItem(name: 'Офис'),
    CategoryItem(name: 'Производство'),
    CategoryItem(name: 'Продажи'),
  ];

  List<CategoryItem> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }
    return _categories
        .where((cat) =>
            cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                'В какой сфере\nищешь работу?',
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
                'Можно выбрать сразу несколько сфер',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.greyDark,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Поиск
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.greyDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Найти категорию',
                    hintStyle: TextStyle(
                      color: AppColors.greyDark.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.greyDark.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Список категорий
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  final isSelected = _selectedInterests.contains(category.name);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(category.name);
                          } else {
                            _selectedInterests.add(category.name);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyDark.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.buttonYellow
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.buttonYellow
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.buttonYellow
                                      : AppColors.greyDark,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.black,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Кнопка продолжить
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.isEmpty ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonYellow,
                    foregroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.greyDark.withValues(alpha: 0.3),
                    disabledForegroundColor: AppColors.greyDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  void _continue() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewSalaryScreen(selectedInterests: _selectedInterests.toList()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class CategoryItem {
  final String name;

  CategoryItem({required this.name});
}

