import 'package:dm_bhatt_classes_new/screen/admin/paper_set_detail_screen.dart';
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

  // Mock Data for Paper Set Logs
  final List<Map<String, String>> _paperSetLogs = [
    {
      "assistant": "Ravi Patel",
      "action": "Collected",
      "exam": "Maths Unit 1",
      "status": "Checked",
      "date": "22 Jan 2024",
      "time": "11:00 AM"
    },
    {
      "assistant": "Priya Shah",
      "action": "Distributed",
      "exam": "Science Ch 5",
      "status": "Pending",
      "date": "21 Jan 2024",
      "time": "02:30 PM"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Activity Log",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue.shade900,
          tabs: const [
            Tab(text: "Student Log"),
            Tab(text: "Paper Set Log"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLogList(_studentLogs, isStudentLog: true),
          _buildLogList(_paperSetLogs, isStudentLog: false),
        ],
      ),
    );
  }

  Widget _buildLogList(List<Map<String, String>> logs, {required bool isStudentLog}) {
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
                            examName: log['exam'] ?? "Unknown Exam",
                            date: log['date'] ?? "",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
            color: Colors.white,
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
                  backgroundColor: _getActionColor(log['action'] ?? "").withOpacity(0.1),
                  child: Icon(
                    isStudentLog ? Icons.person : Icons.description,
                    color: _getActionColor(log['action'] ?? ""),
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
                            log['assistant'] ?? "",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            log['date'] ?? "",
                            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                          children: [
                            TextSpan(
                                text: "${log['action']} ",
                                style: TextStyle(color: _getActionColor(log['action'] ?? ""), fontWeight: FontWeight.w600)),
                            TextSpan(text: isStudentLog ? "student " : "paper set "),
                            TextSpan(
                                text: isStudentLog ? log['student'] : log['exam'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                             log['status'] ?? "",
                             style: GoogleFonts.poppins(
                               fontSize: 12,
                               color: log['status'] == 'Checked' ? Colors.green : Colors.orange,
                               fontWeight: FontWeight.w600
                             ),
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
