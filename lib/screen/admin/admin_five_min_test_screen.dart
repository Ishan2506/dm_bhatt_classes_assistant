import 'dart:convert';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminFiveMinTestScreen extends StatefulWidget {
  const AdminFiveMinTestScreen({super.key});

  @override
  State<AdminFiveMinTestScreen> createState() => _AdminFiveMinTestScreenState();
}

class _AdminFiveMinTestScreenState extends State<AdminFiveMinTestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // --- Form Controllers & State ---
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  
  String? _selectedCreateSubject;
  String? _selectedCreateStd;
  String? _selectedCreateMedium;
  String? _selectedCreateStream;

  bool _isEditing = false;
  String? _editingId;
  bool _isLoading = false;

  // Questions Data for Form
  List<Map<String, dynamic>> _questions = [];

  // --- History Filters & Data ---
  String? _selectedFilterStandard;
  String? _selectedFilterMedium;
  String? _selectedFilterStream;

  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];
  final List<String> _subjects = ['Math', 'Science', 'English', 'Account', 'Statistics', 'Economics', 'BA'];

  List<dynamic> _allTests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _resetForm(); // Initialize questions
    _fetchTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _unitController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchTests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAllFiveMinTests();
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _allTests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Error fetching tests: $e");
    }
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingId = null;
      _selectedCreateSubject = null;
      _selectedCreateStd = null;
      _selectedCreateMedium = null;
      _selectedCreateStream = null;
      _unitController.clear();
      _overviewController.clear();
      _questions = List.generate(5, (index) => {
        "question": "",
        "type": "MCQ", 
        "optionA": "",
        "optionB": "",
        "optionC": "",
        "optionD": "",
        "correctAnswer": "",
      });
    });
  }

  void _editTest(Map<String, dynamic> test) {
    setState(() {
      _isEditing = true;
      _editingId = test['_id']; // MongoDB ID
      _selectedCreateSubject = test['subject'];
      _selectedCreateStd = test['std'];
      _selectedCreateMedium = test['medium'];
      _selectedCreateStream = (test['stream'] == "" || test['stream'] == "-") ? null : test['stream'];
      _unitController.text = test['unit'] ?? "";
      _overviewController.text = test['overview'] ?? "";
      
      // Load questions
      if (test['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(
          (test['questions'] as List).map((q) => {
            "question": q['question'] ?? "",
            "type": q['type'] ?? "MCQ",
            "optionA": q['optionA'] ?? "",
            "optionB": q['optionB'] ?? "",
            "optionC": q['optionC'] ?? "",
            "optionD": q['optionD'] ?? "",
            "correctAnswer": q['correctAnswer'] ?? "",
          })
        );
        // Ensure strictly 5 questions if needed, or adjust UI to be dynamic
        // The UI assumes 5, so let's pad or truncate if necessary, 
        // but typically we save 5 so we get 5.
        if (_questions.length < 5) {
          _questions.addAll(List.generate(5 - _questions.length, (i) => {
             "question": "", "type": "MCQ", "optionA": "", "optionB": "", "optionC": "", "optionD": "", "correctAnswer": ""
          }));
        }
      } else {
        _questions = List.generate(5, (index) => {
           "question": "", "type": "MCQ", "optionA": "", "optionB": "", "optionC": "", "optionD": "", "correctAnswer": ""
        });
      }
    });
    _tabController.animateTo(0);
  }

  Future<void> _submitTest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCreateStd == null || _selectedCreateMedium == null) {
        CustomToast.showError(context, "Please select Standard and Medium");
        return;
      }
      if (_selectedCreateSubject == null) {
        CustomToast.showError(context, "Please select a subject");
        return;
      }
      
      // Validation
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

      // setState(() => _isLoading = true);
      CustomLoader.show(context);

      try {
        if (_isEditing) {
           final response = await ApiService.updateFiveMinTest(
             id: _editingId!,
             std: _selectedCreateStd!,
             medium: _selectedCreateMedium!,
             stream: _selectedCreateStream,
             subject: _selectedCreateSubject!,
             unit: _unitController.text,
             overview: _overviewController.text,
             questions: _questions
           );
           
           if (!mounted) return;
           CustomLoader.hide(context);

           if (response.statusCode == 200) {
             CustomToast.showSuccess(context, "Test Updated Successfully!");
             _fetchTests();
             _resetForm();
           } else {
             CustomToast.showError(context, "Failed: ${response.body}");
           }
        } else {
           final response = await ApiService.createFiveMinTest(
             std: _selectedCreateStd!,
             medium: _selectedCreateMedium!,
             stream: _selectedCreateStream,
             subject: _selectedCreateSubject!,
             unit: _unitController.text,
             overview: _overviewController.text,
             questions: _questions
           );

           if (!mounted) return;
           CustomLoader.hide(context);

           if (response.statusCode == 201) {
             CustomToast.showSuccess(context, "5 Min Test Created Successfully!");
             _fetchTests();
             _resetForm();
           } else {
             CustomToast.showError(context, "Failed: ${response.body}");
           }
        }
      } catch (e) {
        if (mounted) {
           CustomLoader.hide(context);
           CustomToast.showError(context, "Error: $e");
        }
      }
    }
  }

   Future<void> _deleteTest(String id) async {
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
            onPressed: () async {
              Navigator.pop(ctx);
              // setState(() => _isLoading = true);
              CustomLoader.show(context);
              try {
                final response = await ApiService.deleteFiveMinTest(id);
                if (!mounted) return;
                CustomLoader.hide(context);
                if (response.statusCode == 200) {
                  CustomToast.showSuccess(context, "Test Deleted Successfully");
                  _fetchTests();
                } else {
                  CustomToast.showError(context, "Failed to delete");
                }
              } catch (e) {
                if (mounted) CustomLoader.hide(context);
                CustomToast.showError(context, "Error: $e");
              }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Manage 5 Min Test",
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Create New"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CustomLoader()) 
        : TabBarView(
            controller: _tabController,
            children: [
              _buildCreateTab(),
              _buildHistoryTab(),
            ],
          ),
    );
  }

  // --- Tab 1: Create Form ---
  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             if (_isEditing)
               Padding(
                 padding: const EdgeInsets.only(bottom: 16),
                 child: Row(
                   children: [
                     const Icon(Icons.edit, color: Colors.amber, size: 20),
                     const SizedBox(width: 8),
                     Text("Editing Test Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                     const Spacer(),
                     TextButton(
                       onPressed: _resetForm,
                       child: Text("Cancel Edit", style: GoogleFonts.poppins(color: Colors.red)),
                     )
                   ],
                 ),
               ),

            _buildHeader("Test Details"),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCreateStd,
                    items: _standards.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedCreateStd = val),
                    decoration: _inputDecoration("Standard", Icons.class_),
                    style: GoogleFonts.poppins(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCreateMedium,
                    items: _mediums.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedCreateMedium = val),
                    decoration: _inputDecoration("Medium", Icons.language),
                    style: GoogleFonts.poppins(color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_selectedCreateStd == "11" || _selectedCreateStd == "12") ...[
              DropdownButtonFormField<String>(
                value: _selectedCreateStream,
                items: _streams.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedCreateStream = val),
                 decoration: _inputDecoration("Stream", Icons.category),
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
            
            DropdownButtonFormField<String>(
              value: _selectedCreateSubject,
              items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedCreateSubject = val),
              decoration: _inputDecoration("Subject", Icons.subject),
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _unitController,
              decoration: _inputDecoration("Unit / Chapter Name", Icons.book),
              validator: (v) => v!.isEmpty ? "Required" : null,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _overviewController,
              decoration: _inputDecoration("Chapter Overview / Study Material", Icons.article).copyWith(
                alignLabelWithHint: true,
              ),
              maxLines: 6,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Tab 2: History List ---
  Widget _buildHistoryTab() {
    final filtered = _allTests.where((test) {
      final matchStd = _selectedFilterStandard == null || test['std'] == _selectedFilterStandard;
      final matchMedium = _selectedFilterMedium == null || test['medium'] == _selectedFilterMedium;
      final matchStream = _selectedFilterStream == null || test['stream'] == _selectedFilterStream;
      return matchStd && matchMedium && matchStream;
    }).toList();

    return Column(
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
                    child: _buildDropdown("Standard", _selectedFilterStandard, _standards, (val) => setState(() => _selectedFilterStandard = val)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown("Medium", _selectedFilterMedium, _mediums, (val) => setState(() => _selectedFilterMedium = val)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown("Stream", _selectedFilterStream, _streams, (val) => setState(() => _selectedFilterStream = val)),
            ],
          ),
        ),
        
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text("No tests found", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final test = filtered[index];
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
                              onPressed: () => _editTest(test),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTest(test['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

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
                     _questions[index]['correctAnswer'] = ""; 
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            initialValue: _questions[index]['question'], 
            key: Key('q_${index}_${_questions[index]['question']}'), // Ensure rebuilds correctly if state changes externally
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
        key: Key('opt_${index}_${key}_${_questions[index][key]}'),
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
