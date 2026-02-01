import 'dart:io';
import 'package:dm_bhatt_classes_new/models/ai_message.dart';
import 'package:dm_bhatt_classes_new/network/admin_ai_service.dart';
import 'package:dm_bhatt_classes_new/network/pdf_generator_service.dart';
import 'package:dm_bhatt_classes_new/network/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../utils/ai_flow_step.dart';

class AdminAIAssistantScreen extends StatefulWidget {
  const AdminAIAssistantScreen({super.key});

  @override
  State<AdminAIAssistantScreen> createState() => _AdminAIAssistantScreenState();
}

class _AdminAIAssistantScreenState extends State<AdminAIAssistantScreen> {
  final _controller = TextEditingController();
  final _messages = <AIMessage>[];
  final _aiService = AdminAIService();
  File? _generatedPdf;
  String? _aiText;
  AIFlowStep _step = AIFlowStep.greeting;
  String _questionType = "";

  @override
  void initState() {
    super.initState();
    _addBot("👋 Hello Admin! How can I help you?");
  }

  void _addBot(String text) {
    setState(() => _messages.add(AIMessage(text: text, isUser: false)));
  }

  void _addUser(String text) {
    setState(() => _messages.add(AIMessage(text: text, isUser: true)));
  }

  Future<bool> _canUseToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final count = prefs.getInt(today) ?? 0;
    if (count >= 3) return false;

    prefs.setInt(today, count + 1);
    return true;
  }

  Future<void> _handleSubmit() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    _controller.clear();
    _addUser(input);

    switch (_step) {
      case AIFlowStep.greeting:
        _addBot("Great! Which type of questions?\n• Fill in the Blanks\n• True / False");
        _step = AIFlowStep.questionType;
        break;

      case AIFlowStep.questionType:
        _questionType = input;
        _addBot("Please upload the source PDF 📄");
        _step = AIFlowStep.uploadPdf;
        break;

      default:
        _addBot("❌ Invalid step. Please restart.");
    }
  }

  Future<void> _pickPdf() async {
    try{
      if (!await _canUseToday()) {
        _addBot("🚫 Daily limit reached (3 times/day)");
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      _addBot("Generating questions... ⏳");
      _step = AIFlowStep.generating;

      final fileBytes = File(result.files.single.path!).readAsBytesSync();

      final output = await _aiService.generateQuestions(
        pdfBytes: fileBytes,
        questionType: _questionType,
      );
      _aiText = output;
      _generatedPdf = await PdfGeneratorService.generateQuestionPdf(output);
      //_addBot("✅ Your questions are ready:\n\n$output");
      _step = AIFlowStep.done;
    }
    catch(e){
      _addBot("❌ Failed to generate PDF.\nReason: ${e.toString()}");
      _step = AIFlowStep.greeting;
    }
  }

  void _restart() {
    setState(() {
      _messages.clear();
      _step = AIFlowStep.greeting;
    });
    _addBot("👋 Hello Admin! How can I help you?");
  }

  Future<void> downloadPdf(BuildContext context, File pdfFile) async {
    if (pdfFile == null || !pdfFile.existsSync()) return;

    // Let user pick folder (internal or SD card)
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No folder selected")),
      );
      return;
    }

    final newFile = File(
        '$selectedDirectory/Generated_Question_Paper_${DateTime.now().millisecondsSinceEpoch}.pdf');

    try {
      await pdfFile.copy(newFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ PDF saved at: ${newFile.path}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to save PDF: $e"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _restart)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? Colors.blue
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_step == AIFlowStep.uploadPdf)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload PDF"),
                onPressed: _pickPdf,
              ),
            ),
            
          if (_step == AIFlowStep.done && _generatedPdf != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download PDF"),
                  onPressed: () => downloadPdf(context, _generatedPdf!),
                ),
              ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                hintText: "Type here...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSubmit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
