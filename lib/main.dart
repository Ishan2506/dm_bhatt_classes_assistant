import 'package:dm_bhatt_classes_new/constant/app_constant.dart';
import 'package:dm_bhatt_classes_new/cubit/theme/theme_cubit.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/splash_screen.dart';
import 'package:dm_bhatt_classes_new/utils/app_theme_data.dart';
import 'package:dm_bhatt_classes_new/utils/app_theme_extensions.dart'; // Import extension
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dm_bhatt_classes_new/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create text theme
    final textTheme = createTextTheme();
    final theme = MaterialTheme(textTheme);

    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final styleName = state.selectedStyle.name;

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: theme.getThemeForStyle(styleName, false), // Light
            darkTheme: theme.getThemeForStyle(styleName, true), // Dark
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('gu'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
