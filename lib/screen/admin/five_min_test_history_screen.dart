import 'package:dm_bhatt_classes_new/screen/admin/create_five_min_test_screen.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiveMinTestHistoryScreen extends StatefulWidget {
  const FiveMinTestHistoryScreen({super.key});

  @override
  State<FiveMinTestHistoryScreen> createState() => _FiveMinTestHistoryScreenState();
}

class _FiveMinTestHistoryScreenState extends State<FiveMinTestHistoryScreen> {
  // Filters
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;

  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];

  // Mock Data
  final List<Map<String, dynamic>> _allTests = [
    {
      "id": "1",
      "subject": "Maths",
      "unit": "Algebra Basics",
      "std": "10",
      "medium": "English",
      "stream": "General",
      "date": "28 Jan 2024"
    },
    {
      "id": "2",
      "subject": "Science",
      "unit": "Physics Ch 1",
      "std": "12",
      "medium": "English",
      "stream": "Science",
      "date": "29 Jan 2024"
    },
    {
      "id": "3",
      "subject": "Gujarati",
      "unit": "Kavita 1",
      "std": "9",
      "medium": "Gujarati",
      "stream": "General",
      "date": "30 Jan 2024"
    },
  ];

  List<Map<String, dynamic>> get _filteredTests {
    return _allTests.where((test) {
      final matchStd = _selectedStandard == null || test['std'] == _selectedStandard;
      final matchMedium = _selectedMedium == null || test['medium'] == _selectedMedium;
      final matchStream = _selectedStream == null || test['stream'] == _selectedStream;
      return matchStd && matchMedium && matchStream;
    }).toList();
  }

  void _deleteTest(String id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade900, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              "Delete Test",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this test?",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _allTests.removeWhere((t) => t['id'] == id);
              });
              CustomToast.showSuccess(context, "Test Deleted Successfully");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  void _navigateToCreate({Map<String, dynamic>? testToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFiveMinTestScreen(testToEdit: testToEdit),
      ),
    ).then((_) {
      // Refresh logic would go here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "5 Min Test History",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
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
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(),
        backgroundColor: Colors.blue.shade900,
        label: Text("Add New Test", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Filters", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown("Standard", _selectedStandard, _standards, (val) => setState(() => _selectedStandard = val)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown("Medium", _selectedMedium, _mediums, (val) => setState(() => _selectedMedium = val)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown("Stream", _selectedStream, _streams, (val) => setState(() => _selectedStream = val)),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: _filteredTests.isEmpty
                ? Center(child: Text("No tests found", style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTests.length,
                    itemBuilder: (context, index) {
                      final test = _filteredTests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.timer_outlined, color: Colors.blue.shade900),
                          ),
                          title: Text(
                            "${test['subject']} - ${test['unit']}",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Std: ${test['std']} | ${test['medium']} | ${test['stream']}",
                              style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToCreate(testToEdit: test),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTest(test['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
