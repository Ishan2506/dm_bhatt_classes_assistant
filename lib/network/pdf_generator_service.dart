// import 'dart:io';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';

// Future<File> generateQuestionPdf(String content) async {
//   final pdf = pw.Document();

//   pdf.addPage(
//     pw.MultiPage(
//       margin: const pw.EdgeInsets.all(24),
//       build: (_) => [
//         pw.Text(
//           content,
//           style: const pw.TextStyle(fontSize: 11),
//         ),
//       ],
//     ),
//   );

//   final dir = await getApplicationDocumentsDirectory();
//   final file = File('${dir.path}/Generated_Question_Paper.pdf');

//   await file.writeAsBytes(await pdf.save());
//   return file;
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfGeneratorService {
  static Future<File> generateQuestionPdf(String content) async {
    try {
      final pdf = pw.Document();

      // ✅ Load Gujarati Unicode Font
      final fontData = await rootBundle
          .load('assets/fonts/NotoSansGujarati-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            // Split content by \n to allow the layout engine to break between lines/paragraphs
            final lines = content.split('\n');
            return lines.map((line) => pw.Paragraph(
              text: line,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 11,
                lineSpacing: 2,
              ),
              margin: const pw.EdgeInsets.only(bottom: 4),
            )).toList();
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/Generated_Question_Paper_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw Exception("PDF generation failed: $e");
    }
  }
}
