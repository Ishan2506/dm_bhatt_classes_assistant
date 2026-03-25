import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/combined_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/student_performance_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/regular_exam_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/five_min_quiz_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/one_liner_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/refer_and_earn_report_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/reports/upgrade_plan_report_screen.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(
        title: "Reports & Analytics",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a Report", 
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text("Access detailed analytics for each category", 
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 25),
            
            _buildReportCard(
              context,
              title: "Combined Exam Report",
              subtitle: "All exam types aggregated results",
              icon: Icons.all_inbox_rounded,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CombinedReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "Student Wise Performance",
              subtitle: "Individual student average and history",
              icon: Icons.person_search_rounded,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentPerformanceReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "Regular Exam Report",
              subtitle: "Curriculum based exam submissions",
              icon: Icons.assignment_rounded,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegularExamReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "5-Min Quiz Report",
              subtitle: "Speed quiz results and analytics",
              icon: Icons.timer_rounded,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FiveMinQuizReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "One-Liner Report",
              subtitle: "Short answer exam performance",
              icon: Icons.format_list_numbered_rounded,
              color: Colors.teal,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OneLinerReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "Refer & Earn Report",
              subtitle: "Track recent student referrals and points",
              icon: Icons.group_add_rounded,
              color: Colors.indigo,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferAndEarnReportScreen())),
            ),
            _buildReportCard(
              context,
              title: "Upgrade Plan Report",
              subtitle: "Monitor recent premium account upgrades",
              icon: Icons.workspace_premium_rounded,
              color: Colors.amber.shade700,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UpgradePlanReportScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
