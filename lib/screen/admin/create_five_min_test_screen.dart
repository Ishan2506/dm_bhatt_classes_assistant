import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class CreateFiveMinTestScreen extends StatefulWidget {
  final Map<String, dynamic>? testToEdit;
  const CreateFiveMinTestScreen({super.key, this.testToEdit});

  @override
  State<CreateFiveMinTestScreen> createState() => _CreateFiveMinTestScreenState();
}

class _CreateFiveMinTestScreenState extends State<CreateFiveMinTestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _unitController;
  late TextEditingController _overviewController;

  String? _selectedBoard;
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedSubject;
  final List<String> _streams = ["Science", "Commerce", "General"];

  // PDF Upload
  PlatformFile? _pickedPdf;
  bool _isLoading = false;

  // Questions Data
  late List<Map<String, dynamic>> _questions;
  int _currentStep = 0;
  bool _isManualEntry = false;
  String? _editingId;

  // History Filters & Data
  String? _selectedFilterBoard;
  String? _selectedFilterStandard;
  String? _selectedFilterMedium;
  String? _selectedFilterStream;
  List<dynamic> _allTests = [];

  bool get _isEditing => widget.testToEdit != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _unitController = TextEditingController(text: widget.testToEdit?['unit'] ?? "");
    _overviewController = TextEditingController(text: widget.testToEdit?['overview'] ?? "");
    
    if (_isEditing) {
      _editingId = widget.testToEdit?['_id'];
      _selectedBoard = widget.testToEdit?['board'];
      _selectedStandard = widget.testToEdit?['std'];
      _selectedMedium = widget.testToEdit?['medium'];
      _selectedStream = (widget.testToEdit?['stream'] == "" || widget.testToEdit?['stream'] == "-") ? null : widget.testToEdit?['stream'];
      _selectedSubject = widget.testToEdit?['subject'];
      
      if (widget.testToEdit?['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(
          (widget.testToEdit!['questions'] as List).map((q) => {
            "question": q['question'] ?? "",
            "questionImage": q['questionImage'],
            "type": q['type'] ?? "MCQ",
            "optionA": q['optionA'] ?? "",
            "optionAImage": q['optionAImage'],
            "optionB": q['optionB'] ?? "",
            "optionBImage": q['optionBImage'],
            "optionC": q['optionC'] ?? "",
            "optionCImage": q['optionCImage'],
            "optionD": q['optionD'] ?? "",
            "optionDImage": q['optionDImage'],
            "correctAnswer": q['correctAnswer'] ?? "",
          })
        );
      } else {
        _questions = List.generate(5, (index) => {
          "question": "", "questionImage": null, "type": "MCQ", "optionA": "", "optionAImage": null, "optionB": "", "optionBImage": null, "optionC": "", "optionCImage": null, "optionD": "", "optionDImage": null, "correctAnswer": "",
        });
      }
    } else {
      _questions = List.generate(5, (index) => {
        "question": "", "questionImage": null, "type": "MCQ", "optionA": "", "optionAImage": null, "optionB": "", "optionBImage": null, "optionC": "", "optionCImage": null, "optionD": "", "optionDImage": null, "correctAnswer": "",
      });
    }
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAllFiveMinTests();
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _allTests = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error fetching tests: $e");
    }
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _selectedBoard = null;
      _selectedStandard = null;
      _selectedMedium = null;
      _selectedStream = null;
      _selectedSubject = null;
      _unitController.clear();
      _overviewController.clear();
      _pickedPdf = null;
      _questions = List.generate(5, (index) => {
        "question": "", "questionImage": null, "type": "MCQ", "optionA": "", "optionAImage": null, "optionB": "", "optionBImage": null, "optionC": "", "optionCImage": null, "optionD": "", "optionDImage": null, "correctAnswer": "",
      });
      _currentStep = 0;
      _isManualEntry = false;
    });
  }

  void _editTest(Map<String, dynamic> test) {
    setState(() {
      _editingId = test['_id'];
      _selectedBoard = test['board'];
      _selectedStandard = test['std'];
      _selectedMedium = test['medium'];
      _selectedStream = (test['stream'] == "" || test['stream'] == "-") ? null : test['stream'];
      _selectedSubject = test['subject'];
      _unitController.text = test['unit'] ?? "";
      _overviewController.text = test['overview'] ?? "";
      
      if (test['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(
          (test['questions'] as List).map((q) => {
            "question": q['question'] ?? "",
            "questionImage": q['questionImage'],
            "type": q['type'] ?? "MCQ",
            "optionA": q['optionA'] ?? "",
            "optionAImage": q['optionAImage'],
            "optionB": q['optionB'] ?? "",
            "optionBImage": q['optionBImage'],
            "optionC": q['optionC'] ?? "",
            "optionCImage": q['optionCImage'],
            "optionD": q['optionD'] ?? "",
            "optionDImage": q['optionDImage'],
            "correctAnswer": q['correctAnswer'] ?? "",
          })
        );
      } else {
        _questions = List.generate(5, (index) => {
          "question": "", "questionImage": null, "type": "MCQ", "optionA": "", "optionAImage": null, "optionB": "", "optionBImage": null, "optionC": "", "optionCImage": null, "optionD": "", "optionDImage": null, "correctAnswer": "",
        });
      }
      _isManualEntry = true;
      _currentStep = 0;
    });
    _tabController.animateTo(0);
  }

  Future<void> _deleteTest(String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Test"),
        content: const Text("Are you sure you want to delete this test?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              CustomLoader.show(context);
              try {
                final response = await ApiService.deleteFiveMinTest(id);
                CustomLoader.hide(context);
                if (response.statusCode == 200) {
                  CustomToast.showSuccess(context, "Test Deleted Successfully");
                  _fetchTests();
                } else {
                  CustomToast.showError(context, "Failed to delete");
                }
              } catch (e) {
                CustomLoader.hide(context);
                CustomToast.showError(context, "Error: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
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

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result != null) {
        setState(() {
          _pickedPdf = result.files.single;
        });
        _uploadAndProcessPdf();
      }
    } catch (e) {
      CustomToast.showError(context, "Error picking PDF: $e");
    }
  }

  Future<void> _uploadAndProcessPdf() async {
    if (_pickedPdf == null) return;

    CustomLoader.show(context);
    try {
      List<int> fileBytes;
      if (kIsWeb) {
        fileBytes = _pickedPdf!.bytes!;
      } else {
        fileBytes = await File(_pickedPdf!.path!).readAsBytes();
      }

      final response = await ApiService.uploadFiveMinTestPdf(
        bytes: fileBytes,
        filename: _pickedPdf!.name,
      );

      CustomLoader.hide(context);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final overview = body['overview'] as String? ?? "";
        final questions = body['questions'] as List? ?? [];

        if (mounted) {
          setState(() {
            if (overview.isNotEmpty) {
              _overviewController.text = overview;
            }

            if (questions.isNotEmpty) {
              final List<Map<String, dynamic>> parsedQuestions = [];
              for (var i = 0; i < 5 && i < questions.length; i++) {
                final q = questions[i];
                String ans = q['correctAnswer'] ?? "";
                if (q['type'] == 'True/False') {
                  if (ans == 'A' || ans == 'Option A') ans = 'True';
                  else if (ans == 'B' || ans == 'Option B') ans = 'False';
                }
                
                parsedQuestions.add({
                  "question": q['questionText'] ?? "",
                  "questionImage": null,
                  "type": q['type'] ?? "MCQ", 
                  "optionA": q['options'] != null && (q['options'] as List).isNotEmpty ? q['options'][0]['text'] : "",
                  "optionAImage": null,
                  "optionB": q['options'] != null && (q['options'] as List).length > 1 ? q['options'][1]['text'] : "",
                  "optionBImage": null,
                  "optionC": q['options'] != null && (q['options'] as List).length > 2 ? q['options'][2]['text'] : "",
                  "optionCImage": null,
                  "optionD": q['options'] != null && (q['options'] as List).length > 3 ? q['options'][3]['text'] : "",
                  "optionDImage": null,
                  "correctAnswer": ans,
                });
              }
              
              while(parsedQuestions.length < 5) {
                parsedQuestions.add({
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
              _questions = parsedQuestions;
            }
            _isManualEntry = true; // Switch to manual to show the result
            _currentStep = 1; // Ensure we are on the question step
          });
          CustomToast.showSuccess(context, "PDF processed successfully. Review data below.");
        }
      } else {
        CustomToast.showError(context, "PDF processing failed: ${response.body}");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      CustomToast.showError(context, "Error processing PDF: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _unitController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  Future<void> _submitTest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBoard == null || _selectedStandard == null || _selectedMedium == null || _selectedSubject == null) {
        CustomToast.showError(context, "Please select board, standard, medium and subject");
        return;
      }
      
      for (int i = 0; i < 5; i++) {
        bool qValid = _questions[i]['question'].isNotEmpty || _questions[i]['questionImage'] != null;
        if (!qValid) {
           CustomToast.showError(context, "Please enter text or image for Question ${i + 1}");
           return;
        }
        if (_questions[i]['correctAnswer'].isEmpty) {
           CustomToast.showError(context, "Please select correct answer for Question ${i + 1}");
           return;
        }
      }

      CustomLoader.show(context);
      try {
        final response = (_isEditing || _editingId != null) 
          ? await ApiService.updateFiveMinTest(
              id: _editingId ?? widget.testToEdit!['_id'],
              board: _selectedBoard!,
              std: _selectedStandard!,
              medium: _selectedMedium!,
              stream: _selectedStream,
              subject: _selectedSubject!,
              unit: _unitController.text,
              overview: _overviewController.text,
              questions: _questions,
            )
          : await ApiService.createFiveMinTest(
              board: _selectedBoard!,
              std: _selectedStandard!,
              medium: _selectedMedium!,
              stream: _selectedStream,
              subject: _selectedSubject!,
              unit: _unitController.text,
              overview: _overviewController.text,
              questions: _questions,
            );

        CustomLoader.hide(context);

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, (_isEditing || _editingId != null) ? "Test Updated Successfully!" : "5 Min Test Created Successfully!");
          _fetchTests();
          if (_editingId != null) {
            _resetForm();
            _tabController.animateTo(1); // Go back to history
          } else {
            Navigator.pop(context);
          }
        } else {
          CustomToast.showError(context, "Operation failed: ${response.body}");
        }
      } catch (e) {
        CustomLoader.hide(context);
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _isEditing ? "Edit 5 Min Test" : "Manage 5 Min Test",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Create New"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Create New (Stepper)
            _isLoading && _allTests.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep == 0) {
                    if (_selectedBoard != null && _selectedStandard != null && _selectedMedium != null && _selectedSubject != null && _unitController.text.isNotEmpty) {
                       if ((_selectedStandard == "11" || _selectedStandard == "12") && _selectedStream == null) {
                          CustomToast.showError(context, "Please select a Stream");
                          return;
                      }
                      setState(() => _currentStep++);
                    } else {
                      CustomToast.showError(context, "Please enter all basic details");
                    }
                  } else if (_currentStep == 1) {
                     if (_isManualEntry) {
                        _submitTest();
                     } else {
                        if (_pickedPdf != null) {
                          _uploadAndProcessPdf();
                        } else {
                          CustomToast.showError(context, "Please upload a PDF first");
                        }
                     }
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: const Size(120, 45),
                          ),
                          child: _isLoading 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : Text(
                                 _currentStep == 1 
                                   ? (_isManualEntry ? (_isEditing ? "Update Test" : "Create Test") : "Process PDF") 
                                   : "Continue", 
                                 style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                               ),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text("Back", style: GoogleFonts.poppins(color: Colors.grey)),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: Text("Basic Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    isActive: _currentStep >= 0,
                    content: Column(
                      children: [
                         // Board Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedBoard,
                          items: AcademicConstants.boards.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() {
                            _selectedBoard = val;
                            _selectedStandard = null;
                            _selectedSubject = null;
                          }),
                          decoration: _inputDecoration("Board", Icons.school),
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
      
                        // Standard Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedStandard,
                          items: (_selectedBoard == null ? <String>[] : AcademicConstants.standards[_selectedBoard!] ?? <String>[]).map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() {
                            _selectedStandard = val;
                            _selectedSubject = null;
                          }),
                          decoration: _inputDecoration("Standard", Icons.class_outlined),
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
      
                        // Medium Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedMedium,
                          items: AcademicConstants.mediums.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedMedium = val),
                          decoration: _inputDecoration("Medium", Icons.language),
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stream Dropdown
                        if (_selectedStandard != null && (_selectedStandard!.startsWith("11") || _selectedStandard!.startsWith("12"))) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedStream,
                            items: _streams.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedStream = val),
                            decoration: _inputDecoration("Stream", Icons.science_outlined),
                            style: GoogleFonts.poppins(color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                        ],
      
                        // Subject Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          items: (_selectedBoard == null || _selectedStandard == null ? <String>[] : AcademicConstants.subjects["$_selectedBoard-$_selectedStandard"] ?? <String>[]).map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
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
                      ],
                    ),
                  ),
                  Step(
                    title: Text("Questions Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    isActive: _currentStep >= 1,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                         // Toggle
                         Row(
                           children: [
                             Expanded(
                               child: RadioListTile<bool>(
                                 title: Text("Upload PDF", style: GoogleFonts.poppins(fontSize: 14)),
                                 value: false, 
                                 groupValue: _isManualEntry, 
                                 contentPadding: EdgeInsets.zero,
                                 onChanged: (val) => setState(() => _isManualEntry = val!),
                               ),
                             ),
                             Expanded(
                               child: RadioListTile<bool>(
                                 title: Text("Manual Entry", style: GoogleFonts.poppins(fontSize: 14)),
                                 value: true, 
                                 groupValue: _isManualEntry, 
                                 contentPadding: EdgeInsets.zero,
                                 onChanged: (val) => setState(() => _isManualEntry = val!),
                               ),
                             ),
                           ],
                         ),
                         
                         const SizedBox(height: 16),
      
                         if (!_isManualEntry) ...[
                           Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(24),
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey.shade300),
                               borderRadius: BorderRadius.circular(12),
                               color: Colors.grey.shade50,
                             ),
                             child: Column(
                               children: [
                                 Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade300),
                                 const SizedBox(height: 16),
                                 ElevatedButton(
                                   onPressed: _pickPdf,
                                   child: Text(_pickedPdf != null ? "Change PDF" : "Select PDF"),
                                 ),
                                 if (_pickedPdf != null) ...[
                                   const SizedBox(height: 12),
                                   Text("Selected: ${_pickedPdf!.name}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                 ]
                               ],
                             ),
                           ),
                           const SizedBox(height: 12),
                           const Text("The PDF should contain an 'Overview' section and 'True/False' questions.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                         ] else ...[
                            // Manual Entry Content
                            TextFormField(
                              controller: _overviewController,
                              decoration: _inputDecoration("Chapter Overview / Study Material", Icons.article).copyWith(
                                alignLabelWithHint: true,
                              ),
                              maxLines: 6,
                              validator: (v) => v!.isEmpty ? "Required" : null,
                              style: GoogleFonts.poppins(),
                            ),
                            const SizedBox(height: 24),
      
                            _buildHeader("Questions (5)"),
                            const SizedBox(height: 16),
      
                            ...List.generate(5, (index) => _buildQuestionBlock(index)),
                         ]
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final filtered = _allTests.where((test) {
      final matchBoard = _selectedFilterBoard == null || test['board'] == _selectedFilterBoard;
      final matchStd = _selectedFilterStandard == null || test['std'] == _selectedFilterStandard;
      final matchMedium = _selectedFilterMedium == null || test['medium'] == _selectedFilterMedium;
      final matchStream = _selectedFilterStream == null || test['stream'] == _selectedFilterStream;
      return matchBoard && matchStd && matchMedium && matchStream;
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
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown("Board", _selectedFilterBoard, AcademicConstants.boards, (val) => setState(() {
                      _selectedFilterBoard = val;
                      _selectedFilterStandard = null;
                    })),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown("Std", _selectedFilterStandard, _selectedFilterBoard == null ? <String>[] : AcademicConstants.standards[_selectedFilterBoard!] ?? <String>[], (val) => setState(() => _selectedFilterStandard = val)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown("Medium", _selectedFilterMedium, AcademicConstants.mediums, (val) => setState(() => _selectedFilterMedium = val)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown("Stream", _selectedFilterStream, _streams, (val) => setState(() => _selectedFilterStream = val)),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(_isLoading ? "Loading..." : "No tests found", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final test = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: Colors.grey.shade50,
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
                            "Std: ${test['std']} | ${test['medium']} ${test['stream'] != null && test['stream'] != "" ? "| ${test['stream']}" : ""}",
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

  Widget _buildFilterDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
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
                items: ["MCQ", "True/False", "Fill in the Blanks"].map((t) => DropdownMenuItem<String>(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
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
            controller: TextEditingController(text: _questions[index]['question'])..selection = TextSelection.fromPosition(TextPosition(offset: _questions[index]['question'].length)),
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
                value: (_questions[index]['correctAnswer'].startsWith('Option ') || ['Option A', 'Option B', 'Option C', 'Option D'].contains(_questions[index]['correctAnswer'])) ? _questions[index]['correctAnswer'] : null,
                decoration: _inputDecoration("Correct Option", Icons.check_circle_outline),
                items: ['Option A', 'Option B', 'Option C', 'Option D']
                    .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
                    .toList(),
                onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
             ),
          ] else if (_questions[index]['type'] == 'True/False') ...[
             // True/False Options
             const SizedBox(height: 8),
             Text("Correct Answer:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
             Row(
               children: [
                 Expanded(
                   child: RadioListTile<String>(
                     title: Text("True", style: GoogleFonts.poppins()),
                     value: "True", // A corresponds to True in the PDF format
                     groupValue: _questions[index]['correctAnswer'],
                     activeColor: Colors.blue.shade900,
                     onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
                   ),
                 ),
                 Expanded(
                   child: RadioListTile<String>(
                     title: Text("False", style: GoogleFonts.poppins()),
                     value: "False", // B corresponds to False
                     groupValue: _questions[index]['correctAnswer'],
                     activeColor: Colors.blue.shade900,
                     onChanged: (val) => setState(() => _questions[index]['correctAnswer'] = val),
                   ),
                 ),
               ],
             )
          ] else ...[
            // Fill in the Blanks
             const SizedBox(height: 8),
             TextFormField(
                controller: TextEditingController(text: _questions[index]['correctAnswer'])..selection = TextSelection.fromPosition(TextPosition(offset: _questions[index]['correctAnswer'].length)),
                decoration: _inputDecoration("Correct Answer", Icons.done_all),
                onChanged: (val) => _questions[index]['correctAnswer'] = val,
                style: GoogleFonts.poppins(),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildOptionField(int index, String key, String label) {
    String currentText = _questions[index][key] ?? "";
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          TextFormField(
            controller: TextEditingController(text: currentText)..selection = TextSelection.fromPosition(TextPosition(offset: currentText.length)),
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
              if (imageUrl != null && imageUrl!.isNotEmpty)
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
