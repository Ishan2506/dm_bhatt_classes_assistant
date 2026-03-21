import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AddGameQuestionScreen extends StatefulWidget {
  const AddGameQuestionScreen({super.key});

  @override
  State<AddGameQuestionScreen> createState() => _AddGameQuestionScreenState();
}

class _AddGameQuestionScreenState extends State<AddGameQuestionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedGameType;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _factController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  final List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  
  String _difficulty = 'Medium';
  bool _isLoading = false;

  String? _selectedFileName;
  PlatformFile? _pickedFile;
  bool _isImporting = false;
  String _importMode = 'Manual'; // 'Manual' or 'Bulk'

  List<String> _gameTypes = []; // Dynamic

  // List of existing questions
  List<dynamic> _existingQuestions = [];
  bool _isLoadingQuestions = false;
  String? _editingQuestionId; // If null, we are adding. If set, we are editing.

  // Filter for History Tab
  String? _filterGameType; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchGameTypes();
  }

  Future<void> _fetchGameTypes() async {
    try {
      final response = await ApiService.getGameTypes();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _gameTypes = data.cast<String>();
        });
      } else {
        _useFallbackGameTypes();
      }
    } catch (e) {
      _useFallbackGameTypes();
    }
  }

  void _useFallbackGameTypes() {
    setState(() {
      _gameTypes = [
        'Speed Math',
        'Word Scramble',
        'Odd One Out',
        'Fact or Fiction',
        'Sentence Builder',
        'Grammar Guardian',
        'Word Bridge',
        'Emoji Decoder',
        'Word Chain'
      ];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _correctAnswerController.dispose();
    _hintController.dispose();
    _factController.dispose();
    _reasonController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fetchQuestions(String? gameType) async {
    if (gameType == null) return;
    
    setState(() => _isLoadingQuestions = true);
    try {
      final response = await ApiService.getGameQuestions(gameType);
      if (response.statusCode == 200) {
        setState(() {
          _existingQuestions = jsonDecode(response.body);
        });
      } else {
        setState(() => _existingQuestions = []);
        if (response.statusCode != 404) {
           debugPrint("Error fetching questions: ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingQuestions = false);
    }
  }

  void _editQuestion(dynamic q) {
    setState(() {
      _editingQuestionId = q['_id'];
      _selectedGameType = q['gameType'];
      if (!_gameTypes.contains(_selectedGameType)) {
        _selectedGameType = null;
      }

      _difficulty = q['difficulty'] ?? 'Medium';
      if (!['Easy', 'Medium', 'Hard'].contains(_difficulty)) {
        _difficulty = 'Medium';
      }
      
      _questionController.text = q['questionText'] ?? "";
      _correctAnswerController.text = q['correctAnswer'] ?? "";
      
      // Populate Options
      if (q['options'] != null) {
        List<dynamic> opts = q['options'];
        for(int i=0; i<4; i++) {
          if (i < opts.length) _optionControllers[i].text = opts[i];
          else _optionControllers[i].clear();
        }
      }

      // Populate Meta
      if (q['meta'] != null) {
        _hintController.text = q['meta']['hint'] ?? "";
        _factController.text = q['meta']['fact'] ?? "";
        
        // For list-based games, the data might be in 'wordsList' or 'reason'
        _reasonController.text = q['meta']['wordsList'] ?? q['meta']['reason'] ?? "";
      }
    });
    // Switch to Create Tab
    _tabController.animateTo(0);
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _deleteQuestion(String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Question"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final response = await ApiService.deleteGameQuestion(id);
                if (response.statusCode == 200) {
                  CustomToast.showSuccess(context, "Deleted Successfully");
                  // Refresh list based on filter
                  _fetchQuestions(_filterGameType);
                } else {
                  CustomToast.showError(context, "Failed: ${response.body}");
                }
              } catch (e) {
                CustomToast.showError(context, "Error: $e");
              }
            },
            child: const Text("Delete"),
          )
        ],
      )
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb,
      );

      if (result != null && mounted) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _pickedFile = result.files.single;
        });
      }
    } catch (e) {
      if (mounted) {
         CustomToast.showError(context, "Error picking file: $e");
      }
    }
  }

  Future<void> _uploadBulkFile() async {
    if (_pickedFile == null) {
      CustomToast.showError(context, "Please select a file");
      return;
    }

    CustomLoader.show(context);

    try {
      List<int> fileBytes;
      if (kIsWeb) {
        if (_pickedFile!.bytes != null) {
          fileBytes = _pickedFile!.bytes!;
        } else {
          throw Exception("File data not found");
        }
      } else {
        fileBytes = await File(_pickedFile!.path!).readAsBytes();
      }

      final response = await ApiService.importGameQuestions(
        bytes: fileBytes, 
        filename: _pickedFile!.name,
        gameType: _selectedGameType
      );
      
      if (mounted) {
        CustomLoader.hide(context);

        if (response.statusCode == 200) {
           final body = jsonDecode(response.body);
           final results = body['results'];
           
           setState(() {
             _selectedFileName = null;
             _pickedFile = null;
           });
           
           if (results['success'] > 0) {
              CustomToast.showSuccess(context, "Imported: ${results['success']}, Failed: ${results['failed']}");
              if (_filterGameType != null) {
                _fetchQuestions(_filterGameType);
              }
           } else {
              CustomToast.showError(context, "Import Failed. 0 questions added. Failed: ${results['failed']}");
           }
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

  Future<void> _downloadTemplate() async {
    if (_selectedGameType == null) {
      CustomToast.showError(context, "Please select a game type first");
      return;
    }

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    List<String> headers = [];
    List<CellValue> exampleRow = [];

    switch (_selectedGameType) {
      // 1. MCQ Category (Standard MCQ, Speed Math, etc.)
      case 'Speed Math':
      case 'Grammar Guardian':
      case 'GK Quiz':
      case 'Spelling Master':
      case 'Capital City Quest':
      case 'Flag Explorer':
      case 'Stroop Effect Challenge':
      case 'Memory Match':
      case 'Spot The Difference':
      case 'Code Breaker':
      case 'Number Mastermind':
      case 'Mental Math Speedrun':
      case 'Sequence Memory':
        headers = ["Question Text", "Option 1", "Option 2", "Option 3", "Option 4", "Correct Answer", "Difficulty"];
        exampleRow = [
          TextCellValue(_selectedGameType == 'Speed Math' ? "5 + 3 = ?" : "Example Question"),
          TextCellValue("Option 1"),
          TextCellValue("Option 2"),
          TextCellValue("Option 3"),
          TextCellValue("Option 4"),
          TextCellValue("Option 1"),
          TextCellValue("Easy")
        ];
        break;

      case 'Emoji Decoder':
        headers = ["Emojis", "Correct Phrase", "Hint", "Difficulty"];
        exampleRow = [
          TextCellValue("🍎🥧"),
          TextCellValue("Apple Pie"),
          TextCellValue("A type of dessert"),
          TextCellValue("Medium")
        ];
        break;

      case 'Fact or Fiction':
        headers = ["Statement", "Fact or Fiction", "Explanation Fact", "Difficulty"];
        exampleRow = [
          TextCellValue("The sun rises in the west."),
          TextCellValue("Fiction"),
          TextCellValue("The sun rises in the east."),
          TextCellValue("Easy")
        ];
        break;

      case 'Odd One Out':
        headers = ["Option 1", "Option 2", "Option 3", "Option 4", "The Odd One", "Reason", "Difficulty"];
        exampleRow = [
          TextCellValue("Apple"),
          TextCellValue("Banana"),
          TextCellValue("Carrot"),
          TextCellValue("Mango"),
          TextCellValue("Carrot"),
          TextCellValue("It's a vegetable, others are fruits"),
          TextCellValue("Easy")
        ];
        break;

      case 'Word Scramble':
        headers = ["Correct Word", "Scrambled Word (Optional)", "Difficulty"];
        exampleRow = [
          TextCellValue("FLUTTER"),
          TextCellValue("LTTEUFR"),
          TextCellValue("Medium")
        ];
        break;
        
      case 'Sentence Builder':
        headers = ["Correct Sentence", "Difficulty"];
        exampleRow = [
          TextCellValue("The quick brown fox jumps over the lazy dog."),
          TextCellValue("Hard")
        ];
        break;

      // 7. Short Answer Category
      case 'Math Riddles':
      case 'Number Series':
      case 'Magic Square':
      case 'Algebra Balancer':
      case 'Syllable Scramble':
      case 'Proverb Completer':
      case 'Direction Sense':
      case 'Logic Gates Quest':
        headers = ["Question Text", "Correct Answer", "Hint", "Difficulty"];
        exampleRow = [
          TextCellValue("What has keys but can't open locks?"),
          TextCellValue("A piano"),
          TextCellValue("It's a musical instrument"),
          TextCellValue("Medium")
        ];
        break;

      // 9. Word Pairs
      case 'Language Translator':
      case 'Synonym & Antonym':
      case 'Word Bridge':
        headers = ["First Word", "Second Word", "Difficulty"];
        exampleRow = [
          TextCellValue("Hello"),
          TextCellValue("Namaste"),
          TextCellValue("Easy")
        ];
        break;

      // 10. List Based
      case 'Subject Word Search':
      case 'Grammar Sorter':
      case 'Word Chain':
        headers = ["Title", "Words List (Comma separated)", "Difficulty"];
        exampleRow = [
          TextCellValue("Fruits Name"),
          TextCellValue("Apple, Banana, Mango, Grapes"),
          TextCellValue("Medium")
        ];
        break;

      default:
        headers = ["Question Text", "Correct Answer", "Difficulty"];
        exampleRow = [
          TextCellValue("Example Question"),
          TextCellValue("Example Answer"),
          TextCellValue("Medium")
        ];
    }


    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
    sheetObject.appendRow(exampleRow);

    var fileBytes = excel.encode()!;
    String fileName = "${_selectedGameType!.replaceAll(' ', '_')}_Template.xlsx";

    if (kIsWeb) {
       final blob = html.Blob([fileBytes]);
       final url = html.Url.createObjectUrlFromBlob(blob);
       final anchor = html.AnchorElement(href: url)
         ..setAttribute("download", fileName)
         ..click();
       html.Url.revokeObjectUrl(url);
       if (mounted) {
         CustomToast.showSuccess(context, "Template downloaded");
       }
       return;
    }

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
           directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      String outputFile = "${directory!.path}/$fileName";
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
        
      if (mounted) {
        CustomToast.showSuccess(context, "Template downloaded to Downloads folder");
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, "Failed to download template: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Game Questions",
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
          _buildCreateTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_editingQuestionId != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 16.0),
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                   child: Row(
                     children: [
                       const Icon(Icons.edit, color: Colors.amber),
                       const SizedBox(width: 8),
                       Text("Editing Question", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                       const Spacer(),
                       TextButton(onPressed: _cancelEdit, child: const Text("Cancel"))
                     ],
                   ),
                 ),
               ),

            _buildGameTypeDropdown(),
            const SizedBox(height: 16),

            if (_selectedGameType != null && _editingQuestionId == null) ...[
              _buildImportModeToggle(),
              const SizedBox(height: 24),
            ],

            if (_selectedGameType != null) ...[
              if (_importMode == 'Bulk' && _editingQuestionId == null) 
                _buildBulkImportSection()
              else ...[
                _buildDynamicFields(),
                
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _difficulty,
                  decoration: InputDecoration(
                    labelText: "Difficulty",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Easy', 'Medium', 'Hard'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setState(() => _difficulty = val!),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Text(_editingQuestionId != null ? "Update Question" : "Add Question", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportModeToggle() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Center(child: Text("Manual Add")),
            selected: _importMode == 'Manual',
            onSelected: (val) { if (val) setState(() => _importMode = 'Manual'); },
            selectedColor: Colors.deepPurple.shade100,
            labelStyle: GoogleFonts.poppins(
              color: _importMode == 'Manual' ? Colors.deepPurple : Colors.black87,
              fontWeight: _importMode == 'Manual' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: const Center(child: Text("Bulk Import")),
            selected: _importMode == 'Bulk',
            onSelected: (val) { if (val) setState(() => _importMode = 'Bulk'); },
            selectedColor: Colors.deepPurple.shade100,
            labelStyle: GoogleFonts.poppins(
              color: _importMode == 'Bulk' ? Colors.deepPurple : Colors.black87,
              fontWeight: _importMode == 'Bulk' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Filter
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _filterGameType,
            decoration: InputDecoration(
              labelText: "Filter by Game Type",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.filter_list),
            ),
            items: _gameTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (val) {
              setState(() => _filterGameType = val);
              _fetchQuestions(val);
            },
          ),
        ),
        const Divider(),
        
        // List
        Expanded(
          child: _isLoadingQuestions 
            ? const Center(child: CustomLoader())
            : _existingQuestions.isEmpty 
              ? Center(child: Text(_filterGameType == null ? "Select a game type to see questions" : "No questions found.", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _existingQuestions.length,
                  itemBuilder: (context, index) {
                    final q = _existingQuestions[index];
                    final bool isEditing = q['_id'] == _editingQuestionId; 
                    // Note: isEditing check for highlight might not be relevant if we switch tabs, but ok to keep
                    return Card(
                      color: isEditing ? Colors.deepPurple.shade50 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(q['questionText'] ?? "No text", maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text("Ans: ${q['correctAnswer']} • ${q['difficulty']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () => _editQuestion(q),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteQuestion(q['_id']),
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

  // Update submit logic for Edit
  void _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String questionText = _questionController.text.trim();
        String correctAnswer = _correctAnswerController.text.trim();
        List<String> options = [];
        Map<String, dynamic> meta = {};

        // If correctAnswer is empty but required by schema, set a placeholder for certain games
        if (correctAnswer.isEmpty && ['Subject Word Search', 'Grammar Sorter', 'Word Chain'].contains(_selectedGameType)) {
           correctAnswer = "Dynamic List";
        }

        // Prepare data based on Game Type
        // 1. Games that use Options (Standard MCQ format)
        if ([
          'Speed Math', 'Odd One Out', 'Grammar Guardian', 'GK Quiz', 
          'Spelling Master', 'Capital City Quest', 'Flag Explorer', 
          'Logic Gates Quest', 'Stroop Effect Challenge', 'Memory Match', 
          'Spot The Difference', 'Code Breaker', 'Number Mastermind', 
          'Mental Math Speedrun', 'Sequence Memory'
        ].contains(_selectedGameType)) {
           options = _optionControllers.map((c) => c.text.trim()).toList();
        }
        
        // 2. Games that use Hints
        if ([
          'Math Riddles', 'Number Series', 'Magic Square', 'Algebra Balancer', 
          'Syllable Scramble', 'Proverb Completer', 'Direction Sense', 
          'Word Chain', 'Sorting Sweep', 'Path Finder', 'Color Flood', 'Emoji Decoder'
        ].contains(_selectedGameType)) {
           meta['hint'] = _hintController.text.trim();
        }
        
        // 3. Specific Meta Fields
        if (_selectedGameType == 'Odd One Out') {
           meta['reason'] = _reasonController.text.trim();
        }
        
        if (_selectedGameType == 'Fact or Fiction') {
           meta['fact'] = _factController.text.trim();
        }

        if (['Subject Word Search', 'Grammar Sorter', 'Word Chain'].contains(_selectedGameType)) {
           meta['wordsList'] = _reasonController.text.trim();
        }
        
        http.Response response;
        if (_editingQuestionId != null) {
          // Update
          response = await ApiService.editGameQuestion(
            id: _editingQuestionId!,
            gameType: _selectedGameType,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswer,
            difficulty: _difficulty,
            meta: meta
          );
        } else {
          // Create
          response = await ApiService.addGameQuestion(
            gameType: _selectedGameType!,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswer,
            difficulty: _difficulty,
            meta: meta
          );
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, _editingQuestionId != null ? "Updated Successfully" : "Added Successfully");
          _clearForm();
          if (_selectedGameType != null) {
             _filterGameType = _selectedGameType;
             _fetchQuestions(_filterGameType); 
          }
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _clearFormFieldsOnly();
    setState(() {
      // _selectedGameType = null; // Keep selected so list stays
      _editingQuestionId = null;
      _difficulty = 'Medium';
    });
  }

  void _clearFormFieldsOnly() {
    _questionController.clear();
    _correctAnswerController.clear();
    _hintController.clear();
    _factController.clear();
    _reasonController.clear();
     for (var controller in _optionControllers) {
      controller.clear();
    }
  }

  Widget _buildDynamicFields() {
    switch (_selectedGameType) {
      case 'Speed Math':
        return _buildSpeedMathFields();
      case 'Emoji Decoder':
        return _buildEmojiDecoderFields();
      case 'Fact or Fiction':
        return _buildFactOrFictionFields();
      case 'Odd One Out':
        return _buildOddOneOutFields();
      case 'Word Scramble':
        return _buildWordScrambleFields();
      case 'Sentence Builder':
         return _buildSentenceBuilderFields();
      
      // Standard MCQ mapped games
      case 'GK Quiz':
      case 'Grammar Guardian':
      case 'Spelling Master':
      case 'Capital City Quest':
      case 'Flag Explorer':
      case 'Stroop Effect Challenge':
      case 'Memory Match':
      case 'Spot The Difference':
      case 'Code Breaker':
      case 'Number Mastermind':
      case 'Mental Math Speedrun':
      case 'Sequence Memory':
        return _buildStandardMCQFields();

      // Short Answer mapped games
      case 'Math Riddles':
      case 'Number Series':
      case 'Magic Square':
      case 'Algebra Balancer':
      case 'Syllable Scramble':
      case 'Proverb Completer':
      case 'Direction Sense':
      case 'Logic Gates Quest':
        return _buildShortAnswerFields();

      // Word Pair mapped games
      case 'Language Translator':
      case 'Synonym & Antonym':
      case 'Word Bridge':
        return _buildWordPairFields();

      // List based games
      case 'Subject Word Search':
      case 'Grammar Sorter':
      case 'Word Chain':
        return _buildListFields();

      default:
        return const Center(child: Text("Configuration for this game type not yet implemented."));
    }
  }
  
  // 1. Speed Math: Standard + Options
  Widget _buildSpeedMathFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Math Question (e.g. 5 + 3 = ?)", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Correct Answer (e.g. 8)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        const Text("Options (Include correct answer):"),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              controller: _optionControllers[i],
              decoration: InputDecoration(labelText: "Option ${i + 1}", border: const OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ),
      ],
    );
  }

  // 2. Emoji Decoder: Emoji, Phrase, Hint
  Widget _buildEmojiDecoderFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Emojis (e.g. 🤐 🥈 🥇)", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Phrase (Answer)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _hintController,
           decoration: const InputDecoration(labelText: "Hint", border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // 3. Fact or Fiction: Statement, True/False, Fact
  Widget _buildFactOrFictionFields() {
     return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Statement", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: (_correctAnswerController.text == "true" || _correctAnswerController.text == "Fact") 
              ? "Fact" 
              : (_correctAnswerController.text == "false" || _correctAnswerController.text == "Fiction") 
                  ? "Fiction" 
                  : null,
          decoration: const InputDecoration(labelText: "Correct Answer", border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: "Fact", child: Text("Fact")),
            DropdownMenuItem(value: "Fiction", child: Text("Fiction")),
          ],
          onChanged: (val) {
             setState(() {
               _correctAnswerController.text = val!;
             });
          },
          validator: (v) => v == null ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _factController,
           decoration: const InputDecoration(labelText: "Explanation / Fact", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
      ],
    );
  }
  
  // 4. Odd One Out: Options, Answer, Reason
  Widget _buildOddOneOutFields() {
    return Column(
      children: [
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Correct Answer (The Odd One)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _reasonController,
           decoration: const InputDecoration(labelText: "Reason (Why is it odd?)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        const Text("Options (Include correct answer):"),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              controller: _optionControllers[i],
              decoration: InputDecoration(labelText: "Option ${i + 1}", border: const OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ),
      ],
    );
  }
  
  // 5. Word Scramble: Scrambled Word (Q), Answer (A)
  Widget _buildWordScrambleFields() {
    return Column(
      children: [
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Correct Word (Answer)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
         TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Scrambled Word (Optional - leave same as Answer to auto-scramble)", border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // 6. Sentence Builder: Sentence
  Widget _buildSentenceBuilderFields() {
    return Column(
      children: [
        TextFormField(
           controller: _questionController,
           decoration: const InputDecoration(labelText: "Correct Sentence", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
           onChanged: (val) {
             _correctAnswerController.text = val; // Answer is the sentence itself
           },
        ),
         const SizedBox(height: 8),
         const Text("Note: The game will automatically shuffle the words.", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // 7. Standard MCQ: Question + 4 Options
  Widget _buildStandardMCQFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: InputDecoration(
            labelText: _selectedGameType == 'Memory Match' || _selectedGameType == 'Spot The Difference' 
              ? "Prompt / Theme (e.g. Find matching pairs)" 
              : "Question Text", 
            border: const OutlineInputBorder()
          ),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Correct Answer", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        const Text("Options (Include correct answer):"),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              controller: _optionControllers[i],
              decoration: InputDecoration(labelText: "Option ${i + 1}", border: const OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ),
      ],
    );
  }

  // 8. Short Answer: Q + A
  Widget _buildShortAnswerFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Question / Challenge Description", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _correctAnswerController,
           decoration: const InputDecoration(labelText: "Correct Answer", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _hintController,
           decoration: const InputDecoration(labelText: "Hint (Optional)", border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // 9. Word Pairs: Word A (Q), Word B (A)
  Widget _buildWordPairFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: InputDecoration(
            labelText: _selectedGameType == 'Language Translator' ? "Word in Source Language" : "First Word", 
            border: const OutlineInputBorder()
          ),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _correctAnswerController,
           decoration: InputDecoration(
             labelText: _selectedGameType == 'Language Translator' ? "Word in Target Language" : "Second Word (Synonym/Antonym/Match)", 
             border: const OutlineInputBorder()
           ),
           validator: (v) => v!.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  // 10. List Based: Title (Q), CSV List (Reason)
  Widget _buildListFields() {
    return Column(
      children: [
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(labelText: "Title / Instruction", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
           controller: _reasonController,
           decoration: const InputDecoration(labelText: "Words List (Comma separated)", border: OutlineInputBorder()),
           validator: (v) => v!.isEmpty ? "Required" : null,
           maxLines: 3,
        ),
        const SizedBox(height: 8),
        const Text("Note: Enter multiple words separated by commas.", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildGameTypeDropdown() {
    if (_gameTypes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      value: _selectedGameType,
      decoration: InputDecoration(
        labelText: "Select Game Type",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _gameTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (val) {
        if (_editingQuestionId != null) {
          CustomToast.showError(context, "Cannot change game type while editing. Cancel edit first.");
          return;
        }
        setState(() {
          _selectedGameType = val;
          _clearFormFieldsOnly();
        });
      },
      validator: (val) => val == null ? "Please select a game type" : null,
    );
  }

  Widget _buildBulkImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _downloadTemplate,
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Download Template"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade100, width: 1.5, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file, size: 32, color: Colors.deepPurple.shade300),
                const SizedBox(height: 8),
                Text(
                  _selectedFileName ?? "Select Bulk Excel File",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _selectedFileName != null ? Colors.black87 : Colors.grey,
                    fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedFileName != null) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _uploadBulkFile,
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Upload & Import Questions"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ],
    );
  }
}

