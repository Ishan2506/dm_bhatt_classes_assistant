part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const ThemeState({
    this.themeMode = ThemeMode.system, 
    this.locale = const Locale('en'),
  });

  ThemeState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object> get props => [themeMode, locale];
}
