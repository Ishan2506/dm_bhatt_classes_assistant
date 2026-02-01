import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class ReviewQuestionsScreen extends StatefulWidget {
  final List<dynamic> parsedQuestions;
  final String examName;
  final String subject;
  final String duration; // or int
  final String totalMarks; // or int

  const ReviewQuestionsScreen({
    super.key,
    required this.parsedQuestions,
    required this.examName,
    required this.subject,
    required this.duration,
    required this.totalMarks,
  });

  @override
  State<ReviewQuestionsScreen> createState() => _ReviewQuestionsScreenState();
}

class _ReviewQuestionsScreenState extends State<ReviewQuestionsScreen> {
  late List<dynamic> _questions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.parsedQuestions; // Copy list to modify
  }

  void _saveExam() async {
    setState(() => _isSaving = true);
    
    try {
      // Validate Basic Structure
      if (_questions.isEmpty) {
        CustomToast.showError(context, "Cannot save empty exam.");
        setState(() => _isSaving = false);
        return;
      }

      // Convert format if needed or send as is (assuming Backend expects this structure)
      // Backend expects: { name, subject, totalMarks, duration, questions: [{ questionText, options: [{key, text}], correctAnswer }] }
      // Our _questions matches this roughly.

      final response = await ApiService.createExam(
        name: widget.examName,
        subject: widget.subject,
        totalMarks: int.tryParse(widget.totalMarks) ?? 0,
        duration: int.tryParse(widget.duration) ?? 0,
        questions: List<Map<String, dynamic>>.from(_questions),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (response.statusCode == 201) {
        CustomToast.showSuccess(context, "Exam Created Successfully!");
        // Navigate back to Admin Dashboard or Exam List
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        CustomToast.showError(context, "Failed: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _editQuestion(int index) {
    // Show Dialog to Edit Question Text, Options, Answer
    final q = _questions[index];
    final TextEditingController qCtrl = TextEditingController(text: q['questionText']);
    final TextEditingController ansCtrl = TextEditingController(text: q['correctAnswer']);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Question"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qCtrl,
                decoration: const InputDecoration(labelText: "Question Text"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ansCtrl,
                decoration: const InputDecoration(labelText: "Correct Answer (A, B, C, D)"),
              ),
              // Options editing could be complex, omitting for MVP unless requested
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                q['questionText'] = qCtrl.text;
                q['correctAnswer'] = ansCtrl.text.toUpperCase();
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Review Import (${_questions.length})", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExam,
            tooltip: "Save Exam",
          )
        ],
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Text("${index + 1}")),
                            const SizedBox(width: 12),
                            Expanded(child: Text(q['questionText'] ?? "No Text", style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _editQuestion(index)),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteQuestion(index)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Options
                        if (q['options'] != null)
                          ...List<dynamic>.from(q['options']).map((opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "${opt['key']}) ${opt['text']}", 
                              style: TextStyle(
                                color: opt['key'] == q['correctAnswer'] ? Colors.green : Colors.black87,
                                fontWeight: opt['key'] == q['correctAnswer'] ? FontWeight.bold : FontWeight.normal
                              )
                            ),
                          )),
                         const SizedBox(height: 8),
                         Text("Answer: ${q['correctAnswer']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExam,
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.save),
      ),
    );
  }
}
