import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class AdminAddOneLinerExamScreen extends StatefulWidget {
  final Map<String, dynamic>? examData;
  const AdminAddOneLinerExamScreen({super.key, this.examData});

  @override
  State<AdminAddOneLinerExamScreen> createState() => _AdminAddOneLinerExamScreenState();
}

class _AdminAddOneLinerExamScreenState extends State<AdminAddOneLinerExamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String? _selectedStd;
  String? _selectedSubject;
  String? _selectedMedium;
  String? _id;
  bool _isSaving = false;

  final List<String> _stds = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _subjects = ["Science", "Maths", "English", "Gujarati", "Social Science", "Sanskrit", "Hindi", "Other"];
  final List<String> _mediums = ["Gujarati", "English"];

  List<Map<String, String>> _questions = [
    {"questionText": "", "correctAnswer": ""}
  ];

  @override
  void initState() {
    super.initState();
    if (widget.examData != null) {
      _id = widget.examData!['_id'];
      _titleController.text = widget.examData!['title'] ?? "";
      _unitController.text = widget.examData!['unit'] ?? "";
      _selectedStd = widget.examData!['std'];
      if (_selectedStd != null && _selectedStd!.endsWith("th")) {
        _selectedStd = _selectedStd!.replaceAll("th", "");
      }
      _selectedSubject = widget.examData!['subject'];
      _selectedMedium = widget.examData!['medium'];
      if (_selectedMedium == "Gujarat") _selectedMedium = "Gujarati";
      
      final List<dynamic> qList = widget.examData!['questions'] ?? [];
      if (qList.isNotEmpty) {
        _questions = qList.map((q) => {
          "questionText": q['questionText']?.toString() ?? "",
          "correctAnswer": q['correctAnswer']?.toString() ?? "",
        }).toList();
      }
    }
  }

  Future<void> _saveExam() async {
    if (_selectedStd == null || _selectedSubject == null || _selectedMedium == null || 
        _unitController.text.isEmpty || _titleController.text.isEmpty) {
      CustomToast.showError(context, "Please fill all header fields");
      return;
    }

    if (_questions.any((q) => q['questionText']!.isEmpty || q['correctAnswer']!.isEmpty)) {
      CustomToast.showError(context, "Please fill all questions and answers");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'std': _selectedStd,
        'medium': _selectedMedium,
        'subject': _selectedSubject,
        'unit': _unitController.text,
        'title': _titleController.text,
        'questions': _questions,
      };

      final response = _id != null 
          ? await ApiService.updateOneLinerExam(_id!, data)
          : await ApiService.createOneLinerExam(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        CustomToast.showSuccess(context, _id != null ? "Exam updated" : "Exam created");
        Navigator.pop(context, true);
      } else {
        CustomToast.showError(context, "Failed to save: ${response.body}");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_id != null ? "Edit One Liner Exam" : "Add One Liner Exam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.indigo.shade700]))),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white))
          else
            IconButton(icon: const Icon(Icons.check, color: Colors.white), onPressed: _saveExam),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderFields(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Questions & Answers", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => setState(() => _questions.add({"question": "", "answer": ""})),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(index);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderFields() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStd,
                    decoration: InputDecoration(labelText: "Standard", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: _stds.map((std) => DropdownMenuItem(value: std, child: Text(std))).toList(),
                    onChanged: (val) => setState(() => _selectedStd = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMedium,
                    decoration: InputDecoration(labelText: "Medium", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: _mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) => setState(() => _selectedMedium = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(labelText: "Subject", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: _subjects.map((subj) => DropdownMenuItem(value: subj, child: Text(subj))).toList(),
              onChanged: (val) => setState(() => _selectedSubject = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(labelText: "Unit / Topic", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Exam Title", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_questions.length > 1)
              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _questions.removeAt(index))),
            TextFormField(
              initialValue: _questions[index]['questionText'],
              decoration: const InputDecoration(labelText: "Question", border: OutlineInputBorder()),
              maxLines: 2,
              onChanged: (val) => _questions[index]['questionText'] = val,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _questions[index]['correctAnswer'],
              decoration: const InputDecoration(labelText: "Answer", border: OutlineInputBorder()),
              maxLines: 2,
              onChanged: (val) => _questions[index]['correctAnswer'] = val,
            ),
          ],
        ),
      ),
    );
  }
}
