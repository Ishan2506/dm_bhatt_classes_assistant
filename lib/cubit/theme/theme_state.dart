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
  final AppThemeStyle selectedStyle;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.selectedStyle = AppThemeStyle.classic,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppThemeStyle? selectedStyle,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      selectedStyle: selectedStyle ?? this.selectedStyle,
    );
  }

  @override
  List<Object?> get props => [themeMode, selectedStyle];
}
