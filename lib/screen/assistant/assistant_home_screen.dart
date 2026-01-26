import 'package:dm_bhatt_classes_new/screen/assistant/assistant_dashboard.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/attendance/attendance_selection.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/assistant_more_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/paperset_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistantHomeScreen extends StatefulWidget {
  const AssistantHomeScreen({super.key});

  @override
  State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends State<AssistantHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AssistantDashboard(),
    AttendanceSelectionScreen(),
    PapersetScreen(),
    AssistantMoreScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            activeIcon: Icon(Icons.class_),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: "PAPERSET",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}
