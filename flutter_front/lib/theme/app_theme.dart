import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color primaryBlue = Color(0xFF007BFF);
  static const Color textLight = Color(0xFFAAAAAA);
  static const Color textDark = Color(0xFF333333);

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF0056b3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
