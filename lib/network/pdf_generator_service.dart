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
            return [
              pw.Text(
                content,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 11,
                  lineSpacing: 5,
                ),
              ),
            ];
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
