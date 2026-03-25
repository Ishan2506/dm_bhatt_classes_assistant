import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    loadTheme();
  }

  static const String _themeModeKey = 'theme_mode';
  static const String _styleKey = 'selected_style';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    final modeIndex = prefs.getInt(_themeModeKey);
    final styleIndex = prefs.getInt(_styleKey);

    emit(state.copyWith(
      themeMode: modeIndex != null ? ThemeMode.values[modeIndex] : state.themeMode,
      selectedStyle: styleIndex != null ? AppThemeStyle.values[styleIndex] : state.selectedStyle,
    ));
  }

  Future<void> changeTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> changeStyle(AppThemeStyle style) async {
    emit(state.copyWith(selectedStyle: style));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_styleKey, style.index);
  }
}
