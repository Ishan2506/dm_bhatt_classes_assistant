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

class RegularExamReportScreen extends StatefulWidget {
  const RegularExamReportScreen({super.key});

  @override
  State<RegularExamReportScreen> createState() => _RegularExamReportScreenState();
}

class _RegularExamReportScreenState extends State<RegularExamReportScreen> {
  bool _isLoading = false;
  List<dynamic> _results = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedTitle;

  List<String> get _uniqueTitles {
    final titles = _results
        .map((r) => r['title']?.toString() ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    titles.sort();
    return titles;
  }

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
      final res = await ApiService.getExamReports(
        type: "REGULAR", // Filter by Regular Exams
        board: _selectedBoard,
        std: _selectedStd,
        medium: _selectedMedium,
        stream: _selectedStream,
      );

      if (res.statusCode == 200) {
        setState(() {
          _results = jsonDecode(res.body);
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
    if (_results.isEmpty) return;
    var excel = Excel.createExcel();
    Sheet sheetObject = excel["Regular Exam Report"];
    excel.delete('Sheet1');
    sheetObject.appendRow([
      TextCellValue('Student Name'), TextCellValue('Phone'), TextCellValue('Board'),
      TextCellValue('Standard'), TextCellValue('Medium'), TextCellValue('Exam Title'),
      TextCellValue('Obtained Marks'), TextCellValue('Total Marks'), TextCellValue('Date'),
    ]);

    for (var row in _results) {
      sheetObject.appendRow([
        TextCellValue(row['studentName']?.toString() ?? ''),
        TextCellValue(row['studentPhone']?.toString() ?? ''),
        TextCellValue(row['board']?.toString() ?? ''),
        TextCellValue(row['std']?.toString() ?? ''),
        TextCellValue(row['medium']?.toString() ?? ''),
        TextCellValue(row['title']?.toString() ?? ''),
        IntCellValue(int.tryParse(row['obtainedMarks']?.toString() ?? '0') ?? 0),
        IntCellValue(int.tryParse(row['totalMarks']?.toString() ?? '0') ?? 0),
        TextCellValue(row['date'] != null ? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(row['date'])) : ''),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${directory.path}/Regular_Exam_Report_$timestamp.xlsx');
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Regular Exam Report",
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _results.isEmpty ? null : _exportToExcel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(child: _isLoading ? const Center(child: CustomLoader()) : _results.isEmpty ? _buildEmptyState() : _buildList()),
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
              hintText: "Search students or exam title...",
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
          const SizedBox(height: 12),
          _buildFilterDropdown("Exam Title", _selectedTitle, _uniqueTitles, (val) => setState(() => _selectedTitle = val)),
          if (_selectedBoard != null || _selectedStd != null || _selectedMedium != null || _selectedStream != null || _selectedTitle != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _selectedBoard = null;
                  _selectedStd = null;
                  _selectedMedium = null;
                  _selectedStream = null;
                  _selectedTitle = null;
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

  Widget _buildList() {
    final filtered = _results.where((r) {
      final matchTitleDropdown = _selectedTitle == null || r['title']?.toString() == _selectedTitle;
      if (!matchTitleDropdown) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchName = r['studentName']?.toString().toLowerCase().contains(q) ?? false;
      final matchTitle = r['title']?.toString().toLowerCase().contains(q) ?? false;
      return matchName || matchTitle;
    }).toList();
    if (filtered.isEmpty) return _buildEmptyState();
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: filtered.length, itemBuilder: (context, index) => _buildCard(filtered[index]));
  }

  Widget _buildCard(dynamic row) {
    final dateFormatted = row['date'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(row['date'])) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_turned_in_rounded, color: Colors.orange.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row['studentName']?.toString() ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row['title']?.toString() ?? 'Unknown Exam',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: $dateFormatted",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Score",
                    style: GoogleFonts.poppins(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "${row['obtainedMarks']} / ${row['totalMarks']}",
                    style: GoogleFonts.poppins(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No records found", style: GoogleFonts.poppins(color: Colors.grey)));
  }
}
