import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Используем Montserrat как аналог Gilroy (похожий геометрический sans-serif)
  // Если у вас есть файлы Gilroy, замените на: fontFamily: 'Gilroy'
  
  static TextTheme getTextTheme() {
    return GoogleFonts.montserratTextTheme();
  }

  static String get fontFamily => GoogleFonts.montserrat().fontFamily!;
  
  // Готовые стили для разных размеров
  static TextStyle heading1 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static TextStyle heading2 = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static TextStyle heading3 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}

