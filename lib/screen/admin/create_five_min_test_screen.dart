import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        "type": "MCQ", 
        "optionA": "Op A",
        "optionB": "Op B",
        "optionC": "Op C",
        "optionD": "Op D",
        "correctAnswer": "Option A",
      });
    } else {
      _questions = List.generate(5, (index) => {
        "question": "",
        "type": "MCQ", 
        "optionA": "",
        "optionB": "",
        "optionC": "",
        "optionD": "",
        "correctAnswer": "",
      });
    }
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
        if (_questions[i]['question'].isEmpty) {
           CustomToast.showError(context, "Please enter Question ${i + 1}");
           return;
        }
        if (_questions[i]['type'] == 'MCQ') {
           if (_questions[i]['optionA'].isEmpty || _questions[i]['optionB'].isEmpty) {
              CustomToast.showError(context, "Please enter at least Option A and B for Question ${i + 1}");
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
      child: TextFormField(
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
