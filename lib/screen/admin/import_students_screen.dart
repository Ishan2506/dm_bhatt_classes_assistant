import 'dart:io';
import 'dart:convert';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class AdminImportStudentsScreen extends StatefulWidget {
  const AdminImportStudentsScreen({super.key});

  @override
  State<AdminImportStudentsScreen> createState() => _AdminImportStudentsScreenState();
}

class _AdminImportStudentsScreenState extends State<AdminImportStudentsScreen> {
  String? _selectedFileName;
  PlatformFile? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb, // Important for Web to get bytes
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

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      CustomToast.showError(context, "Please select a file");
      return;
    }

    /* setState(() {
      _isUploading = true;
    }); */
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
        // Native
        fileBytes = await File(_pickedFile!.path!).readAsBytes();
      }

      final response = await ApiService.importStudents(
        bytes: fileBytes, 
        filename: _pickedFile!.name
      );
      
      if (mounted) {
        /* setState(() {
          _isUploading = false;
        }); */
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
           } else {
              CustomToast.showError(context, "Import Failed. 0 students added. Failed: ${results['failed']}");
           }
        } else {
           CustomToast.showError(context, "Failed: ${response.body}");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomLoader.hide(context);
        // setState(() => _isUploading = false);
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  Future<void> _downloadTemplate() async {
    // Creating Excel File
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    List<String> headers = [
      "Name",
      "Phone Number",
      "Password",
      "Parent's Mobile Number",
      "Board",
      "Standard",
      "Medium",
      "Stream",
      "State",
      "City",
      "Address",
      "School Name"
    ];

    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
    var fileBytes = excel.encode()!;

    // WEB Logic
    if (kIsWeb) {
       final blob = html.Blob([fileBytes]);
       final url = html.Url.createObjectUrlFromBlob(blob);
       final anchor = html.AnchorElement(href: url)
         ..setAttribute("download", "Student_Import_Template.xlsx")
         ..click();
       html.Url.revokeObjectUrl(url);
       if (mounted) {
         CustomToast.showSuccess(context, "Template downloaded");
       }
       return;
    }

    // NATIVE Logic
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // For managing external storage on Android 11+
    if (Platform.isAndroid) {
         if (await Permission.manageExternalStorage.status.isDenied) {
             await Permission.manageExternalStorage.request();
         }
    }

    // Save Logic
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Fallback if direct path doesn't exist
        if (!await directory.exists()) {
           directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      String outputFile = "${directory!.path}/Student_Import_Template.xlsx";
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Import Students",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Instructions",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "1. Download the Excel template.\n2. Fill in the student details without changing headers.\n3. Upload the filled Excel file.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Download Template Button
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download),
              label: const Text("Download Template"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                foregroundColor: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),

            // File Selection Area
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                    style: BorderStyle.solid,
                    width: 1.5
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file, 
                      size: 48, 
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade700
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? "Select Excel File",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _selectedFileName != null ? theme.textTheme.bodyLarge?.color : Colors.grey.shade500,
                        fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                     if (_selectedFileName == null)
                      Text(
                        "(.xlsx, .xls format)",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: Text(
                      "Upload Excel File",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
