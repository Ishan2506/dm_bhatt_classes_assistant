import 'package:dm_bhatt_classes_new/screen/admin/add_student_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/add_assistant_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/add_paperset_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/create_online_exam_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_five_min_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class AdminAddScreen extends StatelessWidget {
  const AdminAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Quick Add",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAddCard(
              context,
              "Add Student",
              Icons.person_add_outlined,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStudentScreen(),
                  ),
                );
              },
            ),
            _buildAddCard(
              context,
              "Add Assistant",
              Icons.group_add_outlined,
              Colors.purple,
              () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAssistantScreen()),
                );
              },
            ),
            _buildAddCard(
              context,
              "Add Paper Set",
              Icons.assignment_add,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPapersetScreen()),
                );
              },
            ),
             _buildAddCard(
              context,
              "Create Online Exam", // Renamed for clarity as per user context
              Icons.edit_document,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateOnlineExamScreen()),
                );
              },
            ),
             _buildAddCard(
              context,
              "Add 5 Min Test",
              Icons.timer_outlined,
              Colors.indigo,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminFiveMinTestScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
