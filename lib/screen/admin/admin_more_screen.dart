import 'package:dm_bhatt_classes_new/screen/admin/admin_ai_assistant.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_log_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dm_bhatt_classes_new/screen/admin/import_students_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/import_students_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/manage_events_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/help_support_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/my_profile_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/settings_screen.dart';
import 'package:dm_bhatt_classes_new/screen/authentication/welcome_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_video_maker_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMoreScreen extends StatefulWidget {
  const AdminMoreScreen({super.key});

  @override
  State<AdminMoreScreen> createState() => _AdminMoreScreenState();
}

class _AdminMoreScreenState extends State<AdminMoreScreen> {

  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('user_role');
    });
    debugPrint("Role: ${_role}");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "More Options",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOptionTile(context, Icons.person_outline, "My Profile", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfileScreen()));
          }),
          if (_role == "Admin")
            _buildOptionTile(
              context,
              Icons.smart_toy_outlined,
              "AI Assistant",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminAIAssistantScreen(),
                  ),
                );
              },
            ),
          _buildOptionTile(context, Icons.settings_outlined, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          _buildOptionTile(context, Icons.help_outline, "Help & Support", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          }),
          // _buildOptionTile(context, Icons.history, "Activity Log", () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogScreen()));
          // }),
          _buildOptionTile(context, Icons.file_upload_outlined, "Import Students", () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminImportStudentsScreen()));
          }),
          _buildOptionTile(context, Icons.event, "Manage Events", () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageEventsScreen()));
          }),
          _buildOptionTile(context, Icons.video_collection_outlined, "Video Maker (PDF)", () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminVideoMakerScreen()));
          }),
          _buildOptionTile(context, Icons.hub_outlined, "Add Mind Map", () {
             // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMindMapScreen()));
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mind Map creation feature coming soon!")));
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from the application?",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, 
            fontSize: 14
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
               // Clear Session
               final prefs = await SharedPreferences.getInstance();
               await prefs.clear();

               if (!context.mounted) return;

               // Pop dialog first
               Navigator.pop(context);
               // Navigate to Welcome Screen and clear stack
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
                 (route) => false
               );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
             color: isDestructive ? Colors.red.shade50 : (isDark ? theme.primaryColor.withOpacity(0.3) : Colors.blue.shade50),
             borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.red : (isDark ? Colors.blue.shade200 : Colors.blue.shade700),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.red : theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
      ),
    );
  }
}
