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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        leading: canGoBack 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _handleBack,
            )
          : null,
        title: Text(
          "Assistant Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.amber,
          indicatorWeight: 4,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          onTap: (index) {
             setState(() {});
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
          _buildStudentTab(),
          _buildGuestList(),
        ],
      ),
    );
  }

  Widget _buildStudentTab() {
    if (_selectedStandard == null) {
      return _buildStandardList();
    } else if (_selectedMedium == null) {
      return _buildMediumList();
    } else {
      return _buildStudentList();
    }
  }

  Widget _buildStandardList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3, // Make cards shorter/smaller
      ),
      itemCount: _standards.length,
      itemBuilder: (context, index) {
        final std = _standards[index];
        return _buildGridCard(
          title: "Standard $std",
          iconText: std,
          color: Colors.blue.shade50,
          accentColor: Colors.blue.shade900,
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            "Select Medium",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "For Standard $_selectedStandard",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3, // Make cards shorter/smaller
            ),
            itemCount: _mediums.length,
            itemBuilder: (context, index) {
              final medium = _mediums[index];
              return _buildGridCard(
                title: medium,
                icon: Icons.language,
                color: Colors.orange.shade50,
                accentColor: Colors.orange.shade800,
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

  Widget _buildGridCard({
    required String title,
    IconData? icon,
    String? iconText,
    required Color color,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16), // Slightly tighter radius
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56, // Reduced from 64
              width: 56,  // Reduced from 64
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.2) : color,
                shape: BoxShape.circle,
              ),
              child: iconText != null 
                  ? Text(
                      iconText,
                      style: GoogleFonts.poppins(
                        color: isDark ? accentColor.withOpacity(0.8) : accentColor,
                        fontSize: 24, // Reduced from 28
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(icon, color: isDark ? accentColor.withOpacity(0.8) : accentColor, size: 28), // Reduced from 32
            ),
            const SizedBox(height: 12), // Reduced spacing
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Reduced from 16
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Students (Std $_selectedStandard - $_selectedMedium)",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedMedium = null;
                   
                  });
                }, 
                child: Text("Change Medium")
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
              return _buildListCard(
                title: student["name"]!,
                subtitle: "Stream: ${student["stream"]}",
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
                onTap: () => _navigateToEditStudent(student),
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
        return _buildListCard(
          title: guest["name"]!,
          subtitle: guest["phone"]!,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: Colors.orange.shade800, size: 24),
          ),
          onTap: () {
            // Guest Details
          },
        );
      },
    );
  }

  Widget _buildListCard({
    required String title,
    required String subtitle,
    required Widget leading,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 16, 
            color: theme.textTheme.bodyLarge?.color
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13, 
              color: theme.textTheme.bodyMedium?.color
            ),
          ),
        ),
        trailing: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50, 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 20),
          ),
        ),
      ),
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
