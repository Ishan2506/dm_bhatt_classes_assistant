import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';

class UpgradePlanReportScreen extends StatefulWidget {
  const UpgradePlanReportScreen({super.key});

  @override
  State<UpgradePlanReportScreen> createState() => _UpgradePlanReportScreenState();
}

class _UpgradePlanReportScreenState extends State<UpgradePlanReportScreen> {
  bool _isLoading = false;
  List<dynamic> _allData = [];
  List<dynamic> _reportData = [];
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
      final res = await ApiService.getUpgradePlanReports(
        board: _selectedBoard,
        std: _selectedStd,
        medium: _selectedMedium,
        stream: _selectedStream,
      );

      if (res.statusCode == 200) {
        setState(() {
          _allData = jsonDecode(res.body);
          _reportData = List.from(_allData);
        });
      } else {
        CustomToast.showError(context, "Failed to load report");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToExcel() async {
    if (_allData.isEmpty) return;

    var excel = Excel.createExcel();
    Sheet sheetObject = excel["Upgrade Plan"];
    excel.delete('Sheet1');

    sheetObject.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Upgraded Plan'),
      TextCellValue('Date'),
      TextCellValue('Amount Paid'),
    ]);

    for (var row in _allData) {
      sheetObject.appendRow([
        TextCellValue(row['student']?.toString() ?? ''),
        TextCellValue(row['plan']?.toString() ?? ''),
        TextCellValue(row['date']?.toString() ?? ''),
        TextCellValue(row['amount']?.toString() ?? ''),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${directory.path}/Upgrade_Plan_Report_$timestamp.xlsx');
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(file.path);
      CustomToast.showSuccess(context, "Exported!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Upgrade Plan Report",
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _allData.isEmpty ? null : _exportToExcel,
            tooltip: "Export to Excel",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CustomLoader())
                : _reportData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _reportData.length,
                        itemBuilder: (context, index) => _buildReportCard(_reportData[index]),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Board", _selectedBoard, AcademicConstants.boards, (val) {
                  setState(() {
                    _selectedBoard = val;
                    _selectedStd = null;
                    _fetchData();
                  });
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  "Std",
                  _selectedStd,
                  _selectedBoard == null ? [] : AcademicConstants.standards[_selectedBoard!] ?? [],
                  (val) {
                    setState(() {
                      _selectedStd = val;
                      _fetchData();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Medium", _selectedMedium, AcademicConstants.mediums, (val) {
                  setState(() {
                    _selectedMedium = val;
                    _fetchData();
                  });
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown("Stream", _selectedStream, ["Science", "Commerce", "None"], (val) {
                  setState(() {
                    _selectedStream = val;
                    _fetchData();
                  });
                }),
              ),
            ],
          ),
          if (_selectedBoard != null || _selectedStd != null || _selectedMedium != null || _selectedStream != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedBoard = null;
                    _selectedStd = null;
                    _selectedMedium = null;
                    _selectedStream = null;
                    _searchController.clear();
                    _fetchData();
                  });
                },
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

  Widget _buildReportCard(dynamic row) {
    if (_searchQuery.isNotEmpty) {
      final nameStr = row['student'].toString().toLowerCase();
      if (!nameStr.contains(_searchQuery.toLowerCase())) {
        return const SizedBox.shrink();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student Name",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        row['student'] ?? 'Unknown',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    row['amount'] ?? '-',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upgraded Plan",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      row['plan'] ?? 'Unknown',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Date",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      row['date'] ?? '-',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upgrade_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No upgrade plan records found",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
