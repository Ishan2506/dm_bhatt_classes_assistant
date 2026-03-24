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
  String _searchQuery = "";

  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
        children: [_buildFilterBar(), _buildSearchBar(), Expanded(child: _isLoading ? const Center(child: CustomLoader()) : _results.isEmpty ? _buildEmptyState() : _buildList())],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSmallDropdown("Board", _selectedBoard, AcademicConstants.boards, (v) => setState(() { _selectedBoard = v; _fetchData(); })),
            const SizedBox(width: 8),
            _buildSmallDropdown("Std", _selectedStd, _selectedBoard != null ? (AcademicConstants.standards[_selectedBoard!] ?? []) : [], (v) => setState(() { _selectedStd = v; _fetchData(); })),
            const SizedBox(width: 8),
            _buildSmallDropdown("Medium", _selectedMedium, AcademicConstants.mediums, (v) => setState(() { _selectedMedium = v; _fetchData(); })),
            const SizedBox(width: 8),
            if (_selectedStd == "11" || _selectedStd == "12")
              _buildSmallDropdown("Stream", _selectedStream, ["Science", "Commerce"], (v) => setState(() { _selectedStream = v; _fetchData(); })),
            IconButton(icon: const Icon(Icons.clear_all, color: Colors.red), onPressed: () => setState(() { _selectedBoard = null; _selectedStd = null; _selectedMedium = null; _selectedStream = null; _fetchData(); })),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(hint: Text(hint, style: const TextStyle(fontSize: 12)), value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(), onChanged: onChanged)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v) => setState(() => _searchQuery = v), decoration: InputDecoration(hintText: "Search students...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 0))));
  }

  Widget _buildList() {
    final filtered = _results.where((r) => _searchQuery.isEmpty || r['studentName'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (filtered.isEmpty) return _buildEmptyState();
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: filtered.length, itemBuilder: (context, index) => _buildCard(filtered[index]));
  }

  Widget _buildCard(dynamic row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(row['studentName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${row['title']}\nScore: ${row['obtainedMarks']} / ${row['totalMarks']}"),
        trailing: Text(DateFormat('dd-MM').format(DateTime.parse(row['date']))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No records found", style: GoogleFonts.poppins(color: Colors.grey)));
  }
}
