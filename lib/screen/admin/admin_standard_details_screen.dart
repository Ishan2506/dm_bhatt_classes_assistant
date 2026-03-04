import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class AdminStandardDetailsScreen extends StatefulWidget {
  final String standard;
  const AdminStandardDetailsScreen({super.key, required this.standard});

  @override
  State<AdminStandardDetailsScreen> createState() => _AdminStandardDetailsScreenState();
}

class _AdminStandardDetailsScreenState extends State<AdminStandardDetailsScreen> {
  bool _isLoading = true;
  List<dynamic> _boardStats = [];
  List<dynamic> _streamStats = [];
  List<dynamic> _mediumStats = [];
  List<dynamic> _studentStats = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailedStats();
  }

  Future<void> _fetchDetailedStats() async {
    try {
      final response = await ApiService.getStandardDetailedStats(widget.standard);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _boardStats = data['boardStats'] ?? [];
          _streamStats = data['streamStats'] ?? [];
          _mediumStats = data['mediumStats'] ?? [];
          _studentStats = data['studentStats'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching detailed stats: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text("Standard ${widget.standard} Details", 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: "Analysis"),
              Tab(text: "Students"),
            ],
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: _isLoading 
          ? const Center(child: CustomLoader())
          : TabBarView(
              children: [
                _buildAnalysisTab(colorScheme),
                _buildStudentsTab(colorScheme),
              ],
            ),
      ),
    );
  }

  Widget _buildAnalysisTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard("Board-wise Collection", _boardStats, "board", Icons.dashboard_customize_outlined, colorScheme),
          const SizedBox(height: 16),
          _buildStatCard("Stream-wise Collection", _streamStats, "stream", Icons.trending_up, colorScheme),
          const SizedBox(height: 16),
          _buildStatCard("Medium-wise Collection", _mediumStats, "medium", Icons.language, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, List<dynamic> stats, String key, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 32),
          if (stats.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text("No records found", style: GoogleFonts.poppins(color: Colors.grey)),
            ))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              itemBuilder: (context, idx) {
                final item = stats[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item[key] == "None" ? "Standard ${widget.standard}" : (item[key] ?? "Unknown"), 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)
                        ),
                      ),
                      Text("₹${item['sales']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(ColorScheme colorScheme) {
    if (_studentStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("No students found", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studentStats.length,
      itemBuilder: (context, index) {
        final student = _studentStats[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            title: Text(student['name'] ?? "Unknown", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "${student['board']} | ${student['medium']} | ${student['stream']}\n${student['phone']}", 
                style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${student['amount']}", 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 18)),
                Text("Total Paid", style: GoogleFonts.poppins(fontSize: 10, color: colorScheme.primary.withOpacity(0.7))),
              ],
            ),
          ),
        );
      },
    );
  }
}
