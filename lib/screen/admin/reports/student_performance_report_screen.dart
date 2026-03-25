import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class StudentPerformanceReportScreen extends StatefulWidget {
  const StudentPerformanceReportScreen({super.key});

  @override
  State<StudentPerformanceReportScreen> createState() => _StudentPerformanceReportScreenState();
}

class _StudentPerformanceReportScreenState extends State<StudentPerformanceReportScreen> {
  bool _isLoading = false;
  List<dynamic> _students = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Filter States
  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getStudentReports(
        board: _selectedBoard,
        std: _selectedStd,
        medium: _selectedMedium,
        stream: _selectedStream,
      );

      if (res.statusCode == 200) {
        setState(() {
          _students = jsonDecode(res.body);
        });
      } else {
        CustomToast.showError(context, "Failed to load reports");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToExcel() async {
    if (_students.isEmpty) return;

    var excel = Excel.createExcel();
    Sheet sheetObject = excel["Student Performance"];
    excel.delete('Sheet1');

    sheetObject.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Phone'),
      TextCellValue('Board'),
      TextCellValue('Standard'),
      TextCellValue('Medium'),
      TextCellValue('Total Exams'),
      TextCellValue('Average Score (%)'),
    ]);

    for (var row in _students) {
      sheetObject.appendRow([
        TextCellValue(row['name']?.toString() ?? ''),
        TextCellValue(row['phone']?.toString() ?? ''),
        TextCellValue(row['board']?.toString() ?? ''),
        TextCellValue(row['std']?.toString() ?? ''),
        TextCellValue(row['medium']?.toString() ?? ''),
        IntCellValue(int.tryParse(row['totalExams']?.toString() ?? '0') ?? 0),
        DoubleCellValue(double.tryParse(row['avgMarks']?.toString() ?? '0') ?? 0.0),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${directory.path}/Student_Performance_Report_$timestamp.xlsx');
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(file.path);
      CustomToast.showSuccess(context, "Exported!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Student Performance",
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _students.isEmpty ? null : _exportToExcel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CustomLoader())
                : _students.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _students.length,
                        itemBuilder: (context, index) => _buildStudentCard(_students[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search students...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Board", _selectedBoard, AcademicConstants.boards, (val) => setState(() {
                  _selectedBoard = val;
                  _selectedStd = null;
                  _fetchData();
                })),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown("Std", _selectedStd, _selectedBoard == null ? [] : AcademicConstants.standards[_selectedBoard!] ?? [], (val) => setState(() { 
                  _selectedStd = val;
                  _fetchData(); 
                })),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Medium", _selectedMedium, AcademicConstants.mediums, (val) => setState(() { 
                  _selectedMedium = val;
                  _fetchData(); 
                })),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown("Stream", _selectedStream, ["Science", "Commerce"], (val) => setState(() { 
                  _selectedStream = val;
                  _fetchData(); 
                })),
              ),
            ],
          ),
          if (_selectedBoard != null || _selectedStd != null || _selectedMedium != null || _selectedStream != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _selectedBoard = null;
                  _selectedStd = null;
                  _selectedMedium = null;
                  _selectedStream = null;
                  _searchController.clear();
                  _fetchData();
                }),
                icon: const Icon(Icons.filter_list_off, size: 16),
                label: Text("Clear All Filters", style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          value: value,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem(value: null, child: Text("All $hint", style: GoogleFonts.poppins(fontSize: 14))),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic row) {
    if (_searchQuery.isNotEmpty && !(row['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(row['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Exams: ${row['totalExams']} | Avg: ${row['avgMarks']?.toStringAsFixed(1)}%"),
        children: [
          ...(row['exams'] as List).map((exam) => ListTile(
            dense: true,
            title: Text(exam['title']),
            trailing: Text("${exam['score']}/${exam['total']}"),
            subtitle: Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(exam['date']))),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No data found", style: GoogleFonts.poppins(color: Colors.grey)));
  }
}
