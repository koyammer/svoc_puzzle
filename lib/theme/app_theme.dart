import 'package:flutter/material.dart';

class AppTheme {
  static const Map<String, Color> _roleColors = {
    'S': Color(0xFF4361EE),
    'V': Color(0xFFE63946),
    'O': Color(0xFF10B981),
    'C': Color(0xFFFF9F1C),
    'M': Color(0xFF9B5DE5),
  };

  static const Map<String, Color> _roleLightColors = {
    'S': Color(0xFFEEF2FF),
    'V': Color(0xFFFFF0F0),
    'O': Color(0xFFECFDF5),
    'C': Color(0xFFFFF8EE),
    'M': Color(0xFFF5EEFF),
  };

  static const Color background = Color(0xFFF4F6FF);

  static const LinearGradient decomposeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient patternGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF5576C), Color(0xFFF093FB)],
  );

  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4158D0), Color(0xFF764BA2), Color(0xFFC850C0)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient comboGradient = LinearGradient(
    colors: [Color(0xFFFF9F1C), Color(0xFFFF4081)],
  );

  static Color roleColor(String role) =>
      _roleColors[role] ?? const Color(0xFF546E7A);

  static Color roleLightColor(String role) =>
      _roleLightColors[role] ?? const Color(0xFFF0F4FF);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: background,
      );
}
