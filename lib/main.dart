import 'package:dm_bhatt_classes_new/constant/app_constant.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/splash_screen.dart';
import 'package:dm_bhatt_classes_new/utils/app_theme_data.dart';
import 'package:dm_bhatt_classes_new/utils/app_theme_extensions.dart'; // Import extension
import 'package:flutter/material.dart';

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

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: theme.getThemeForStyle("classic", false), // Light classic
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
