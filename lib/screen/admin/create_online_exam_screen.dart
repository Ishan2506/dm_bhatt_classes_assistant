import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Mock Model for YouthEducation Data
class Chapter {
  final String id;
  final String name;
  Chapter(this.id, this.name);
}

class MCQ {
  final String id;
  final String question;
  MCQ(this.id, this.question);
}

class CreateOnlineExamScreen extends StatefulWidget {
  const CreateOnlineExamScreen({super.key});

  @override
  State<CreateOnlineExamScreen> createState() => _CreateOnlineExamScreenState();
}

class _CreateOnlineExamScreenState extends State<CreateOnlineExamScreen> {
  int _currentStep = 0;

  // Selection Data
  String? _selectedStandard;
  String? _selectedSubject;
  String? _selectedMedium;
  String? _selectedUnit;

  // Mock Data
  final List<String> _standards = ["9", "10", "11", "12"];
  final List<String> _subjects = ["Maths", "Science", "English"];
  final List<String> _mediums = ["English", "Gujarati"];
  
  List<Chapter> _chapters = [];
  Chapter? _selectedChapter;
  
  List<MCQ> _availableMCQs = [];
  final Set<String> _selectedMCQIds = {};

  bool _isLoading = false;

  // Mock Exam History
  final List<Map<String, String>> _examHistory = [
     {"name": "Maths Unit 1 Test", "date": "22 Jan 2024", "marks": "20"},
     {"name": "Science Ch 5 Quiz", "date": "18 Jan 2024", "marks": "15"},
  ];

  // Mock API Call to fetch Chapters
  Future<void> _fetchChapters() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    setState(() {
      _chapters = [
        Chapter("c1", "Unit 1: Introduction"),
        Chapter("c2", "Unit 2: Advanced Concepts"),
        Chapter("c3", "Unit 3: Problem Solving"),
      ];
      _isLoading = false;
    });
  }

  // Mock API Call to fetch MCQs for a Chapter
  Future<void> _fetchMCQs(String chapterId) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    setState(() {
      _availableMCQs = List.generate(10, (index) => MCQ("mcq_$index", "Question ${index + 1} from Chapter $chapterId?"));
      _isLoading = false;
    });
  }

  void _showPreview() {
    final selectedQuestions = _availableMCQs.where((element) => _selectedMCQIds.contains(element.id)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exam Preview", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
             separatorBuilder: (context, index) => const Divider(),
             itemCount: selectedQuestions.length,
             itemBuilder: (context, index) {
               return ListTile(
                 leading: CircleAvatar(
                   backgroundColor: Colors.blue.shade50,
                   child: Text("${index + 1}"),
                 ),
                 title: Text(selectedQuestions[index].question, style: GoogleFonts.poppins()),
               );
             },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Create Online Exam",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Create New"),
              Tab(text: "Exam History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Create Stepper
            Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  if (_selectedStandard != null && _selectedSubject != null && _selectedMedium != null) {
                    _fetchChapters();
                    setState(() => _currentStep++);
                  } else {
                    CustomToast.showError(context, "Please select Standard, Subject and Medium");
                  }
                } else if (_currentStep == 1) {
                   if (_selectedChapter != null) {
                     _fetchMCQs(_selectedChapter!.id);
                     setState(() => _currentStep++);
                   } else {
                     CustomToast.showError(context, "Please select a Unit/Chapter");
                   }
                } else if (_currentStep == 2) {
                   if (_selectedMCQIds.isNotEmpty) {
                     // Final Creation
                     CustomToast.showSuccess(context, "Exam Created with ${_selectedMCQIds.length} questions!");
                     // Navigate or Reset
                     // Navigator.pop(context);
                   } else {
                     CustomToast.showError(context, "Please select at least one question");
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
                        ),
                        child: Text(_currentStep == 2 ? "Finish & Create" : "Continue", style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep == 2) ...[
                        OutlinedButton.icon(
                          onPressed: _showPreview,
                          icon: const Icon(Icons.visibility),
                          label: const Text("Preview"),
                           style: OutlinedButton.styleFrom(
                             foregroundColor: Colors.blue.shade900,
                             side: BorderSide(color: Colors.blue.shade900),
                           ),
                        ),
                        const SizedBox(width: 12),
                      ],
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
                  content: Column(
                    children: [
                      _buildDropdown("Standard", _selectedStandard, _standards, (val) => setState(() => _selectedStandard = val)),
                      const SizedBox(height: 16),
                      _buildDropdown("Medium", _selectedMedium, _mediums, (val) => setState(() => _selectedMedium = val)),
                      const SizedBox(height: 16),
                      _buildDropdown("Subject", _selectedSubject, _subjects, (val) => setState(() => _selectedSubject = val)),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text("Select Unit (YouthEducation API)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  content: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: _chapters.map((chapter) => RadioListTile<Chapter>(
                          title: Text(chapter.name, style: GoogleFonts.poppins()),
                          value: chapter,
                          groupValue: _selectedChapter,
                          onChanged: (val) => setState(() => _selectedChapter = val),
                          activeColor: Colors.blue.shade900,
                        )).toList(),
                      ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: Text("Select Questions", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                   content: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                           Text("Total Selected: ${_selectedMCQIds.length}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                           const SizedBox(height: 8),
                           ..._availableMCQs.map((mcq) => CheckboxListTile(
                              title: Text(mcq.question, style: GoogleFonts.poppins()),
                               value: _selectedMCQIds.contains(mcq.id),
                               activeColor: Colors.blue.shade900,
                               onChanged: (bool? value) {
                                 setState(() {
                                   if (value == true) {
                                     _selectedMCQIds.add(mcq.id);
                                   } else {
                                     _selectedMCQIds.remove(mcq.id);
                                   }
                                 });
                               },
                            )),
                        ],
                      ),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
            
            // Tab 2: Exam History
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _examHistory.length,
              itemBuilder: (context, index) {
                final exam = _examHistory[index];
                return Card(
                   elevation: 0,
                   color: Colors.grey.shade50,
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                   margin: const EdgeInsets.only(bottom: 12),
                   child: ListTile(
                     leading: const Icon(Icons.quiz_outlined, color: Colors.purple),
                     title: Text(exam['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                     subtitle: Text("${exam['date']} • ${exam['marks']} questions", style: GoogleFonts.poppins(fontSize: 12)),
                     trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                   ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins()))).toList(),
      onChanged: onChanged,
    );
  }
}
