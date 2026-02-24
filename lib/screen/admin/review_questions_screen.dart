import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReviewQuestionsScreen extends StatefulWidget {
  final List<dynamic> parsedQuestions;
  final String title;
  final String subject;
  final String std;
  final String medium;
  final String unit;
  final String totalMarks; // or int

  const ReviewQuestionsScreen({
    super.key,
    required this.parsedQuestions,
    required this.title,
    required this.subject,
    required this.std,
    required this.medium,
    required this.unit,
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
    _questions = List.from(widget.parsedQuestions); // Copy list to modify
    
    // Logic: If more questions uploaded than marks, pick random ones
    int target = int.tryParse(widget.totalMarks) ?? 0;
    if (_questions.length > target && target > 0) {
       _questions.shuffle();
       _questions = _questions.sublist(0, target);
       debugPrint("Randomly selected $target questions from imported list.");
    }
  }

  void _saveExam() async {
    // setState(() => _isSaving = true);
    CustomLoader.show(context);
    
    try {
      // Validate Basic Structure
      if (_questions.isEmpty) {
        CustomToast.showError(context, "Cannot save empty exam.");
        setState(() => _isSaving = false);
        return;
      }

      int target = int.tryParse(widget.totalMarks) ?? 0;
      if (_questions.length != target) {
        CustomToast.showError(context, "Question count (${_questions.length}) does not match Total Marks ($target). Please add or remove questions.");
        setState(() => _isSaving = false);
        return;
      }

      // Convert format if needed or send as is (assuming Backend expects this structure)
      // Backend expects: { name, subject, totalMarks, duration, questions: [{ questionText, options: [{key, text}], correctAnswer }] }
      // Our _questions matches this roughly.

      final response = await ApiService.createExam(
        title: widget.title,
        subject: widget.subject,
        std: widget.std,
        medium: widget.medium,
        unit: widget.unit,
        totalMarks: int.tryParse(widget.totalMarks) ?? 0,
        questions: List<Map<String, dynamic>>.from(_questions),
      );

      if (!mounted) return;
      // setState(() => _isSaving = false);
      CustomLoader.hide(context);

      if (response.statusCode == 201) {
        CustomToast.showSuccess(context, "Exam Created Successfully!");
        // Navigate back to Admin Dashboard or Exam List
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        CustomToast.showError(context, "Failed: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        // setState(() => _isSaving = false);
        CustomLoader.hide(context);
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );

      if (result != null) {
        CustomLoader.show(context);
        final response = await ApiService.uploadImage(file: result.files.single);
        CustomLoader.hide(context);

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          return body['imageUrl'];
        } else {
          CustomToast.showError(context, "Upload failed: ${response.body}");
        }
      }
    } catch (e) {
      CustomLoader.hide(context);
      CustomToast.showError(context, "Error uploading image: $e");
    }
    return null;
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
    
    // Extract existing option texts if they exist
    String optA = "";
    String optB = "";
    String optC = "";
    String optD = "";
    
    if (q['options'] != null) {
      for (var opt in q['options']) {
        if (opt['key'] == 'A') optA = opt['text'] ?? "";
        if (opt['key'] == 'B') optB = opt['text'] ?? "";
        if (opt['key'] == 'C') optC = opt['text'] ?? "";
        if (opt['key'] == 'D') optD = opt['text'] ?? "";
      }
    }

    final TextEditingController optACtrl = TextEditingController(text: optA);
    final TextEditingController optBCtrl = TextEditingController(text: optB);
    final TextEditingController optCCtrl = TextEditingController(text: optC);
    final TextEditingController optDCtrl = TextEditingController(text: optD);
    
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
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(labelText: "Question Text"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _buildImageUploadButton(
                label: "Question Image",
                imageUrl: q['questionImage'],
                onUpload: (url) => setState(() => q['questionImage'] = url),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: optACtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option A"),
              ),
              TextField(
                controller: optBCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option B"),
              ),
              TextField(
                controller: optCCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option C"),
              ),
              TextField(
                controller: optDCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option D"),
              ),
              const SizedBox(height: 10),
              // Option Images
              _buildImageUploadButton(
                label: "Option A Image",
                imageUrl: _getOptionImage(q, 'A'),
                onUpload: (url) => _setOptionImage(q, 'A', url),
              ),
              _buildImageUploadButton(
                label: "Option B Image",
                imageUrl: _getOptionImage(q, 'B'),
                onUpload: (url) => _setOptionImage(q, 'B', url),
              ),
              _buildImageUploadButton(
                label: "Option C Image",
                imageUrl: _getOptionImage(q, 'C'),
                onUpload: (url) => _setOptionImage(q, 'C', url),
              ),
              _buildImageUploadButton(
                label: "Option D Image",
                imageUrl: _getOptionImage(q, 'D'),
                onUpload: (url) => _setOptionImage(q, 'D', url),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ansCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(labelText: "Correct Answer (A, B, C, D)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              bool qValid = qCtrl.text.isNotEmpty || q['questionImage'] != null;
              bool optAValid = optACtrl.text.isNotEmpty || _getOptionImage(q, 'A') != null;
              bool optBValid = optBCtrl.text.isNotEmpty || _getOptionImage(q, 'B') != null;

              if (!qValid || !optAValid || !optBValid || ansCtrl.text.isEmpty) {
                CustomToast.showError(context, "Please fill basic fields (either text or image for Q, A, B).");
                return;
              }
              setState(() {
                q['questionText'] = qCtrl.text;
                q['correctAnswer'] = ansCtrl.text.toUpperCase();
                q['options'] = [
                  {'key': 'A', 'text': optACtrl.text, 'image': _getOptionImage(q, 'A')},
                  {'key': 'B', 'text': optBCtrl.text, 'image': _getOptionImage(q, 'B')},
                  {'key': 'C', 'text': optCCtrl.text, 'image': _getOptionImage(q, 'C')},
                  {'key': 'D', 'text': optDCtrl.text, 'image': _getOptionImage(q, 'D')},
                ];
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _addQuestion() {
    final TextEditingController qCtrl = TextEditingController();
    final TextEditingController ansCtrl = TextEditingController();
    final TextEditingController optACtrl = TextEditingController();
    final TextEditingController optBCtrl = TextEditingController();
    final TextEditingController optCCtrl = TextEditingController();
    final TextEditingController optDCtrl = TextEditingController();
    final Map<String, dynamic> qData = {
      'questionText': '',
      'questionImage': null,
      'optionAImage': null,
      'optionBImage': null,
      'optionCImage': null,
      'optionDImage': null,
    };
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Question"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(labelText: "Question Text"),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              _buildImageUploadButton(
                label: "Question Image",
                imageUrl: qData['questionImage'],
                onUpload: (url) => setState(() => qData['questionImage'] = url),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: optACtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option A"),
              ),
              TextField(
                controller: optBCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option B"),
              ),
              TextField(
                controller: optCCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option C"),
              ),
              TextField(
                controller: optDCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: "Option D"),
              ),
              const SizedBox(height: 10),
              // Option Images
              _buildImageUploadButton(
                label: "Option A Image",
                imageUrl: qData['optionAImage'],
                onUpload: (url) => setState(() => qData['optionAImage'] = url),
              ),
              _buildImageUploadButton(
                label: "Option B Image",
                imageUrl: qData['optionBImage'],
                onUpload: (url) => setState(() => qData['optionBImage'] = url),
              ),
              _buildImageUploadButton(
                label: "Option C Image",
                imageUrl: qData['optionCImage'],
                onUpload: (url) => setState(() => qData['optionCImage'] = url),
              ),
              _buildImageUploadButton(
                label: "Option D Image",
                imageUrl: qData['optionDImage'],
                onUpload: (url) => setState(() => qData['optionDImage'] = url),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ansCtrl,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(labelText: "Correct Answer (A, B, C, D)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              bool qValid = qCtrl.text.isNotEmpty || qData['questionImage'] != null;
              bool optAValid = optACtrl.text.isNotEmpty || qData['optionAImage'] != null;
              bool optBValid = optBCtrl.text.isNotEmpty || qData['optionBImage'] != null;

              if (!qValid || !optAValid || !optBValid || ansCtrl.text.isEmpty) {
                CustomToast.showError(context, "Please fill basic fields (either text or image for Q, A, B).");
                return;
              }
              setState(() {
                _questions.add({
                  'questionText': qCtrl.text,
                  'questionImage': qData['questionImage'],
                  'options': [
                    {'key': 'A', 'text': optACtrl.text, 'image': qData['optionAImage']},
                    {'key': 'B', 'text': optBCtrl.text, 'image': qData['optionBImage']},
                    {'key': 'C', 'text': optCCtrl.text, 'image': qData['optionCImage']},
                    {'key': 'D', 'text': optDCtrl.text, 'image': qData['optionDImage']},
                  ],
                  'correctAnswer': ansCtrl.text.toUpperCase(),
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  String? _getOptionImage(Map<String, dynamic> q, String key) {
    if (q['options'] == null) return null;
    for (var opt in q['options']) {
      if (opt['key'] == key) return opt['image'];
    }
    return null;
  }

  void _setOptionImage(Map<String, dynamic> q, String key, String? url) {
    if (q['options'] == null) return;
    for (var opt in q['options']) {
      if (opt['key'] == key) opt['image'] = url;
    }
  }

  Widget _buildImageUploadButton({required String label, String? imageUrl, required Function(String?) onUpload}) {
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
              ),
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.network(imageUrl!, width: 40, height: 40, fit: BoxFit.cover),
                ),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = await _pickAndUploadImage();
                  if (url != null) {
                    setInternalState(() => imageUrl = url);
                    onUpload(url);
                  }
                },
                icon: const Icon(Icons.upload, size: 16),
                label: Text(imageUrl != null ? "Change" : "Upload", style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                ),
              ),
              if (imageUrl != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  onPressed: () {
                    setInternalState(() => imageUrl = null);
                    onUpload(null);
                  },
                )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Review Import (${_questions.length}/${widget.totalMarks})", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addQuestion,
            tooltip: "Add Question",
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExam,
            tooltip: "Save Exam",
          )
        ],
      ),
      body: ListView.builder(
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
                        if (q['questionImage'] != null && q['questionImage'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(q['questionImage'], height: 150, width: double.infinity, fit: BoxFit.contain),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Options
                        if (q['options'] != null)
                          ...List<dynamic>.from(q['options']).map((opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${opt['key']}) ${opt['text']}", 
                                  style: TextStyle(
                                    color: opt['key'] == q['correctAnswer'] ? Colors.green : Colors.black87,
                                    fontWeight: opt['key'] == q['correctAnswer'] ? FontWeight.bold : FontWeight.normal
                                  )
                                ),
                                if (opt['image'] != null && (opt['image'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, bottom: 8.0, top: 4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(opt['image'] as String, height: 100, fit: BoxFit.contain),
                                    ),
                                  ),
                              ],
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
