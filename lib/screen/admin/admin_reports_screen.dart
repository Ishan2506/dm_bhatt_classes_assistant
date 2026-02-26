import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _allResults = [];
  List<dynamic> _studentReports = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final resAll = await ApiService.getExamReports();
      final resStudents = await ApiService.getStudentReports();

      if (resAll.statusCode == 200 && resStudents.statusCode == 200) {
        setState(() {
          _allResults = jsonDecode(resAll.body);
          _studentReports = jsonDecode(resStudents.body);
        });
      } else {
        CustomToast.showError(context, "Failed to load report data");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Exam Reports'];
    excel.delete('Sheet1');

    // Headers
    sheetObject.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Phone'),
      TextCellValue('Standard'),
      TextCellValue('Medium'),
      TextCellValue('Exam Title'),
      TextCellValue('Obtained Marks'),
      TextCellValue('Total Marks'),
      TextCellValue('Date'),
    ]);

    for (var row in _allResults) {
      sheetObject.appendRow([
        TextCellValue(row['studentName']?.toString() ?? ''),
        TextCellValue(row['studentPhone']?.toString() ?? ''),
        TextCellValue(row['std']?.toString() ?? ''),
        TextCellValue(row['medium']?.toString() ?? ''),
        TextCellValue(row['title']?.toString() ?? ''),
        IntCellValue(int.tryParse(row['obtainedMarks']?.toString() ?? '0') ?? 0),
        IntCellValue(int.tryParse(row['totalMarks']?.toString() ?? '0') ?? 0),
        TextCellValue(row['date'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(row['date'])) : ''),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      try {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/Exam_Reports_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(fileBytes);
        
        // Open/Share the file
        await OpenFilex.open(file.path);
        CustomToast.showSuccess(context, "Report exported and opened!");
      } catch (e) {
        CustomToast.showError(context, "Export failed: $e");
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports & Analytics", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]))),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _allResults.isEmpty ? null : _exportToExcel,
            tooltip: "Export to Excel",
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All Submissions", icon: Icon(Icons.list_alt)),
            Tab(text: "Student Wise", icon: Icon(Icons.person_search)),
          ],
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomLoader())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllResultsTab(),
                _buildStudentWiseTab(),
              ],
            ),
    );
  }

  Widget _buildAllResultsTab() {
    final filtered = _allResults.where((r) {
      final name = r['studentName']?.toString().toLowerCase() ?? "";
      final phone = r['studentPhone']?.toString().toLowerCase() ?? "";
      final title = r['title']?.toString().toLowerCase() ?? "";
      return name.contains(_searchQuery.toLowerCase()) || 
             phone.contains(_searchQuery.toLowerCase()) || 
             title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState("No submissions found")
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final row = filtered[index];
                    return _buildResultCard(row);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentWiseTab() {
    final filtered = _studentReports.where((s) {
      final name = s['name']?.toString().toLowerCase() ?? "";
      final phone = s['phone']?.toString().toLowerCase() ?? "";
      return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState("No students found")
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return _buildStudentCard(student);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search by name, phone or exam...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildResultCard(dynamic row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(row['studentName']?[0].toUpperCase() ?? 'S', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
        ),
        title: Text(row['studentName'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Exam: ${row['title']}"),
            Text("Score: ${row['obtainedMarks']} / ${row['totalMarks']}"),
            Text("Date: ${row['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(row['date'])) : 'N/A'}", style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text("Std ${row['std'] ?? '-'}", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(student['name']?[0].toUpperCase() ?? 'S', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
        ),
        title: Text(student['name'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text("${student['totalExams']} Exams | Avg Score: ${student['avgMarks']?.toStringAsFixed(1)}"),
        children: [
          const Divider(),
          ...(student['exams'] as List).map((exam) => ListTile(
            dense: true,
            title: Text(exam['title'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(exam['date']))),
            trailing: Text("${exam['score']} / ${exam['total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          )).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
