import 'dart:async';
import 'package:dm_bhatt_classes_new/constant/app_images.dart';

import 'package:dm_bhatt_classes_new/screen/admin/admin_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/login_screen.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/force_update_screen.dart';
import 'package:dm_bhatt_classes_new/utils/app_sizes.dart';
import 'package:dm_bhatt_classes_new/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dm_bhatt_classes_new/network/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Start from bottom
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    
    // Start Navigation Timer
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for animation + extra time (total ~4 seconds)
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;

    try {
      // 1. Fetch App Config
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/config/app')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        
        // 2. Get current app version (Build Number)
        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
        
        int minBuildNumber = 0;
        String storeUrl = '';
        String message = config['forceUpdateMessage'] ?? 'A new version of the app is available. Please update to continue using the app.';

        if (!kIsWeb) {
          if (Platform.isAndroid) {
              minBuildNumber = int.tryParse(config['adminMinAndroidVersion']?.toString() ?? '0') ?? 0;
              storeUrl = config['adminPlayStoreUrl'] ?? '';
          } else if (Platform.isIOS) {
              minBuildNumber = int.tryParse(config['adminMinIosVersion']?.toString() ?? '0') ?? 0;
              storeUrl = config['adminAppStoreUrl'] ?? '';
          }
        }

        if (!kIsWeb && currentBuildNumber > 0 && minBuildNumber > 0 && currentBuildNumber < minBuildNumber) {
            // Force update
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ForceUpdateScreen(
                message: message,
                storeUrl: storeUrl,
              )),
            );
            return;
        }
      }
    } catch (e) {
      debugPrint('App Version Check Failed: $e');
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    if (token != null && token.isNotEmpty && role != null) {
      Widget targetScreen;
      if (role == "Admin") {
        targetScreen = const AdminHomeScreen();
      } else {
        // App does not support other roles except Admin now
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen(role: 'Admin')),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen(role: 'Admin')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Dynamic background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Image.asset(
                      imgSplashLogo,
                      width: 250, // Matching the size S.s250 from Student App approx
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
