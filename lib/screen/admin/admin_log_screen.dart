import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/screen/admin/paper_set_detail_screen.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogScreen extends StatefulWidget {
  const AdminLogScreen({super.key});

  @override
  State<AdminLogScreen> createState() => _AdminLogScreenState();
}

class _AdminLogScreenState extends State<AdminLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data for Student Logs
  final List<Map<String, String>> _studentLogs = [
    {
      "assistant": "Ravi Patel",
      "action": "Updated Student",
      "student": "Devarsh Shah",
      "date": "24 Jan 2024",
      "time": "10:30 AM"
    },
    {
      "assistant": "Priya Shah",
      "action": "Added Student",
      "student": "Rahul Verma",
      "date": "24 Jan 2024",
      "time": "09:15 AM"
    },
     {
      "assistant": "Ravi Patel",
      "action": "Deleted Student",
      "student": "Amit Kumar",
      "date": "23 Jan 2024",
      "time": "04:45 PM"
    },
  ];

  List<Map<String, dynamic>> _paperSetLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPaperSetLogs();
  }

  Future<void> _fetchPaperSetLogs() async {
    try {
      final response = await ApiService.getPaperSetLogs();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _paperSetLogs = data.map((item) => {
            "assistant": item['createdBy'] ?? "Unknown",
            "action": _parseAction(item['action']),
            "exam": item['examName'] ?? "Unknown Exam",
            "status": item['status'],
            "date": _formatDate(item['createdAt']),
            "time": _formatTime(item['createdAt']),
            "fullAction": item['action'], // For internal use if needed
          }).toList().cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error fetching logs: $e");
    }
  }

  String _parseAction(String? fullAction) {
    if (fullAction == null) return "";
    // If backend sends "Updated Status to Collected", we might just want "Collected" or the full string
    // Based on existing UI mock: "Collected", "Distributed"
    if (fullAction.contains("Collected")) return "Collected";
    if (fullAction.contains("Checked")) return "Checked";
    if (fullAction.contains("Rechecked")) return "Rechecked";
    return fullAction;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return "${dt.day} ${_getMonthName(dt.month)} ${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "";
     try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      String period = dt.hour >= 12 ? "PM" : "AM";
      int hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      if (hour == 0) hour = 12;
      String minute = dt.minute.toString().padLeft(2, '0');
      return "$hour:$minute $period";
    } catch (e) {
      return "";
    }
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (month >= 1 && month <= 12) return months[month - 1];
    return "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Activity Log",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: "Student Log"),
            Tab(text: "Paper Set Log"),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CustomLoader())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLogList(_studentLogs, isStudentLog: true),
                _buildLogList(_paperSetLogs, isStudentLog: false),
              ],
            ),
    );
  }

  Widget _buildLogList(List<Map<String, dynamic>> logs, {required bool isStudentLog}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return InkWell(
          onTap: () {
            if (!isStudentLog) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaperSetDetailScreen(
                    examName: (log['exam'] ?? "Unknown Exam").toString(),
                    date: (log['date'] ?? "").toString(),
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon / Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getActionColor((log['action'] ?? "").toString()).withOpacity(0.1),
                    child: Icon(
                      isStudentLog ? Icons.person : Icons.description,
                      color: _getActionColor((log['action'] ?? "").toString()),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (log['assistant'] ?? "").toString(),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              (log['date'] ?? "").toString(),
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                            children: [
                              TextSpan(
                                  text: "${log['action']} ",
                                  style: TextStyle(color: _getActionColor((log['action'] ?? "").toString()), fontWeight: FontWeight.w600)),
                              TextSpan(text: isStudentLog ? "student " : "paper set "),
                              TextSpan(
                                  text: (isStudentLog ? log['student'] : log['exam'])?.toString() ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                        ),
                        if (!isStudentLog) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: log['status'] == 'Checked' ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (log['status'] ?? "").toString(),
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: log['status'] == 'Checked' ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getActionColor(String action) {
    if (action.contains("Collected") || action.contains("Added")) return Colors.green;
    if (action.contains("Distributed") || action.contains("Updated")) return Colors.blue;
    if (action.contains("Deleted")) return Colors.red;
    return Colors.grey;
  }
}
