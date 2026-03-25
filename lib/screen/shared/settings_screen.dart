import 'package:dm_bhatt_classes_new/screen/admin/update_password_screen.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Settings",
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsItem(
              context,
              title: "Update Password",
              value: "",
              icon: Icons.lock_reset,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
