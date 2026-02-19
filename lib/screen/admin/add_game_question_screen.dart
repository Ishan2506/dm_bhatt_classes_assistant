import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'dart:convert';
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

  final List<String> _gameTypes = [
    'Speed Math',
    'Word Scramble',
    'Odd One Out',
    'Fact or Fiction',
    'Sentence Builder',
    'Grammar Guradian', // Typo in backend enum check
    'Word Bridge',
    'Emoji Decoder'
  ];

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
    // Fetch initial questions if needed, or wait for user to select filter
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
      _selectedGameType = q['gameType']; // Should match anyway
      _difficulty = q['difficulty'] ?? 'Medium';
      
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
        _reasonController.text = q['meta']['reason'] ?? "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Questions", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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

            DropdownButtonFormField<String>(
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
            ),
            const SizedBox(height: 16),
            
            if (_selectedGameType != null) ...[
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
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(_editingQuestionId != null ? "Update Question" : "Add Question", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
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
            ? const Center(child: CircularProgressIndicator())
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
        final String correctAnswer = _correctAnswerController.text.trim();
        List<String> options = [];
        Map<String, dynamic> meta = {};

        // Prepare data based on Game Type
        if (_selectedGameType == 'Speed Math' || _selectedGameType == 'Odd One Out') {
           options = _optionControllers.map((c) => c.text.trim()).toList();
        }
        
        if (_selectedGameType == 'Odd One Out') {
           meta['reason'] = _reasonController.text.trim();
        }
        
        if (_selectedGameType == 'Emoji Decoder') {
           meta['hint'] = _hintController.text.trim();
        }
        
        if (_selectedGameType == 'Fact or Fiction') {
           meta['fact'] = _factController.text.trim();
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
          value: _correctAnswerController.text.isNotEmpty ? _correctAnswerController.text : null,
          decoration: const InputDecoration(labelText: "Correct Answer", border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: "true", child: Text("True")),
            DropdownMenuItem(value: "false", child: Text("False")),
          ],
          onChanged: (val) {
             _correctAnswerController.text = val!;
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
}
