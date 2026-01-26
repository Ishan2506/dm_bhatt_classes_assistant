import 'package:dm_bhatt_classes_new/screen/assistant/attendance/attendance_list.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/attendance/attendance_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  // Filters
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;
  bool _filtersVisible = false;

  final List<String> _standards = ["8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];

  // Dummy history data
  final List<Map<String, dynamic>> _history = [
    {
      "date": DateTime.now().subtract(const Duration(days: 0)),
      "type": "Student",
      "details": "Std 10 | Science | Eng",
      "total": 50,
      "present": 45,
      "absent": 5,
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "type": "Guest",
      "details": "General Guest List",
      "total": 12,
      "present": 10,
      "absent": 2,
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "type": "Student",
      "details": "Std 12 | Commerce | Guj",
      "total": 40,
      "present": 38,
      "absent": 2,
    },
     {
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "type": "Student",
      "details": "Std 9 | General | Eng",
      "total": 45,
      "present": 40,
      "absent": 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Attendance History",
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
        centerTitle: false,
        automaticallyImplyLeading: false, // Hide back button as it's a main tab
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceSelectionScreen()),
          );
        },
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("New Attendance", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _filtersVisible = !_filtersVisible),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter Records", 
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue.shade900)
                      ),
                      Icon(
                        _filtersVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.blue.shade900,
                      )
                    ],
                  ),
                ),
                if (_filtersVisible) ...[
                  const SizedBox(height: 16),
                  _buildDropdown("Standard", _standards, _selectedStandard, (val) {
                    setState(() => _selectedStandard = val);
                  }),
                  const SizedBox(height: 12),
                  _buildDropdown("Medium", _mediums, _selectedMedium, (val) {
                    setState(() => _selectedMedium = val);
                  }),
                  const SizedBox(height: 12),
                  if (_selectedStandard == "11" || _selectedStandard == "12")
                    _buildDropdown("Stream", _streams, _selectedStream, (val) {
                      setState(() => _selectedStream = val);
                    }),
                ]
              ],
            ),
          ),
          
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No attendance records found",
                          style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      // Simple filter logic (dummy) - In real app, filter _history list based on selection
                      return GestureDetector(
                        onTap: () {
                           // Navigate to Edit Mode
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceListScreen(
                                isStudent: item['type'] == 'Student',
                                isEditing: true,
                                // Pass generic dummy data as initialData for editing
                              ),
                            ),
                          );
                        },
                        child: _buildHistoryCard(item)
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text("Select $label", style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue.shade700, size: 20),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isStudent = item['type'] == 'Student';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isStudent ? Colors.blue.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isStudent ? Icons.school : Icons.person_outline,
                        color: isStudent ? Colors.blue.shade700 : Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['type'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          dateFormat.format(item['date']),
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Text(
                    "Submitted",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['details'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBadge("Total", item['total'].toString(), Colors.grey),
                const SizedBox(width: 8),
                _buildStatBadge("Present", item['present'].toString(), Colors.green),
                const SizedBox(width: 8),
                _buildStatBadge("Absent", item['absent'].toString(), Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(fontSize: 11, color: color.shade700),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color.shade900),
          ),
        ],
      ),
    );
  }
}
