import 'package:dm_bhatt_classes_new/screen/assistant/help_support_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/my_profile_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/settings_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/update_marks_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistantMoreScreen extends StatelessWidget {
  const AssistantMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "More Options",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOptionTile(context, Icons.person_outline, "My Profile", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfileScreen()));
          }),
          _buildOptionTile(context, Icons.settings_outlined, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          _buildOptionTile(context, Icons.help_outline, "Help & Support", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          }),
          _buildOptionTile(context, Icons.edit_note_outlined, "Update Marks", () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateMarksSelectionScreen()));
          }),
          const SizedBox(height: 24),
          _buildOptionTile(context, Icons.logout, "Logout", () {
             _showLogoutDialog(context);
          }, isDestructive: true),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: Colors.blue.shade900, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from the application?",
          style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
               // Pop dialog first
               Navigator.pop(context);
               // Pop until the first route (Welcome Screen usually)
               Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
             color: isDestructive ? Colors.red.shade50 : Colors.blue.shade50,
             borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.red : Colors.blue.shade700,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      ),
    );
  }
}
