import 'dart:typed_data';
import 'package:dm_bhatt_classes_new/config/secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AdminAIService {
  static const String _apiKey = Secrets.geminiApiKey;

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash', // Faster model
    apiKey: _apiKey,
  );

  /// Extract only first 5 pages text
  Future<String> _extractFirstFivePages(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);

    final int totalPages =
        document.pages.count > 5 ? 5 : document.pages.count;

    final textExtractor = PdfTextExtractor(document);

    String extractedText = '';

    for (int i = 0; i < totalPages; i++) {
      extractedText += textExtractor.extractText(startPageIndex: i);
    }

    document.dispose();

    // Limit to 12,000 characters to avoid token overload
    if (extractedText.length > 12000) {
      extractedText = extractedText.substring(0, 12000);
    }

    return extractedText;
  }

  Future<String> generateQuestions({
    required Uint8List fileBytes,
    required String questionType,
  }) async {
    try {
      debugPrint("Extracting first 5 pages...");
      final extractedText = await _extractFirstFivePages(fileBytes);

      final isTrueFalse =
          questionType.toLowerCase().contains("true") ||
              questionType.toLowerCase().contains("false");

      final isFillBlanks =
          questionType.toLowerCase().contains("fill");

      final prompt = """
You are an expert school question paper generator.

TASK:
1. First, generate a brief OVERVIEW/SUMMARY (2-3 sentences) of the provided content.
2. Then, generate MAXIMUM 20 questions based ONLY on the content.

Do NOT exceed 20 questions.
Generate questions ONLY from the provided content below.

QUESTION TYPE: $questionType
LEVEL: School Level
LANGUAGE: Keep original document language (Gujarati/English).

STRICT RULES:
1. Plain text only.
2. No markdown.
3. No headings (except the word OVERVIEW: at the start).
4. Start numbering from 01.
5. Maximum 20 questions.

FORMAT:

OVERVIEW: [Your summary here]

${isTrueFalse ? """
01. Question text
A. True
B. False
Ans. (A or B)

02. Question text
...
""" : isFillBlanks ? """
01. Fill in the blank: __________.
Ans. Correct Answer

02. Fill in the blank: __________.
Ans. Correct Answer
""" : """
01. Question text
A. Option A
B. Option B
C. Option C
D. Option D
Ans. (Correct Letter)

02. Question text
...
"""}

DOCUMENT CONTENT:
$extractedText
""";

      debugPrint("Sending limited content to AI...");

      final response = await _model.generateContent([
        Content.text(prompt)
      ]).timeout(
        const Duration(seconds: 60),
      );

      final text = response.text;

      if (text == null || text.isEmpty) {
        return "No content generated.";
      }

      return text;
    } catch (e) {
      debugPrint("AI ERROR: $e");
      return "ERROR: $e";
    }
  }
}
