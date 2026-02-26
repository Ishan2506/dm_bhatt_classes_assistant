import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_add_one_liner_exam_screen.dart';

class AdminOneLinerExamHistoryScreen extends StatefulWidget {
  const AdminOneLinerExamHistoryScreen({super.key});

  @override
  State<AdminOneLinerExamHistoryScreen> createState() => _AdminOneLinerExamHistoryScreenState();
}

class _AdminOneLinerExamHistoryScreenState extends State<AdminOneLinerExamHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _exams = [];

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
      appBar: AppBar(
        title: Text("One Liner Exam History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.indigo.shade700]))),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? const Center(child: Text("No exams found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
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
                            Text("Questions: ${(exam['questions'] as List).length}", style: const TextStyle(fontWeight: FontWeight.w500)),
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
    );
  }
}
