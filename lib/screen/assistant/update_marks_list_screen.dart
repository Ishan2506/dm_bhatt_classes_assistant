import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateMarksListScreen extends StatefulWidget {
  final Map<String, dynamic> exam;
  const UpdateMarksListScreen({super.key, required this.exam});

  @override
  State<UpdateMarksListScreen> createState() => _UpdateMarksListScreenState();
}

class _UpdateMarksListScreenState extends State<UpdateMarksListScreen> {
  late List<Map<String, dynamic>> _students;
  final Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    // Simulate fetching students based on exam Std/Medium
    _students = [
      {"id": "1", "name": "Aarav Patel", "roll": "101"},
      {"id": "2", "name": "Diya Shah", "roll": "102"},
      {"id": "3", "name": "Rohan Mehta", "roll": "103"},
      {"id": "4", "name": "Priya Sharma", "roll": "104"},
       {"id": "5", "name": "Vihan Shah", "roll": "105"},
    ];

    for (var student in _students) {
      _marksControllers[student["id"]] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Marks",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "${widget.exam['subject']} (${widget.exam['marks']} Marks)",
              style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ],
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
              itemCount: _students.length,
              separatorBuilder: (context, index) => Divider(color: theme.dividerColor),
              itemBuilder: (context, index) {
                final student = _students[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark ? Colors.blue.shade900.withOpacity(0.4) : Colors.blue.shade50,
                    child: Text(
                      student["roll"].substring(student["roll"].length - 2), // Show last 2 digits
                      style: GoogleFonts.poppins(color: isDark ? Colors.blue.shade200 : Colors.blue.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    student["name"],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                  ),
                  subtitle: Text(
                    "Roll No: ${student["roll"]}",
                    style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                  ),
                  trailing: SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _marksControllers[student["id"]],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        ),
                        filled: true,
                         fillColor: isDark ? Colors.grey.shade900 : Colors.indigo.shade50.withOpacity(0.3),
                      ),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Validate marks (should be <= total marks)
                  bool hasError = false;
                  int maxMarks = int.tryParse(widget.exam['marks'].toString()) ?? 100;

                  for (var student in _students) {
                    final marks = int.tryParse(_marksControllers[student["id"]]!.text) ?? 0;
                    if (marks > maxMarks) {
                      hasError = true;
                      break;
                    }
                  }

                  if (hasError) {
                    CustomToast.showError(context, "Marks cannot lie greater than Total Marks ($maxMarks)");
                  } else {
                    CustomToast.showSuccess(context, "Marks Updated Successfully");
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Save Marks", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
