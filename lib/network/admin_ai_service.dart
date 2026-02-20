import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class AdminAIService {
  static const String _apiKey = "AIzaSyAGh3ga2KcJBK-8dZLjO-39wgAdI2i7L9E";

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  Future<String> generateQuestions({
    required Uint8List fileBytes,
    required String mimeType,
    required String questionType,
  }) async {
//     final prompt = '''
// You are an education content generator.

// Read the uploaded PDF and generate a Question Answer content.

// Question Types:
// $questionType

// Rules:
// - School level
// - Simple English
// - Output format:
//   1. Questions
//   2. Options (if applicable)
//   3. Correct Answers at the end
// ''';
final isTrueFalse = questionType.toLowerCase().contains("true") || questionType.toLowerCase().contains("false");

final prompt = '''
You are a question paper generator.

IMPORTANT RULES (MANDATORY):
- Follow the exact format shown below
- Do NOT add headings
- Do NOT add markdown
- Do NOT explain anything
- Do NOT change spacing
- Do NOT add extra text

FORMAT TO FOLLOW EXACTLY:
${isTrueFalse ? '''
01. Question text
A. True
B. False
Ans. (A or B) Correct Option Text
''' : '''
01. Question text
A. Option A
B. Option B
C. Option C
D. Option D
Ans. (CorrectOptionLetter) Correct Option Text
'''}

LANGUAGE: Gujarati + English (as per Document)
LEVEL: School
QUESTION TYPE: $questionType

Generate questions ONLY based on the uploaded Document.
''';


    final content = [
      Content.multi([
        DataPart(mimeType, fileBytes),
        TextPart(prompt),
      ])
    ];

    final response = await _model.generateContent(content).timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception("AI request timed out. Please try again."),
    );
    return response.text ?? "No content generated.";
  }
}
