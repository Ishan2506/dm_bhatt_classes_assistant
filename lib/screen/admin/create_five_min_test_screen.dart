import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';

class CreateFiveMinTestScreen extends StatefulWidget {
  final Map<String, dynamic>? testToEdit;
  const CreateFiveMinTestScreen({super.key, this.testToEdit});

  @override
  State<CreateFiveMinTestScreen> createState() => _CreateFiveMinTestScreenState();
}

class _CreateFiveMinTestScreenState extends State<CreateFiveMinTestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _unitController;
  late TextEditingController _overviewController;

  String? _selectedSubject;
  final List<String> _subjects = ['Math', 'Science', 'English', 'Account', 'Statistics', 'Economics', 'BA'];

  // Questions Data
  late List<Map<String, dynamic>> _questions;

  bool get _isEditing => widget.testToEdit != null;

  @override
  void initState() {
    super.initState();
    _unitController = TextEditingController(text: widget.testToEdit?['unit'] ?? "");
    _overviewController = TextEditingController(text: _isEditing ? "Mock Overview Content..." : "");
    
    if (_isEditing) {
      _selectedSubject = widget.testToEdit?['subject'];
      // Mock questions or use passed data if structure matched
      _questions = List.generate(5, (index) => {
        "question": "Mock Question ${index + 1}",
        "questionImage": null,
        "type": "MCQ", 
        "optionA": "Op A",
        "optionAImage": null,
        "optionB": "Op B",
        "optionBImage": null,
        "optionC": "Op C",
        "optionCImage": null,
        "optionD": "Op D",
        "optionDImage": null,
        "correctAnswer": "Option A",
      });
    } else {
      _questions = List.generate(5, (index) => {
        "question": "",
        "questionImage": null,
        "type": "MCQ", 
        "optionA": "",
        "optionAImage": null,
        "optionB": "",
        "optionBImage": null,
        "optionC": "",
        "optionCImage": null,
        "optionD": "",
        "optionDImage": null,
        "correctAnswer": "",
      });
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

  @override
  void dispose() {
    _unitController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  void _submitTest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        CustomToast.showError(context, "Please select a subject");
        return;
      }
      
      // Basic validation for questions
      for (int i = 0; i < 5; i++) {
        bool qValid = _questions[i]['question'].isNotEmpty || _questions[i]['questionImage'] != null;
        if (!qValid) {
           CustomToast.showError(context, "Please enter text or image for Question ${i + 1}");
           return;
        }
        if (_questions[i]['type'] == 'MCQ') {
           bool optAValid = _questions[i]['optionA'].isNotEmpty || _questions[i]['optionAImage'] != null;
           bool optBValid = _questions[i]['optionB'].isNotEmpty || _questions[i]['optionBImage'] != null;
           if (!optAValid || !optBValid) {
              CustomToast.showError(context, "Please enter text or image for at least Option A and B for Question ${i + 1}");
              return;
           }
        }
        if (_questions[i]['correctAnswer'].isEmpty) {
           CustomToast.showError(context, "Please select correct answer for Question ${i + 1}");
           return;
        }
      }

      // Mock Save
      if (_isEditing) {
        CustomToast.showSuccess(context, "Test Updated Successfully!");
      } else {
        CustomToast.showSuccess(context, "5 Min Test Created Successfully!");
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit 5 Min Test" : "Create 5 Min Test",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader("Test Details"),
              const SizedBox(height: 16),
              
              // Subject Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSubject = val),
                decoration: _inputDecoration("Subject", Icons.subject),
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // Unit Name
              TextFormField(
                controller: _unitController,
                decoration: _inputDecoration("Unit / Chapter Name", Icons.book),
                validator: (v) => v!.isEmpty ? "Required" : null,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),

              // Overview
              TextFormField(
                controller: _overviewController,
                decoration: _inputDecoration("Chapter Overview / Study Material", Icons.article).copyWith(
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (v) => v!.isEmpty ? "Required" : null,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 32),

              _buildHeader("Questions (5)"),
              const SizedBox(height: 16),

              ...List.generate(5, (index) => _buildQuestionBlock(index)),

              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: Text(
                    _isEditing ? "Update Test" : "Create Test",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBlock(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue.shade100,
                child: Text("${index + 1}", style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text("Question ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              // Type Selector
              DropdownButton<String>(
                value: _questions[index]['type'],
                underline: Container(),
                items: ["MCQ", "True/False"].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
                onChanged: (val) {
                  setState(() {
                    _questions[index]['type'] = val;
                     _questions[index]['correctAnswer'] = ""; // Reset answer on type change
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            initialValue: _questions[index]['question'],
            decoration: _inputDecoration("Enter Question", Icons.help_outline),
            onChanged: (val) => _questions[index]['question'] = val,
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 8),
          _buildImageUploadButton(
            label: "Question Image",
            imageUrl: _questions[index]['questionImage'],
            onUpload: (url) => setState(() => _questions[index]['questionImage'] = url),
          ),
          const SizedBox(height: 12),

          if (_questions[index]['type'] == 'MCQ') ...[
             _buildOptionField(index, 'optionA', 'A'),
             _buildOptionField(index, 'optionB', 'B'),
             _buildOptionField(index, 'optionC', 'C'),
             _buildOptionField(index, 'optionD', 'D'),
             const SizedBox(height: 12),
             DropdownButtonFormField<String>(
                value: _questions[index]['correctAnswer'].isEmpty ? null : _questions[index]['correctAnswer'],
                decoration: _inputDecoration("Correct Option", Icons.check_circle_outline),
                items: ['Option A', 'Option B', 'Option C', 'Option D']
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
             ),
          ] else ...[
             // True/False Options (Fixed)
             const SizedBox(height: 8),
             Text("Correct Answer:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
             Row(
               children: [
                 Expanded(
                   child: RadioListTile<String>(
                     title: Text("True", style: GoogleFonts.poppins()),
                     value: "True",
                     groupValue: _questions[index]['correctAnswer'],
                     activeColor: Colors.blue.shade900,
                     onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
                   ),
                 ),
                 Expanded(
                   child: RadioListTile<String>(
                     title: Text("False", style: GoogleFonts.poppins()),
                     value: "False",
                     groupValue: _questions[index]['correctAnswer'],
                     activeColor: Colors.blue.shade900,
                     onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
                   ),
                 ),
               ],
             )
          ]
        ],
      ),
    );
  }

  Widget _buildOptionField(int index, String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _questions[index][key],
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              hintText: "Option $label",
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (val) => _questions[index][key] = val,
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 4),
          _buildImageUploadButton(
            label: "Option $label Image",
            imageUrl: _questions[index]['${key}Image'],
            onUpload: (url) => setState(() => _questions[index]['${key}Image'] = url),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton({required String label, String? imageUrl, required Function(String?) onUpload}) {
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
              ),
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(imageUrl!, width: 30, height: 30, fit: BoxFit.cover),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = await _pickAndUploadImage();
                  if (url != null) {
                    setInternalState(() => imageUrl = url);
                    onUpload(url);
                  }
                },
                icon: const Icon(Icons.upload, size: 14),
                label: Text(imageUrl != null ? "Change" : "Upload", style: const TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (imageUrl != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 14, color: Colors.red),
                  onPressed: () {
                    setInternalState(() => imageUrl = null);
                    onUpload(null);
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 4),
                )
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade900),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
