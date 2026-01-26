import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatePasswordScreen extends StatelessWidget {
  const UpdatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Update Password",
          style: GoogleFonts.poppins(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "Update Password Screen Placeholder",
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}
