import 'package:flutter/material.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  
  factory ThemeManager() {
    return _instance;
  }

  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  void toggleTheme(ThemeMode mode) {
    themeMode.value = mode;
  }
}
