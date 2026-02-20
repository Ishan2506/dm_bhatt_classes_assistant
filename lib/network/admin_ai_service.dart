// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class AdminAIService {
//   static const String _apiKey = "AIzaSyC-myNA1DZn6106sZ2MmDSQPIArTKOaO6k";

//   final GenerativeModel _model = GenerativeModel(
//     model: 'gemini-2.5-flash',
//     apiKey: _apiKey,
//   );

//   Future<String> generateQuestions({
//     required Uint8List fileBytes,
//     required String mimeType,
//     required String questionType,
//   }) async {
//     final isTrueFalse = questionType.toLowerCase().contains("true") || 
//                         questionType.toLowerCase().contains("false");

//     final prompt = '''
// You are an expert question paper generator for schools.

// TASK:
// Generate high-quality questions based ONLY on the content of the attached document.
// The document may contain text in Gujarati and English. Please maintain the language context as per the source.

// QUESTION TYPE: $questionType
// LANGUAGE: Gujarati + English (as per Document)
// LEVEL: School level

// IMPORTANT FORMATTING RULES (MANDATORY):
// 1. Use the EXACT format shown below.
// 2. Do NOT add any markdown formatting (like ``` or **).
// 3. Do NOT add headings, titles, or introductory text.
// 4. Do NOT add explanations or extra commentary.
// 5. Use plain text only.
// 6. Number questions starting from 01.

// EXPECTED OUTPUT FORMAT:
// ${isTrueFalse ? '''
// 01. [Question text here]
// A. True
// B. False
// Ans. (A or B) [Correct Option Text]

// 02. [Question text here]
// ...
// ''' : '''
// 01. [Question text here]
// A. [Option A]
// B. [Option B]
// C. [Option C]
// D. [Option D]
// Ans. (CorrectOptionLetter) [Correct Option Text]

// 02. [Question text here]
// ...
// '''}

// If the document is too blurry or cannot be read, respond with: "ERROR: Document could not be processed. Please upload a clearer file."
// ''';

//     debugPrint("AI_PROMPT_SENT >>> questionType: $questionType");
//     debugPrint("AI_PROMPT_SENT >>> isTrueFalse: $isTrueFalse");
//     debugPrint("AI_PROMPT_SENT >>> mimeType: $mimeType");
//     debugPrint("AI_PROMPT_SENT >>> fullPrompt:\n$prompt");

//     final content = [
//       Content.multi([
//         DataPart(mimeType, fileBytes),
//         TextPart(prompt),
//       ])
//     ];

//     try {
//       final response = await _model.generateContent(content).timeout(
//         const Duration(seconds: 90), // Increased timeout for Pro model
//         onTimeout: () => throw Exception("AI request timed out. Large or complex documents may take longer."),
//       );

//       final text = response.text;
//       if (text == null || text.isEmpty) {
//         return "No content generated. The AI might have found the document incompatible.";
//       }

//       if (text.contains("ERROR:")) {
//         return text;
//       }

//       return text;
//     } catch (e) {
//       debugPrint("AI_SERVICE_ERROR: $e");
//       if (e.toString().contains("model not found")) {
//         return "ERROR: Model not found. Exact error: $e";
//       }
//       return "ERROR: $e";
//     }
//   }
// }
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AdminAIService {
  static const String _apiKey = "AIzaSyC-myNA1DZn6106sZ2MmDSQPIArTKOaO6k";

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

Generate MAXIMUM 20 questions ONLY.
Do NOT exceed 20 questions.

Generate questions ONLY from the provided content below.

QUESTION TYPE: $questionType
LEVEL: School Level
LANGUAGE: Keep original document language (Gujarati/English).

STRICT RULES:
1. Plain text only.
2. No markdown.
3. No headings.
4. Start numbering from 01.
5. Maximum 20 questions.

FORMAT:

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
