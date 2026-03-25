import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_add_one_liner_exam_screen.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class AdminOneLinerExamHistoryScreen extends StatefulWidget {
  const AdminOneLinerExamHistoryScreen({super.key});

  @override
  State<AdminOneLinerExamHistoryScreen> createState() => _AdminOneLinerExamHistoryScreenState();
}

class _AdminOneLinerExamHistoryScreenState extends State<AdminOneLinerExamHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _exams = [];
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _filterBoard;
  String? _filterStandard;
  String? _filterMedium;
  String? _filterStream;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAllOneLinerExams();
      if (response.statusCode == 200) {
        setState(() {
          _exams = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        CustomToast.showError(context, "Failed to fetch exams");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExam(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this exam?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.deleteOneLinerExam(id);
        if (response.statusCode == 200) {
          CustomToast.showSuccess(context, "Exam deleted");
          _fetchExams();
        } else {
          CustomToast.showError(context, "Failed to delete");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CustomLoader())
                : _getFilteredExams().isEmpty
                    ? const Center(child: Text("No exams found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _getFilteredExams().length,
                        itemBuilder: (context, index) {
                          final exam = _getFilteredExams()[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(exam['title'] ?? 'Untitled', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("${exam['std']} Standard | ${exam['medium']} Medium", style: const TextStyle(color: Colors.grey)),
                            Text("${exam['subject']} | Unit: ${exam['unit']}", style: const TextStyle(color: Colors.grey)),
                            Text("Questions: ${(exam['questions'] as List).length} | Marks: ${exam['totalMarks'] ?? 20}", style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminAddOneLinerExamScreen(examData: exam),
                                  ),
                                );
                                if (result == true) _fetchExams();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExam(exam['_id']),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredExams() {
    return _exams.where((exam) {
      final title = (exam['title'] ?? "").toString().toLowerCase();
      final subject = (exam['subject'] ?? "").toString().toLowerCase();
      final query = _searchController.text.toLowerCase();
      
      final matchesSearch = title.contains(query) || subject.contains(query);
      
      final matchesBoard = _filterBoard == null || exam['board'] == _filterBoard;
      final matchesStd = _filterStandard == null || exam['std'] == _filterStandard;
      final matchesMedium = _filterMedium == null || exam['medium'] == _filterMedium;
      final matchesStream = _filterStream == null || exam['stream'] == _filterStream;

      return matchesSearch && matchesBoard && matchesStd && matchesMedium && matchesStream;
    }).toList();
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search by Title or Subject...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () => setState(() => _searchController.clear()))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Filters Row 1
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Board", 
                  _filterBoard, 
                  AcademicConstants.boards, 
                  (val) => setState(() {
                    _filterBoard = val;
                    _filterStandard = null;
                  })
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  "Std", 
                  _filterStandard, 
                  _filterBoard == null ? [] : AcademicConstants.standards[_filterBoard!] ?? [], 
                  (val) => setState(() => _filterStandard = val)
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filters Row 2
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Medium", 
                  _filterMedium, 
                  AcademicConstants.mediums, 
                  (val) => setState(() => _filterMedium = val)
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  "Stream", 
                  _filterStream, 
                  ["Science", "Commerce"], 
                  (val) => setState(() => _filterStream = val)
                ),
              ),
            ],
          ),
          if (_filterBoard != null || _filterStandard != null || _filterMedium != null || _filterStream != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _filterBoard = null;
                  _filterStandard = null;
                  _filterMedium = null;
                  _filterStream = null;
                  _searchController.clear();
                }),
                icon: const Icon(Icons.filter_list_off, size: 16),
                label: Text("Clear All Filters", style: GoogleFonts.poppins(fontSize: 12)),
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
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem(value: null, child: Text("All $hint", style: GoogleFonts.poppins(fontSize: 14))),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
