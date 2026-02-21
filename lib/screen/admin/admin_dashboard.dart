import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _totalSales = 0;
  List<Map<String, dynamic>> _subjectSales = [];
  List<Map<String, dynamic>> _standardSales = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService.getDashboardStats();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalSales = data['totalSales'] ?? 0;
          
          final List<dynamic> subjectData = data['subjectSales'] ?? [];
          _subjectSales = subjectData.map((item) {
            return {
              "subject": item['subject'] ?? "Unknown",
              "sales": item['sales'] ?? 0,
              "percentage": (item['percentage'] ?? 0).toDouble(),
              "color": _getSubjectColor(item['subject']),
            };
          }).toList();

          final List<dynamic> standardData = data['standardSales'] ?? [];
          _standardSales = standardData.map((item) {
            return {
              "standard": item['standard'] ?? "Unknown",
              "sales": item['sales'] ?? 0,
              "percentage": (item['percentage'] ?? 0).toDouble(),
              "color": _getStandardColor(item['standard']),
            };
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getSubjectColor(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'science': return Colors.blue;
      case 'maths': return Colors.green;
      case 'english': return Colors.orange;
      case 'gujarati': return Colors.purple;
      case 'social science': return Colors.brown;
      case 'hindi': return Colors.red;
      case 'sanskrit': return Colors.teal;
      default: return Colors.blueGrey;
    }
  }

  Color _getStandardColor(String? standard) {
    // Generate colors based on standard index or name
    final standards = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime
    ];
    int index = standards.indexOf(standard ?? "");
    if (index != -1) return colors[index % colors.length];
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text("Admin Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CustomLoader()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchStats();
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Sales Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.9),
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.currency_rupee, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Sales",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${_totalSales.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Analysis Toggle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: "By Subject"),
                    Tab(text: "By Standard"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 650, // Slightly more height for better list visibility
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildStatsView("Subject Performance", _subjectSales, "subject", colorScheme),
                    _buildStatsView("Standard Performance", _standardSales, "standard", colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsView(String title, List<Map<String, dynamic>> stats, String labelKey, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bar Chart
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Comparison", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                  Icon(Icons.bar_chart_rounded, color: colorScheme.primary.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 24),
              stats.isEmpty 
                ? SizedBox(
                    height: 150,
                    child: Center(
                      child: Text("No data available", style: GoogleFonts.poppins(color: Colors.grey))
                    )
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: stats.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Tooltip(
                                 message: "₹${item['sales']}",
                                 child: AnimatedContainer(
                                   duration: const Duration(milliseconds: 500),
                                   width: 30,
                                   height: 150.0 * (item['percentage'] as double),
                                   decoration: BoxDecoration(
                                     color: item['color'],
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                 ),
                               ),
                              const SizedBox(height: 8),
                              Text(
                                item[labelKey], 
                                style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        // Detailed List
        Text(
          "Detailed Breakdown",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: stats.isEmpty
            ? Center(child: Text("No records found", style: GoogleFonts.poppins()))
            : ListView.builder(
              itemCount: stats.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = stats[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          labelKey == "standard" ? "Standard ${item[labelKey]}" : item[labelKey],
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        "₹${item['sales']}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${((item['percentage'] as double) * 100).toStringAsFixed(1)}%)",
                        style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}
