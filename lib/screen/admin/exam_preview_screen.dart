import 'dart:convert';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamPreviewScreen extends StatefulWidget {
  final String examId;

  const ExamPreviewScreen({super.key, required this.examId});

  @override
  State<ExamPreviewScreen> createState() => _ExamPreviewScreenState();
}

class _ExamPreviewScreenState extends State<ExamPreviewScreen> {
  Map<String, dynamic>? _examData;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for Header
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();
  final TextEditingController _mediumController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }
  
  @override 
  void dispose() {
    _subjectController.dispose();
    _stdController.dispose();
    _mediumController.dispose();
    _unitController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _fetchExamDetails() async {
    try {
      final response = await ApiService.getExamById(widget.examId);
      if (response.statusCode == 200) {
        if(!mounted) return;
        final data = jsonDecode(response.body);
        setState(() {
          _examData = data;
          _isLoading = false;
          
          // Init Controllers
          _subjectController.text = data['subject'] ?? "";
          _stdController.text = data['std'] ?? "";
          _mediumController.text = data['medium'] ?? "";
          _unitController.text = data['unit'] ?? "";
          _marksController.text = (data['totalMarks'] ?? 0).toString();
          
          _questions = data['questions'] ?? [];
        });
      } else {
        if(!mounted) return;
        CustomToast.showError(context, "Failed to load exam details");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if(!mounted) return;
      CustomToast.showError(context, "Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
     // setState(() => _isSaving = true);
     CustomLoader.show(context);
     
     try {
       final response = await ApiService.updateExam(
         id: widget.examId,
         subject: _subjectController.text,
         std: _stdController.text,
         medium: _mediumController.text,
         unit: _unitController.text,
         totalMarks: int.tryParse(_marksController.text) ?? 0,
         questions: _questions
       );
       
       if (!mounted) return;
       // setState(() => _isSaving = false);
       CustomLoader.hide(context);
       
       if (response.statusCode == 200) {
         CustomToast.showSuccess(context, "Exam Updated Successfully");
       } else {
         CustomToast.showError(context, "Update Failed: ${response.body}");
       }
     } catch (e) {
       if (mounted) CustomLoader.hide(context);
       CustomToast.showError(context, "Error: $e");
     }
  }

  void _editQuestion(int index) {
    final q = _questions[index];
    final TextEditingController qTextCtrl = TextEditingController(text: q['questionText']);
    final TextEditingController ansCtrl = TextEditingController(text: q['correctAnswer']);
    
    // We also need to edit options. 
    // Simplified: Show options as text inputs? Or just allow editing keys/text.
    // Let's iterate options and make controllers.
    List<dynamic> opts = List.from(q['options'] ?? []);
    List<TextEditingController> optCtrls = opts.map((o) => TextEditingController(text: o['text'])).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Question ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qTextCtrl,
                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(labelText: "Question Text", border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text("Options:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(opts.length, (i) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       children: [
                         Text("${opts[i]['key']}) ", style: const TextStyle(fontWeight: FontWeight.bold)),
                         Expanded(
                           child: TextField(
                             controller: optCtrls[i],
                             style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.normal),
                             decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                           ),
                         )
                       ],
                     ),
                   );
                }),
                 const SizedBox(height: 16),
                 TextField(
                  controller: ansCtrl,
                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(labelText: "Correct Answer (A/B/C/D)", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
               // Dispose local controllers? No need strictly for dialog, garbage collected
               Navigator.pop(ctx);
            }, 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
              // Update state
              setState(() {
                _questions[index]['questionText'] = qTextCtrl.text;
                _questions[index]['correctAnswer'] = ansCtrl.text.toUpperCase();
                for (int i=0; i<opts.length; i++) {
                   _questions[index]['options'][i]['text'] = optCtrls[i].text;
                }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Exam Preview", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
           IconButton(
             icon: const Icon(Icons.save),
             onPressed: _saveChanges,
             tooltip: "Save Changes",
           )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CustomLoader()) 
          : _examData == null 
              ? const Center(child: Text("Exam not found or failed to load"))
              : _buildExamContent(),
    );
  }

  Widget _buildExamContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Header Info (Editable)
           Card(
             elevation: 0,
             color: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 children: [
                    _buildEditableRow(Icons.book, "Subject", _subjectController),
                    const SizedBox(height: 12),
                    _buildEditableRow(Icons.school, "Standard", _stdController),
                    const SizedBox(height: 12),
                    _buildEditableRow(Icons.language, "Medium", _mediumController),
                    const SizedBox(height: 12),
                    _buildEditableRow(Icons.topic, "Unit", _unitController),
                    const SizedBox(height: 12),
                    _buildEditableRow(Icons.star, "Total Marks", _marksController, isNumber: true),
                 ],
               ),
             ),
           ),
           const SizedBox(height: 24),
           
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text("Questions (${_questions.length})", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
               // Add Question Button Could go here
             ],
           ),
           const SizedBox(height: 12),

           ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                               radius: 14,
                               backgroundColor: Colors.blue.shade50,
                               child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(q['questionText'] ?? "No Text", style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editQuestion(index),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Options
                        if (q['options'] != null)
                          ...List<dynamic>.from(q['options']).map((opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0, left: 40),
                            child: Text(
                              "${opt['key']}) ${opt['text']}", 
                              style: TextStyle(
                                color: opt['key'] == q['correctAnswer'] ? Colors.green.shade700 : Colors.black87,
                                fontWeight: opt['key'] == q['correctAnswer'] ? FontWeight.bold : FontWeight.normal
                              )
                            ),
                          )),
                         const SizedBox(height: 8),
                         Padding(
                           padding: const EdgeInsets.only(left: 40.0),
                           child: Text("Answer: ${q['correctAnswer']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                         ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String label, TextEditingController controller, {bool isNumber = false}) {
     return Row(
       children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
               controller: controller,
               keyboardType: isNumber ? TextInputType.number : TextInputType.text,
               decoration: InputDecoration(
                 labelText: label,
                 isDense: true,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
               ),
               style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
       ],
     );
  }
}
