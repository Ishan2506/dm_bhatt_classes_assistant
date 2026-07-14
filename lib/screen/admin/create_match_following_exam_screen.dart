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

class CreateMatchFollowingExamScreen extends StatefulWidget {
  final Map<String, dynamic>? testToEdit;
  const CreateMatchFollowingExamScreen({super.key, this.testToEdit});

  @override
  State<CreateMatchFollowingExamScreen> createState() => _CreateMatchFollowingExamScreenState();
}

class _CreateMatchFollowingExamScreenState extends State<CreateMatchFollowingExamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _orderIndexController;
  late TextEditingController _unitController;
  late TextEditingController _overviewController;

  String? _selectedBoard;
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedSubject;
  String? _selectedMarks;
  final List<String> _streams = ["Science", "Commerce"];

  // PDF Upload
  PlatformFile? _pickedPdf;
  bool _isLoading = false;

  // Pairs Data
  late List<Map<String, dynamic>> _pairs;
  int _currentStep = 0;
  bool _isManualEntry = true;
  String? _editingId;

  // History Filters & Data
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterBoard;
  String? _selectedFilterStandard;
  String? _selectedFilterMedium;
  String? _selectedFilterStream;
  String? _selectedFilterSubject;
  List<dynamic> _allTests = [];

  bool get _isEditing => widget.testToEdit != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _titleController = TextEditingController(text: widget.testToEdit?['title'] ?? "");
    _orderIndexController = TextEditingController(text: (widget.testToEdit?['orderIndex'] ?? 1).toString());
    _unitController = TextEditingController(text: widget.testToEdit?['unit'] ?? "");
    _overviewController = TextEditingController(text: widget.testToEdit?['overview'] ?? "");
    
    if (_isEditing) {
      _editingId = widget.testToEdit?['_id'];
      _selectedBoard = widget.testToEdit?['board'];
      _selectedStandard = widget.testToEdit?['std'];
      _selectedMedium = widget.testToEdit?['medium'];
      _selectedStream = (widget.testToEdit?['stream'] == "" || widget.testToEdit?['stream'] == "-") ? null : widget.testToEdit?['stream'];
      _selectedSubject = widget.testToEdit?['subject'];
      _selectedMarks = widget.testToEdit?['totalMarks']?.toString();
      
      if (widget.testToEdit?['pairs'] != null) {
        _pairs = List<Map<String, dynamic>>.from(
          (widget.testToEdit!['pairs'] as List).map((q) => {
            "left": q["left"] ?? "",
            "right": q["right"] ?? ""
          })
        );
      }
    } else {
      _pairs = List.generate(int.tryParse(_selectedMarks ?? "20") ?? 20, (index) => {
        "left": "",
        "right": ""
      });
    }
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAllMatchFollowingExams();
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
      _selectedMarks = null;
      _titleController.clear();
      _unitController.clear();
      _overviewController.clear();
      _pickedPdf = null;
      _pairs = List.generate(int.tryParse(_selectedMarks ?? "20") ?? 20, (index) => {
        "left": "", "right": ""});
      _currentStep = 0;
      _isManualEntry = true;
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
      _selectedMarks = test['totalMarks']?.toString();
      _titleController.text = test['title'] ?? "";
      _unitController.text = test['unit'] ?? "";
      _overviewController.text = test['overview'] ?? "";
      
      if (test['pairs'] != null) {
        _pairs = List<Map<String, dynamic>>.from(
          (test['pairs'] as List).map((q) => {
            "left": q["left"] ?? "",
            "right": q["right"] ?? ""
          })
        );
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
                final response = await ApiService.deleteMatchFollowingExam(id);
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

      final response = await ApiService.uploadTrueFalseExamPdf(
        bytes: fileBytes,
        filename: _pickedPdf!.name,
      );

      CustomLoader.hide(context);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final overview = body['overview'] as String? ?? "";
        final questions = body['pairs'] as List? ?? [];

        if (mounted) {
          setState(() {
            if (overview.isNotEmpty) {
              _overviewController.text = overview;
            }

            if (questions.isNotEmpty) {
              final List<Map<String, dynamic>> parsedPairs = [];
              final int marks = int.tryParse(_selectedMarks ?? "20") ?? 20;
              for (var i = 0; i < marks && i < questions.length; i++) {
                final q = questions[i];
                String ans = q['right'] ?? "";
                if (q['type'] == 'Match Following') {
                  if (ans == 'A' || ans == 'Option A') ans = 'True';
                  else if (ans == 'B' || ans == 'Option B') ans = 'False';
                }
                
                parsedPairs.add({
                  "left": "", "right": ""});
              }
              _pairs = parsedPairs;
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
    _titleController.dispose();
    _orderIndexController.dispose();
    _unitController.dispose();
    _overviewController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitTest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBoard == null || _selectedStandard == null || _selectedMedium == null || _selectedSubject == null) {
        CustomToast.showError(context, "Please select board, standard, medium and subject");
        return;
      }
      
      for (int i = 0; i < _pairs.length; i++) {
        bool qValid = _pairs[i]['left'].isNotEmpty;
        if (!qValid) {
           CustomToast.showError(context, "Please enter left item for Pair ${i + 1}");
           return;
        }
        if (_pairs[i]['right'].isEmpty) {
           CustomToast.showError(context, "Please enter right item for Pair ${i + 1}");
           return;
        }
      }

      CustomLoader.show(context);
      try {
        final List<Map<String, dynamic>> finalPairs = _pairs.map((q) {
          final newQ = Map<String, dynamic>.from(q);
          return newQ;
        }).toList();

        final response = (_isEditing || _editingId != null) 
          ? await ApiService.updateMatchFollowingExam(
              _editingId ?? widget.testToEdit!['_id'],
              {
                "title": _titleController.text,
                "board": _selectedBoard,
                "std": _selectedStandard,
                "medium": _selectedMedium,
                "stream": _selectedStream,
                "subject": _selectedSubject,
                "unit": _unitController.text,
                "overview": _overviewController.text,
                "totalMarks": int.tryParse(_selectedMarks ?? "20") ?? 20,
                "orderIndex": int.tryParse(_orderIndexController.text) ?? 1,
                "pairs": finalPairs,
              }
            )
          : await ApiService.createMatchFollowingExam(
              {
                "title": _titleController.text,
                "board": _selectedBoard,
                "std": _selectedStandard,
                "medium": _selectedMedium,
                "stream": _selectedStream,
                "subject": _selectedSubject,
                "unit": _unitController.text,
                "overview": _overviewController.text,
                "totalMarks": int.tryParse(_selectedMarks ?? "20") ?? 20,
                "orderIndex": int.tryParse(_orderIndexController.text) ?? 1,
                "pairs": finalPairs,
              }
            );

        CustomLoader.hide(context);

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, (_isEditing || _editingId != null) ? "Test Updated Successfully!" : "Match Following Exam Created Successfully!");
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
            _isEditing ? "Edit Match Following Exam" : "Manage Match Following Exam",
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
            ? const Center(child: CustomLoader())
            : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep == 0) {
                    if (_selectedBoard != null && _selectedStandard != null && _selectedMedium != null && _selectedSubject != null && _selectedMarks != null && _unitController.text.isNotEmpty && _titleController.text.isNotEmpty) {
                       if ((_selectedStandard == "11" || _selectedStandard == "12") && _selectedStream == null) {
                          CustomToast.showError(context, "Please select a Stream");
                          return;
                      }
                      setState(() => _currentStep++);
                    } else {
                      CustomToast.showError(context, "Please enter all basic details");
                    }
                  } else if (_currentStep == 1) {
                    _submitTest();
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
                             ? const CustomLoader(size: 20)
                             : Text(
                                 _currentStep == 1 
                                   ? (_isEditing ? "Update Test" : "Create Test") 
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
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
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
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
      
                        // Medium Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedMedium,
                          items: AcademicConstants.mediums.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedMedium = val),
                          decoration: _inputDecoration("Medium", Icons.language),
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stream Dropdown
                        if (_selectedStandard != null && (_selectedStandard!.startsWith("11") || _selectedStandard!.startsWith("12"))) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedStream,
                            items: _streams.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedStream = val),
                            decoration: _inputDecoration("Stream", Icons.science_outlined),
                            style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                        ],
      
                        // Subject Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          items: (() {
                            if (_selectedBoard == null || _selectedStandard == null) return <String>[];
                            String key = "$_selectedBoard-$_selectedStandard";
                            if (_selectedStandard == "11" || _selectedStandard == "12") {
                              if (_selectedStream == null) return <String>[];
                              key += "-$_selectedStream";
                            }
                            return AcademicConstants.subjects[key] ?? <String>[];
                          }()).map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedSubject = val),
                          decoration: _inputDecoration("Subject", Icons.subject),
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
      
                        // Marks Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedMarks,
                          items: AcademicConstants.marks.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                          onChanged: _isEditing ? null : (val) => setState(() {
                            _selectedMarks = val;
                            _pairs = List.generate(int.tryParse(_selectedMarks ?? "20") ?? 20, (index) => {
                              "left": "", "right": ""});
                          }),
                          decoration: _inputDecoration("Total Marks", Icons.score),
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
      
                        // Title Name
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration("Test Title", Icons.title),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _orderIndexController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Display Order / Chapter No.", Icons.format_list_numbered),
                          style: GoogleFonts.poppins(),
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
                    title: Text("Pairs Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    isActive: _currentStep >= 1,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
  
                        _buildHeader("Pairs (${_selectedMarks ?? 20})"),
                        const SizedBox(height: 16),
  
                        ...List.generate(_pairs.length, (index) => _buildPairBlock(index)),
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

  List<String> _getFilterSubjects(String? board, String? std, String? stream) {
    if (board != null && std != null) {
      String key = "$board-$std";
      if (std == "11" || std == "12") {
        if (stream != null) {
          key += "-$stream";
        }
      }
      return AcademicConstants.subjects[key] ?? <String>[];
    }
    final Set<String> allSubs = {};
    for (var subs in AcademicConstants.subjects.values) {
      allSubs.addAll(subs);
    }
    return allSubs.toList()..sort();
  }

  Widget _buildHistoryTab() {
    final filtered = _allTests.where((test) {
      final query = _searchController.text.toLowerCase();
      final title = (test['title'] ?? "").toString().toLowerCase();
      final subject = (test['subject'] ?? "").toString().toLowerCase();
      final unit = (test['unit'] ?? "").toString().toLowerCase();
      final matchesSearch = title.contains(query) || subject.contains(query) || unit.contains(query);

      final matchBoard = _selectedFilterBoard == null || test['board'] == _selectedFilterBoard;
      final matchStd = _selectedFilterStandard == null || test['std'] == _selectedFilterStandard;
      final matchMedium = _selectedFilterMedium == null || test['medium'] == _selectedFilterMedium;
      final matchStream = _selectedFilterStream == null || test['stream'] == _selectedFilterStream;
      final matchSubject = _selectedFilterSubject == null || test['subject'] == _selectedFilterSubject;
      return matchesSearch && matchBoard && matchStd && matchMedium && matchStream && matchSubject;
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
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search by Title or Subject...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear), 
                          onPressed: () => setState(() => _searchController.clear()))
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown("Board", _selectedFilterBoard, AcademicConstants.boards, (val) => setState(() {
                      _selectedFilterBoard = val;
                      _selectedFilterStandard = null;
                      _selectedFilterSubject = null;
                    })),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown("Std", _selectedFilterStandard, _selectedFilterBoard == null ? <String>[] : AcademicConstants.standards[_selectedFilterBoard!] ?? <String>[], (val) => setState(() {
                      _selectedFilterStandard = val;
                      _selectedFilterSubject = null;
                    })),
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
                    child: _buildFilterDropdown("Stream", _selectedFilterStream, _streams, (val) => setState(() {
                      _selectedFilterStream = val;
                      _selectedFilterSubject = null;
                    })),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown("Subject", _selectedFilterSubject, _getFilterSubjects(_selectedFilterBoard, _selectedFilterStandard, _selectedFilterStream), (val) => setState(() => _selectedFilterSubject = val)),
                  ),
                ],
              ),
              if (_selectedFilterBoard != null || _selectedFilterStandard != null || _selectedFilterMedium != null || _selectedFilterStream != null || _selectedFilterSubject != null || _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _selectedFilterBoard = null;
                      _selectedFilterStandard = null;
                      _selectedFilterMedium = null;
                      _selectedFilterStream = null;
                      _selectedFilterSubject = null;
                      _searchController.clear();
                    }),
                    icon: const Icon(Icons.filter_list_off, size: 16),
                    label: Text("Clear All Filters", style: GoogleFonts.poppins(fontSize: 12)),
                  ),
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
                            "Std: ${test['std']} | ${test['medium']} ${test['stream'] != null && test['stream'] != "" ? "| ${test['stream']}" : ""} | ${test['totalMarks'] ?? 20} Marks",
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
          items: [
            DropdownMenuItem(value: null, child: Text("All $hint", style: GoogleFonts.poppins(fontSize: 14))),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPairBlock(int index) {
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
              Text("Pair ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            controller: TextEditingController(text: _pairs[index]['left'])..selection = TextSelection.fromPosition(TextPosition(offset: _pairs[index]['left'].length)),
            decoration: _inputDecoration("Enter Left Item", Icons.format_align_left),
            onChanged: (val) => _pairs[index]['left'] = val,
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: TextEditingController(text: _pairs[index]['right'])..selection = TextSelection.fromPosition(TextPosition(offset: _pairs[index]['right'].length)),
            decoration: _inputDecoration("Enter Right Item", Icons.format_align_right),
            onChanged: (val) => _pairs[index]['right'] = val,
            style: GoogleFonts.poppins(),
          ),
        ],
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
