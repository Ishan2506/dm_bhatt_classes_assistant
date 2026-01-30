import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceListScreen extends StatefulWidget {
  final bool isStudent;
  final bool isEditing;
  final List<Map<String, dynamic>>? initialData;

  const AttendanceListScreen({
    super.key, 
    required this.isStudent,
    this.isEditing = false,
    this.initialData,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  // Dummy data
  final List<Map<String, dynamic>> _defaultStudents = [
    {"name": "Aarav Patel", "isPresent": true, "reason": ""},
    {"name": "Diya Shah", "isPresent": true, "reason": ""},
    {"name": "Rohan Mehta", "isPresent": true, "reason": ""},
    {"name": "Sita Verma", "isPresent": true, "reason": ""},
    {"name": "Vikram Singh", "isPresent": true, "reason": ""},
  ];
  
  final List<Map<String, dynamic>> _defaultGuests = [
    {"name": "Amit Kumar", "isPresent": true, "reason": ""},
    {"name": "Priya Sharma", "isPresent": true, "reason": ""},
    {"name": "Rahul Roy", "isPresent": true, "reason": ""},
    {"name": "Neha Gupta", "isPresent": true, "reason": ""},
  ];
  
  late List<Map<String, dynamic>> _listData;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _listData = widget.initialData!;
    } else {
      _listData = widget.isStudent ? _defaultStudents : _defaultGuests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.isStudent ? 'Student' : 'Guest'} Attendance",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _listData.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildStudentTile(index);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SizedBox(
               width: double.infinity,
               height: 56,
               child: ElevatedButton(
                 onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Attendance Submitted Successfully!"))
                   );
                   Navigator.pop(context);
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green.shade600,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 4,
                   shadowColor: Colors.green.shade200,
                 ),
                 child: Text(
                   "Submit Attendance",
                   style: GoogleFonts.poppins(
                     fontSize: 16, 
                     fontWeight: FontWeight.bold,
                     color: Colors.white
                   ),
                 ),
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(int index) {
    final student = _listData[index];
    bool isPresent = student["isPresent"];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent ? Colors.transparent : Colors.red.shade100,
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isPresent ? Colors.blue.shade50 : Colors.red.shade50,
                child: Text(
                  student["name"][0],
                  style: GoogleFonts.poppins(
                    color: isPresent ? Colors.blue.shade900 : Colors.red.shade900,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  student["name"],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: theme.textTheme.bodyLarge?.color),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPresent ? "Present" : "Absent",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isPresent ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isPresent,
                activeColor: Colors.green,
                activeTrackColor: Colors.green.shade100,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade100,
                onChanged: (val) {
                  setState(() {
                    _listData[index]["isPresent"] = val;
                    if (val) {
                      _listData[index]["reason"] = ""; // Clear reason if present
                    }
                  });
                },
              ),
            ],
          ),
          if (!isPresent && widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter reason for absence...",
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade400),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.edit_note, color: Colors.grey.shade400, size: 20),
                ),
                style: GoogleFonts.poppins(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                onChanged: (val) {
                  _listData[index]["reason"] = val;
                },
              ),
            ),
        ],
      ),
    );
  }
}
