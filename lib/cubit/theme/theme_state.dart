part of 'theme_cubit.dart';

enum AppThemeStyle {
  classic,
  ocean,
  sunset,
  forest,
  lavender,
  midnight
}

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final AppThemeStyle selectedStyle;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.selectedStyle = AppThemeStyle.classic,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppThemeStyle? selectedStyle,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      selectedStyle: selectedStyle ?? this.selectedStyle,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, selectedStyle];
}
