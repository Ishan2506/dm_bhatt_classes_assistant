import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeKey);
    if (modeIndex != null) {
      emit(state.copyWith(themeMode: ThemeMode.values[modeIndex]));
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
