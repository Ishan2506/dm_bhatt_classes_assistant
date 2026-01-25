import 'package:dm_bhatt_classes_new/constant/app_constant.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/splash_screen.dart';
import 'package:dm_bhatt_classes_new/utils/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system, // Default to system, or light
      home: const SplashScreen(),
    );
  }
}
