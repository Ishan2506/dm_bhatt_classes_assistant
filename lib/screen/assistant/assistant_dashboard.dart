import 'package:dm_bhatt_classes_new/screen/assistant/edit_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistantDashboard extends StatefulWidget {
  const AssistantDashboard({super.key});

  @override
  State<AssistantDashboard> createState() => _AssistantDashboardState();
}

class _AssistantDashboardState extends State<AssistantDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selection state
  String? _selectedStandard;
  String? _selectedMedium;

  // Dummy Data
  final List<Map<String, String>> _allStudents = [
    // Std 9
    {"name": "Rohan Mehta", "std": "9", "stream": "General", "medium": "English", "phone": "1234567890"},
    {"name": "Ayesha Khan", "std": "9", "stream": "General", "medium": "Gujarati", "phone": "1234567891"},
    
    // Std 10
    {"name": "Aarav Patel", "std": "10", "stream": "Science", "medium": "English", "phone": "1234567892"},
    {"name": "Vihan Shah", "std": "10", "stream": "Science", "medium": "Gujarati", "phone": "1234567893"},

    // Std 12
    {"name": "Diya Shah", "std": "12", "stream": "Commerce", "medium": "English", "phone": "1234567894"},
  ];

  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];

  final List<Map<String, String>> _guests = [
    {"name": "Guest User 1", "phone": "9876543210"},
    {"name": "Guest User 2", "phone": "9123456780"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    setState(() {
      if (_selectedMedium != null) {
        _selectedMedium = null;
      } else if (_selectedStandard != null) {
        _selectedStandard = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to show back button in app bar
    bool canGoBack = _tabController.index == 0 && (_selectedStandard != null);

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Lighter background
      appBar: AppBar(
        leading: canGoBack 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _handleBack,
            )
          : null,
        title: Text(
          "Assistant Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          onTap: (index) {
             setState(() {}); // Rebuild to update back button state
          },
          tabs: const [
            Tab(text: "Students"),
            Tab(text: "Guests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid confusion with internal nav
        children: [
          _buildStudentFlow(),
          _buildGuestList(),
        ],
      ),
    );
  }

  Widget _buildStudentFlow() {
    if (_selectedStandard == null) {
      return _buildStandardList();
    } else if (_selectedMedium == null) {
      return _buildMediumList();
    } else {
      return _buildStudentList();
    }
  }

  Widget _buildStandardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _standards.length,
      itemBuilder: (context, index) {
        final std = _standards[index];
        return _buildSelectionCard(
          title: "Standard $std",
          icon: Icons.class_outlined,
          color: Colors.blue.shade50,
          iconColor: Colors.blue.shade800,
          onTap: () {
            setState(() {
              _selectedStandard = std;
            });
          },
        );
      },
    );
  }

  Widget _buildMediumList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Select Medium for Std $_selectedStandard",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mediums.length,
            itemBuilder: (context, index) {
              final medium = _mediums[index];
              return _buildSelectionCard(
                title: medium,
                icon: Icons.language,
                color: Colors.orange.shade50,
                iconColor: Colors.orange.shade800,
                onTap: () {
                  setState(() {
                    _selectedMedium = medium;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildStudentList() {
    final filteredStudents = _allStudents.where((s) {
      return s["std"] == _selectedStandard && s["medium"] == _selectedMedium;
    }).toList();

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No students found in Std $_selectedStandard ($_selectedMedium)",
              style: GoogleFonts.poppins(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
               Text(
                "Std $_selectedStandard • $_selectedMedium",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900
                ),
              ),
              const Spacer(),
              Text(
                "${filteredStudents.length} Students",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      student["name"]![0],
                      style: GoogleFonts.poppins(
                        color: Colors.blue.shade900, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    student["name"]!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Stream: ${student["stream"]}",
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () => _navigateToEditStudent(student),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuestList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _guests.length,
      itemBuilder: (context, index) {
        final guest = _guests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange.shade50,
              child: Icon(Icons.person_outline, color: Colors.orange.shade800),
            ),
            title: Text(
              guest["name"]!,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                guest["phone"]!,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }

  void _navigateToEditStudent(Map<String, String> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentScreen(studentData: student),
      ),
    );
  }
}
