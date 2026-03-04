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
            final lines = content.split('\n');
            List<pw.Widget> widgets = [];

            for (var line in lines) {
              final trimmedLine = line.trim();
              if (trimmedLine.isEmpty) continue;

              if (trimmedLine.startsWith('OVERVIEW:')) {
                // Add "Overview" Header
                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8, top: 8),
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.black)),
                    ),
                    child: pw.Text(
                      "Overview",
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                );
                // Add Overview Text (without the "OVERVIEW:" prefix if possible, or just the whole line)
                widgets.add(
                  pw.Paragraph(
                    text: trimmedLine.replaceFirst('OVERVIEW:', '').trim(),
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 11,
                      lineSpacing: 2,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    margin: const pw.EdgeInsets.only(bottom: 12),
                  ),
                );

                // Add "Questions" Header
                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8, top: 8),
                    child: pw.Text(
                      "Questions & Answers",
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                // Regular Question/Answer lines
                widgets.add(
                  pw.Paragraph(
                    text: trimmedLine,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 11,
                      lineSpacing: 2,
                    ),
                    margin: const pw.EdgeInsets.only(bottom: 4),
                  ),
                );
              }
            }
            return widgets;
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
