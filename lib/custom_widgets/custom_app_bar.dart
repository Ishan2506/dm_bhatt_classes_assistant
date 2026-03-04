import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.blue.shade900,
      elevation: 0,
      leading: leading ?? IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        color: foregroundColor ?? Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      actions: actions,
      iconTheme: IconThemeData(color: foregroundColor ?? Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
