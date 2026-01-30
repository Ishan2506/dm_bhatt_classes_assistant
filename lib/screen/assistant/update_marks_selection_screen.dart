import 'package:dm_bhatt_classes_new/screen/assistant/update_marks_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateMarksSelectionScreen extends StatefulWidget {
  const UpdateMarksSelectionScreen({super.key});

  @override
  State<UpdateMarksSelectionScreen> createState() => _UpdateMarksSelectionScreenState();
}

class _UpdateMarksSelectionScreenState extends State<UpdateMarksSelectionScreen> {
  // Filters
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;

  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];

  // Mock Exams
  final List<Map<String, dynamic>> _exams = [
    {
      "id": "101",
      "subject": "Mathematics Part-1",
      "std": "10",
      "medium": "English",
      "stream": null,
      "marks": 50,
      "date": "24 Jan"
    },
    {
       "id": "102",
      "subject": "Physics Unit Test 3",
      "std": "12",
      "medium": "English",
      "stream": "Science",
      "marks": 25,
      "date": "22 Jan"
    },
     {
       "id": "103",
      "subject": "Gujarati Grammar",
      "std": "9",
      "medium": "Gujarati",
      "stream": null,
      "marks": 30,
      "date": "20 Jan"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredExams = _exams.where((exam) {
      if (_selectedStandard != null && exam["std"] != _selectedStandard) return false;
      if (_selectedMedium != null && exam["medium"] != _selectedMedium) return false;
      if (_selectedStream != null && exam["stream"] != null && exam["stream"] != _selectedStream) return false;
      return true;
    }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
       appBar: AppBar(
        title: Text(
          "Select Exam",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: theme.cardColor,
               borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                   blurRadius: 10,
                   offset: const Offset(0, 5),
                 )
               ] 
             ),
             child: Column(
               children: [
                 Row(
                   children: [
                     Expanded(child: _buildDropdown("Standard", _selectedStandard, _standards, (val) => setState(() => _selectedStandard = val))),
                     const SizedBox(width: 12),
                     Expanded(child: _buildDropdown("Medium", _selectedMedium, _mediums, (val) => setState(() => _selectedMedium = val))),
                   ],
                 ),
                 if (_selectedStandard == "11" || _selectedStandard == "12") ...[
                    const SizedBox(height: 12),
                    _buildDropdown("Stream", _selectedStream, _streams, (val) => setState(() => _selectedStream = val)),
                 ]
               ],
             ),
           ),

           // Exams List
           Expanded(
             child: filteredExams.isEmpty 
               ? Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.assignment_outlined, size: 64, color: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.grey.shade300),
                       const SizedBox(height: 16),
                       Text("No exams found for selection", style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color)),
                     ],
                   ),
                 )
               : ListView.builder(
                   padding: const EdgeInsets.all(16),
                   itemCount: filteredExams.length,
                   itemBuilder: (context, index) {
                     final exam = filteredExams[index];
                     return _buildExamCard(exam);
                   },
                 ),
           ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
      ),
      style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
      dropdownColor: theme.cardColor,
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
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
          )
        ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateMarksListScreen(exam: exam)));
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade900.withOpacity(0.4) : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.assignment_turned_in, color: isDark ? Colors.blue.shade200 : Colors.blue.shade800),
        ),
        title: Text(
          exam["subject"],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${exam['marks']} Marks • ${exam['date']}",
            style: GoogleFonts.poppins(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
      ),
    );
  }
}
