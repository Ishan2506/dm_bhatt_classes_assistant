import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
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
import 'package:universal_html/html.dart' as html;

class CombinedReportScreen extends StatefulWidget {
  const CombinedReportScreen({super.key});

  @override
  State<CombinedReportScreen> createState() => _CombinedReportScreenState();
}

class _CombinedReportScreenState extends State<CombinedReportScreen> {
  bool _isLoading = false;
  List<dynamic> _results = [];
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
      final res = await ApiService.getExamReports(
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
    Sheet sheetObject = excel["Combined Report"];
    excel.delete('Sheet1');

    sheetObject.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Phone'),
      TextCellValue('Board'),
      TextCellValue('Standard'),
      TextCellValue('Medium'),
      TextCellValue('Stream'),
      TextCellValue('Exam Title'),
      TextCellValue('Type'),
      TextCellValue('Obtained Marks'),
      TextCellValue('Total Marks'),
      TextCellValue('Date'),
    ]);

    for (var row in _results) {
      sheetObject.appendRow([
        TextCellValue(row['studentName']?.toString() ?? ''),
        TextCellValue(row['studentPhone']?.toString() ?? ''),
        TextCellValue(row['board']?.toString() ?? ''),
        TextCellValue(row['std']?.toString() ?? ''),
        TextCellValue(row['medium']?.toString() ?? ''),
        TextCellValue(row['stream']?.toString() ?? ''),
        TextCellValue(row['title']?.toString() ?? ''),
        TextCellValue(row['type']?.toString() ?? ''),
        IntCellValue(int.tryParse(row['obtainedMarks']?.toString() ?? '0') ?? 0),
        IntCellValue(int.tryParse(row['totalMarks']?.toString() ?? '0') ?? 0),
        TextCellValue(row['date'] != null ? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(row['date'])) : ''),
      ]);
    }

    var fileBytes = excel.encode();
    if (fileBytes != null) {
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = "Combined_Report_$timestamp.xlsx";

      if (kIsWeb) {
        final blob = html.Blob([fileBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        CustomToast.showSuccess(context, "Report exported!");
        return;
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(file.path);
      CustomToast.showSuccess(context, "Report exported!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Combined Exam Report",
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _results.isEmpty ? null : _exportToExcel),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CustomLoader())
                : _results.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _results.length,
                        itemBuilder: (context, index) => _buildResultCard(_results[index]),
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
              hintText: "Search by student name...",
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

  Widget _buildResultCard(dynamic row) {
    if (_searchQuery.isNotEmpty && !(row['studentName']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(row['studentName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${row['title']} (${row['type'] ?? 'N/A'})\nScore: ${row['obtainedMarks']} / ${row['totalMarks']}"),
        trailing: Text("Std ${row['std']}", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No data found", style: GoogleFonts.poppins(color: Colors.grey)));
  }
}
