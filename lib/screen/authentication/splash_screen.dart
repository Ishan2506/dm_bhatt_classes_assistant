import 'dart:async';
import 'package:dm_bhatt_classes_new/constant/app_images.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/welcome_screen.dart';
import 'package:dm_bhatt_classes_new/utils/app_sizes.dart';
import 'package:flutter/material.dart';

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

    // Currently defaulting to WelcomeScreen as auth persistence is not yet implemented in this simplified flow
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
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
