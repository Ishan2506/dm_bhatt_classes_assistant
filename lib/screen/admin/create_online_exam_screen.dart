import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/screen/admin/review_questions_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/exam_preview_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  // String? _selectedUnit; // Removed in favor of PDF

  // Mock Data
  final List<String> _standards = ["9", "10", "11", "12"];
  final List<String> _subjects = ["Maths", "Science", "English"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _marks = ["20", "30", "40", "50"];
  
  String? _selectedMarks;
  
  // List<Chapter> _chapters = []; // Not used in PDF flow
  // Chapter? _selectedChapter; // Not used
  
  // List<MCQ> _availableMCQs = []; 
  // final Set<String> _selectedMCQIds = {};

  bool _isLoading = false;
  final TextEditingController _unitController = TextEditingController();

  // Exam History Data
  List<dynamic> _exams = [];
  bool _isLoadingHistory = true;
  bool _isManualEntry = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if(!mounted) return;
    setState(() => _isLoadingHistory = true);
    try {
      final response = await ApiService.getAllExams();
      if (response.statusCode == 200) {
        if(!mounted) return;
        setState(() {
          _exams = jsonDecode(response.body);
          _isLoadingHistory = false;
        });
      } else {
        if(!mounted) return;
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      if(!mounted) return;
      setState(() => _isLoadingHistory = false);
      debugPrint("Error fetching exams: $e");
    }
  }

  Future<void> _deleteExam(String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Exam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this exam?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final response = await ApiService.deleteExam(id);
                if (response.statusCode == 200) {
                  CustomToast.showSuccess(context, "Exam deleted successfully");
                  _fetchExams();
                } else {
                  CustomToast.showError(context, "Failed to delete exam");
                }
              } catch (e) {
                CustomToast.showError(context, "Error: $e");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  PlatformFile? _pickedPdf;

  Future<void> _pickPdf() async {
    debugPrint("Picking PDF...");
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed from custom to any to rule out filter issues
        withData: kIsWeb,
      );

      debugPrint("FilePicker Result: $result");

      if (result != null && mounted) {
        setState(() {
          _pickedPdf = result.files.single;
        });
        debugPrint("Selected File: ${_pickedPdf!.name}");
      } else {
        debugPrint("File selection cancelled or failed.");
      }
    } catch (e) {
      debugPrint("FilePicker Error: $e");
      CustomToast.showError(context, "Error: $e");
    }
  }

  Future<void> _uploadAndProcessPdf() async {
    if (_pickedPdf == null) return;

    setState(() => _isLoading = true);

    try {
      List<int> fileBytes;
      if (kIsWeb) {
         fileBytes = _pickedPdf!.bytes!;
      } else {
         fileBytes = await File(_pickedPdf!.path!).readAsBytes();
      }

      final response = await ApiService.uploadExamPdf(
        bytes: fileBytes,
        filename: _pickedPdf!.name
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
         final body = jsonDecode(response.body);
         final questions = body['questions'] as List;
         final rawText = body['rawText'] as String? ?? "No text extracted";

         debugPrint("Parsed Questions: ${questions.length}");
         debugPrint("Raw Text Preview: ${rawText.substring(0, rawText.length > 200 ? 200 : rawText.length)}");

         if (questions.isEmpty) {
            // Show Debug Dialog with Raw Text to understand why parsing failed
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Parsing Failed"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("No questions valid found. Here is what the OCR read:"),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey.shade100,
                        height: 300,
                        width: double.maxFinite,
                        child: SelectableText(rawText, style: GoogleFonts.robotoMono(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
                ],
              )
            );
            return;
         }

         // Navigate to Review Screen
         Navigator.push(
           context, 
           MaterialPageRoute(builder: (context) => ReviewQuestionsScreen(
             parsedQuestions: questions,
             subject: _selectedSubject ?? "General",
             std: _selectedStandard ?? "",
             medium: _selectedMedium ?? "",
             unit: _unitController.text,
             totalMarks: _selectedMarks ?? "20", 
           ))
         );

      } else {
         CustomToast.showError(context, "Upload Failed: ${response.body}");
      }
    } catch (e) {
       if (mounted) {
         setState(() => _isLoading = false);
         CustomToast.showError(context, "Error: $e");
       }
    }
  }

  // Not used in PDF flow, but keeping if needed later or deleting?
  // _fetchChapters, _fetchMCQs, _showPreview removed for clarity since we are doing PDF only now as per request.

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
                  if (_selectedStandard != null && _selectedSubject != null && _selectedMedium != null && _selectedMarks != null && _unitController.text.isNotEmpty) {
                    setState(() => _currentStep++);
                  } else {
                    CustomToast.showError(context, "Please select Standard, Subject, Medium, Marks and enter Unit");
                  }
                } else if (_currentStep == 1) {
                   if (_isManualEntry) {
                     // Manual Entry Flow
                     Navigator.push(
                       context, 
                       MaterialPageRoute(builder: (context) => ReviewQuestionsScreen(
                         parsedQuestions: const [],
                         subject: _selectedSubject ?? "General",
                         std: _selectedStandard ?? "",
                         medium: _selectedMedium ?? "",
                         unit: _unitController.text,
                         totalMarks: _selectedMarks ?? "20", 
                       ))
                     );
                   } else {
                     // PDF Upload Flow
                     if (_pickedPdf != null) {
                       _uploadAndProcessPdf();
                     } else {
                       CustomToast.showError(context, "Please upload a PDF");
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
                        ),
                        child: _isLoading 
                           ? const Center(child: CustomLoader())
                           : Text(
                               _currentStep == 1 
                                 ? (_isManualEntry ? "Start Adding Questions" : "Process PDF") 
                                 : "Continue", 
                               style: GoogleFonts.poppins(color: Colors.white)
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
                  content: Column(
                    children: [
                      _buildDropdown("Standard", _selectedStandard, _standards, (val) => setState(() => _selectedStandard = val)),
                      const SizedBox(height: 16),
                      _buildDropdown("Medium", _selectedMedium, _mediums, (val) => setState(() => _selectedMedium = val)),
                      const SizedBox(height: 16),
                      _buildDropdown("Subject", _selectedSubject, _subjects, (val) => setState(() => _selectedSubject = val)),
                      const SizedBox(height: 16),
                      _buildDropdown("Marks", _selectedMarks, _marks, (val) => setState(() => _selectedMarks = val)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: "Unit / Chapter",
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text("Questions Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  content: Column(
                    children: [
                       // Toggle
                       Row(
                         children: [
                           Expanded(
                             child: RadioListTile<bool>(
                               title: Text("Upload PDF", style: GoogleFonts.poppins()),
                               value: false, 
                               groupValue: _isManualEntry, 
                               onChanged: (val) => setState(() => _isManualEntry = val!),
                             ),
                           ),
                           Expanded(
                             child: RadioListTile<bool>(
                               title: Text("Manual Entry", style: GoogleFonts.poppins()),
                               value: true, 
                               groupValue: _isManualEntry, 
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
                             border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                             borderRadius: BorderRadius.circular(12),
                             color: Colors.grey.shade50,
                           ),
                           child: Column(
                             children: [
                               Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade300),
                               const SizedBox(height: 16),
                               ElevatedButton(
                                 onPressed: _pickPdf,
                                 child: Text(_pickedPdf != null ? "Change File" : "Select PDF"),
                               ),
                               if (_pickedPdf != null) ...[
                                 const SizedBox(height: 12),
                                 Text("Selected: ${_pickedPdf!.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                               ]
                             ],
                           ),
                         ),
                         const SizedBox(height: 12),
                         const Text("Ensure format: 1. Question... A)... B)... Answer: A", style: TextStyle(color: Colors.grey, fontSize: 12)),
                       ] else ...[
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             border: Border.all(color: Colors.blue.shade100, style: BorderStyle.solid),
                             borderRadius: BorderRadius.circular(12),
                             color: Colors.blue.shade50,
                           ),
                           child: Column(
                             children: [
                               Icon(Icons.edit_note, size: 48, color: Colors.blue.shade700),
                               const SizedBox(height: 16),
                               Text(
                                 "You will manually add ${_selectedMarks ?? '20'} questions in the next screen.",
                                 textAlign: TextAlign.center,
                                 style: GoogleFonts.poppins(color: Colors.blue.shade900),
                               ),
                             ],
                           ),
                         ),
                       ]
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
            
            // Tab 2: Exam History
            _isLoadingHistory
                ? const Center(child: CustomLoader())
                : _exams.isEmpty
                    ? Center(child: Text("No exams found", style: GoogleFonts.poppins(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _exams.length,
                        itemBuilder: (context, index) {
                          final exam = _exams[index];
                          final String id = exam['_id'];
                          
                          // Format Date
                          String displayDate = "--";
                          if (exam['createdAt'] != null) {
                             displayDate = exam['createdAt'].toString().split('T')[0];
                          }

                          return Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.quiz_outlined, color: Colors.blue.shade900),
                              ),
                              title: Text(exam['name'] ?? "Untitled", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                "${exam['subject'] ?? 'General'} • $displayDate • ${exam['totalMarks']} Marks", 
                                style: GoogleFonts.poppins(fontSize: 12)
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExamPreviewScreen(
                                            examId: id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteExam(id),
                                  ),
                                ],
                              ),
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
