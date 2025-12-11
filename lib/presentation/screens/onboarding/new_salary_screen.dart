import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'new_geolocation_screen.dart';

class NewSalaryScreen extends StatefulWidget {
  final List<String> selectedInterests;

  const NewSalaryScreen({
    super.key,
    required this.selectedInterests,
  });

  @override
  State<NewSalaryScreen> createState() => _NewSalaryScreenState();
}

class _NewSalaryScreenState extends State<NewSalaryScreen> {
  final TextEditingController _salaryController = TextEditingController();
  int _selectedSalary = 60000; // Значение по умолчанию

  @override
  void initState() {
    super.initState();
    _salaryController.text = '10.000';
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _selectQuickAmount() {
    setState(() {
      _selectedSalary = 60000;
    });
    _continue();
  }

  void _skip() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewGeolocationScreen(
          selectedInterests: widget.selectedInterests,
          minSalary: null,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _continue() {
    // Парсим введенную зарплату
    final text = _salaryController.text.replaceAll(RegExp(r'[^\d]'), '');
    final salary = int.tryParse(text) ?? _selectedSalary;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewGeolocationScreen(
          selectedInterests: widget.selectedInterests,
          minSalary: salary,
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
                'Выбери желаемую сумму\nзарплаты в месяц',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Поле ввода
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.greyDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'От 10.000 ₽',
                    hintStyle: TextStyle(
                      color: AppColors.greyDark.withValues(alpha: 0.5),
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Кнопка "Пропустить"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Пропустить',
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

            // Кнопка быстрого выбора
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectQuickAmount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonYellow,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Выбрать 60 тысяч',
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

// Форматтер для разделения тысяч
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();
    
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(str[i]);
    }
    
    return result.toString();
  }
}

