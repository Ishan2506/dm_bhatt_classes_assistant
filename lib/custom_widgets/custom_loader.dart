import 'package:dm_bhatt_classes_new/constant/app_images.dart';
import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final double? size;
  const CustomLoader({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    final double finalSize = size ?? 100.0;
    final double iconSize = (finalSize / 100.0) * 50.0;
    final double padding = (finalSize / 100.0) * 16.0;

    return Container(
      width: size == null ? MediaQuery.of(context).size.width : null,
      height: size == null ? MediaQuery.of(context).size.height : null,
      color: size == null ? Colors.black.withOpacity(0.05) : Colors.transparent, // Subtle dimming for full-screen
      child: Center(
        child: Container(
          width: finalSize,
          height: finalSize,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15 * (finalSize / 100.0),
                spreadRadius: 2 * (finalSize / 100.0),
                offset: Offset(0, 4 * (finalSize / 100.0)),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo
              Image.asset(
                imgLoaderBot, // Using App Logo
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              // Loader Ring
              SizedBox(
                width: finalSize,
                height: finalSize,
                child: CircularProgressIndicator(
                  strokeWidth: 4 * (finalSize / 100.0),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), // App Theme Color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static method to show loader dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3), // Dimmed background
      builder: (context) {
        return const CustomLoader();
      },
    );
  }

  // Static method to hide loader dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
