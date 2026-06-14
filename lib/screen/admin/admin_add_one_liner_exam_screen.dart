import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_one_liner_exam_history_screen.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';
class AdminAddOneLinerExamScreen extends StatefulWidget {
  final Map<String, dynamic>? examData;
  const AdminAddOneLinerExamScreen({super.key, this.examData});

  @override
  State<AdminAddOneLinerExamScreen> createState() => _AdminAddOneLinerExamScreenState();
}

class _AdminAddOneLinerExamScreenState extends State<AdminAddOneLinerExamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedSubject;
  String? _selectedMarks;
  String? _id;
  bool _isSaving = false;

  List<Map<String, dynamic>> _questions = [
    {"questionText": "", "correctAnswer": "", "mark": "1"}
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
      _selectedBoard = widget.examData!['board'];
      _selectedSubject = widget.examData!['subject'];
      _selectedMarks = widget.examData!['totalMarks']?.toString();
      _selectedMedium = widget.examData!['medium'];
      _selectedStream = widget.examData!['stream'];
      if (_selectedMedium == "Gujarat") _selectedMedium = "Gujarati";
      
      final List<dynamic> qList = widget.examData!['questions'] ?? [];
      if (qList.isNotEmpty) {
        _questions = qList.map((q) => {
          "questionText": q['questionText']?.toString() ?? "",
          "correctAnswer": q['correctAnswer']?.toString() ?? "",
          "mark": q['mark']?.toString() ?? "1",
        }).toList();
      }
    }
  }

  Future<void> _saveExam() async {
    if (_selectedBoard == null || _selectedStd == null || _selectedSubject == null || _selectedMedium == null || 
        _selectedMarks == null || _unitController.text.isEmpty || _titleController.text.isEmpty) {
      CustomToast.showError(context, "Please fill all header fields");
      return;
    }

    if ((_selectedStd == "11" || _selectedStd == "12") && _selectedStream == null) {
      CustomToast.showError(context, "Please select a Stream");
      return;
    }

    if (_questions.any((q) => q['questionText']!.isEmpty || q['correctAnswer']!.isEmpty)) {
      CustomToast.showError(context, "Please fill all questions and answers");
      return;
    }

    final int expectedMarks = int.tryParse(_selectedMarks ?? "0") ?? 0;
    int currentSum = 0;
    for (var q in _questions) {
      currentSum += int.tryParse(q['mark']?.toString() ?? "1") ?? 1;
    }

    if (currentSum != expectedMarks) {
      CustomToast.showError(context, "Sum of question marks ($currentSum) must equal Total Marks ($expectedMarks).");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'board': _selectedBoard,
        'std': _selectedStd,
        'medium': _selectedMedium,
        'stream': _selectedStream ?? "-",
        'subject': _selectedSubject,
        'unit': _unitController.text,
        'title': _titleController.text,
        'totalMarks': int.tryParse(_selectedMarks!) ?? 20,
        'questions': _questions.map((q) => {
          'questionText': q['questionText'],
          'correctAnswer': q['correctAnswer'],
          'mark': int.tryParse(q['mark']?.toString() ?? "1") ?? 1
        }).toList(),
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
    if (_id != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Edit One Liner Exam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          actions: [
            if (_isSaving)
              const Padding(padding: EdgeInsets.all(8), child: CustomLoader(size: 32))
            else
              IconButton(icon: const Icon(Icons.check), onPressed: _saveExam),
          ],
        ),
        body: _buildForm(),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("One Liner Exam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          actions: [
            if (_isSaving)
              const Padding(padding: EdgeInsets.all(8), child: CustomLoader(size: 32))
            else
              IconButton(icon: const Icon(Icons.check), onPressed: _saveExam),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Add Exam"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildForm(),
            const AdminOneLinerExamHistoryScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
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
                onPressed: () {
                  final int expectedMarks = int.tryParse(_selectedMarks ?? "0") ?? 0;
                  int currentSum = 0;
                  for (var q in _questions) {
                    currentSum += int.tryParse(q['mark']?.toString() ?? "1") ?? 1;
                  }
                  if (expectedMarks > 0 && currentSum >= expectedMarks) {
                    CustomToast.showError(context, "Total marks ($expectedMarks) reached. Cannot add more questions.");
                    return;
                  }
                  setState(() => _questions.add({"questionText": "", "correctAnswer": "", "mark": "1"}));
                },
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
            DropdownButtonFormField<String>(
              value: _selectedBoard,
              decoration: InputDecoration(labelText: "Board", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: AcademicConstants.boards.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: _id != null ? null : (val) => setState(() {
                _selectedBoard = val;
                _selectedStd = null;
                _selectedSubject = null;
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStd,
                    decoration: InputDecoration(labelText: "Standard", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: (_selectedBoard == null ? <String>[] : AcademicConstants.standards[_selectedBoard!] ?? <String>[]).map((std) => DropdownMenuItem(value: std, child: Text(std))).toList(),
                    onChanged: _id != null ? null : (val) => setState(() {
                      _selectedStd = val;
                      _selectedSubject = null;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMedium,
                    decoration: InputDecoration(labelText: "Medium", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: AcademicConstants.mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: _id != null ? null : (val) => setState(() => _selectedMedium = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedStd == "11" || _selectedStd == "12") ...[
              DropdownButtonFormField<String>(
                value: _selectedStream,
                decoration: InputDecoration(labelText: "Stream", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["Science", "Commerce"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: _id != null ? null : (val) => setState(() => _selectedStream = val),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(labelText: "Subject", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: {
                ...(() {
                  if (_selectedBoard == null || _selectedStd == null) return <String>[];
                  String key = "$_selectedBoard-$_selectedStd";
                  if (_selectedStd == "11" || _selectedStd == "12") {
                    if (_selectedStream == null) return <String>[];
                    key += "-$_selectedStream";
                  }
                  return AcademicConstants.subjects[key] ?? <String>[];
                }()),
                if (_selectedSubject != null) _selectedSubject!
              }.map((subj) => DropdownMenuItem(value: subj, child: Text(subj))).toList(),
              onChanged: _id != null ? null : (val) => setState(() => _selectedSubject = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMarks,
              decoration: InputDecoration(labelText: "Marks", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: {
                ...AcademicConstants.oneLinerMarks,
                if (_selectedMarks != null) _selectedMarks!
              }.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: _id != null ? null : (val) => setState(() => _selectedMarks = val),
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
    final int expectedMarks = int.tryParse(_selectedMarks ?? "0") ?? 0;
    List<String> markOptions = [];
    if (expectedMarks > 0) {
       for (int i = 1; i <= expectedMarks; i++) {
         markOptions.add(i.toString());
       }
    } else {
       markOptions = ["1"];
    }
    
    // Ensure the current mark is valid for the dropdown
    if (!markOptions.contains(_questions[index]['mark'])) {
        _questions[index]['mark'] = markOptions.contains("1") ? "1" : markOptions.first;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Question ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<String>(
                        value: _questions[index]['mark'],
                        decoration: const InputDecoration(labelText: "Mark", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                        items: markOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setState(() => _questions[index]['mark'] = val),
                      ),
                    ),
                    if (_questions.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _questions.removeAt(index))),
                    ]
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
