import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class AddGameQuestionScreen extends StatefulWidget {
  const AddGameQuestionScreen({super.key});

  @override
  State<AddGameQuestionScreen> createState() => _AddGameQuestionScreenState();
}

class _AddGameQuestionScreenState extends State<AddGameQuestionScreen> {
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

  @override
  void dispose() {
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

  void _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
        
        if (_selectedGameType == 'Word Scramble') {
           // For Scramble, Question is scrambled word (optional, or same as answer to auto-scramble)
        }

        if (_selectedGameType == 'Fact or Fiction') {
           meta['fact'] = _factController.text.trim();
        }
        
        final response = await ApiService.addGameQuestion(
          gameType: _selectedGameType!,
          questionText: questionText,
          options: options,
          correctAnswer: correctAnswer,
          difficulty: _difficulty,
          meta: meta
        );

        if (response.statusCode == 201) {
          CustomToast.showSuccess(context, "Question Added Successfully");
          _clearForm();
        } else {
          CustomToast.showError(context, "Failed to add question: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _clearFormFieldsOnly();
    setState(() {
      _selectedGameType = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Game Question", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedGameType,
                decoration: InputDecoration(
                  labelText: "Select Game Type",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _gameTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) {
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
                      : Text("Add Question", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
