import 'package:dm_bhatt_classes_new/screen/assistant/attendance/attendance_history.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/attendance/attendance_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

class AttendanceSelectionScreen extends StatefulWidget {
  const AttendanceSelectionScreen({super.key});

  @override
  State<AttendanceSelectionScreen> createState() => _AttendanceSelectionScreenState();
}

class _AttendanceSelectionScreenState extends State<AttendanceSelectionScreen> {
  bool _isStudent = true;
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;

  final List<String> _standards = ["8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "New Attendance",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
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

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Date Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.blue.shade900 : Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: isDark ? Colors.blue.shade200 : Colors.blue.shade900),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date (Auto-picked)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Type Selection (Student/History)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudent = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                             color: _isStudent ? theme.cardColor : Colors.transparent,
                             borderRadius: BorderRadius.circular(10),
                             boxShadow: _isStudent ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Students",
                            style: GoogleFonts.poppins(
                              fontWeight: _isStudent ? FontWeight.bold : FontWeight.w500,
                              color: _isStudent ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudent = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                             color: !_isStudent ? theme.cardColor : Colors.transparent,
                             borderRadius: BorderRadius.circular(10),
                             boxShadow: !_isStudent ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "History", 
                            style: GoogleFonts.poppins(
                              fontWeight: !_isStudent ? FontWeight.bold : FontWeight.w500,
                              color: !_isStudent ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Class Filters (Visible for both, or customize slightly if needed)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                   color: theme.cardColor,
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [
                     BoxShadow(
                       color: isDark ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.05),
                       blurRadius: 20,
                       offset: const Offset(0, 10),
                     ),
                   ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isStudent ? "Select Class Details" : "Filter History",
                      style: GoogleFonts.poppins(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: theme.primaryColor
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isStudent ? "Filter students to mark attendance" : "Select class to view past records",
                      style: GoogleFonts.poppins(
                        fontSize: 14, 
                        color: theme.textTheme.bodyMedium?.color
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown("Standard", _standards, _selectedStandard, (val) {
                      setState(() => _selectedStandard = val);
                    }),
                    const SizedBox(height: 16),
                    _buildDropdown("Medium", _mediums, _selectedMedium, (val) {
                      setState(() => _selectedMedium = val);
                    }),
                    const SizedBox(height: 16),
                    if (_selectedStandard == "11" || _selectedStandard == "12") ...[
                      _buildDropdown("Stream", _streams, _selectedStream, (val) {
                        setState(() => _selectedStream = val);
                      }),
                      const SizedBox(height: 16),
                    ]
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedStandard == null || _selectedMedium == null) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select Standard and Medium"))
                        );
                        return;
                    }

                    if (_isStudent) {
                         // Go to New Attendance List
                         Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AttendanceListScreen(isStudent: true))
                        );
                    } else {
                      // Go to History (Filtered)
                      Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen())
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shadowColor: Colors.blue.shade200,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isStudent ? "Show Students" : "Show History",
                        style: GoogleFonts.poppins(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              hint: Text("Select $label", style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color)),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue.shade700),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
