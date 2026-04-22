import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:dm_bhatt_classes_new/screen/admin/admin_standard_details_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

enum ChartType { pie, bar }

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  int _totalSales = 0;
  List<Map<String, dynamic>> _subjectSales = [];
  List<Map<String, dynamic>> _standardSales = [];
  late TabController _tabController;
  ChartType _chartType = ChartType.pie;

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
      } else if (response.statusCode == 403) {
        setState(() {
          _isLoading = false;
          _error = "Access Denied. Super Admin only.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = "Failed to load dashboard data.";
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        _isLoading = false;
        _error = "An error occurred while loading stats.";
      });
    }
  }

  Color _getSubjectColor(String? subject) {
    final subjects = ["maths", "science", "english", "gujarati", "social science", "hindi", "sanskrit", "computer"];
    final colors = [
      Colors.green, 
      Colors.lightGreen, 
      Colors.lime, 
      Colors.teal, 
      Colors.cyan, 
      Colors.lightBlue, 
      Colors.blue,
      Colors.indigo
    ];
    int index = subjects.indexOf(subject?.toLowerCase() ?? "");
    if (index != -1) return colors[index % colors.length];
    return colors[(subject?.hashCode ?? 0).abs() % colors.length];
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
        body: const Center(child: CustomLoader()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.poppins(fontSize: 16, color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchStats,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                  color: colorScheme.primary,
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
                  PopupMenuButton<ChartType>(
                    icon: Icon(
                      _chartType == ChartType.pie ? Icons.pie_chart_rounded : Icons.bar_chart_rounded,
                      color: colorScheme.primary.withOpacity(0.8),
                    ),
                    onSelected: (ChartType result) {
                      setState(() {
                        _chartType = result;
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<ChartType>>[
                      PopupMenuItem<ChartType>(
                        value: ChartType.pie,
                        child: Row(
                          children: [
                            const Icon(Icons.pie_chart_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text('Pie Chart', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem<ChartType>(
                        value: ChartType.bar,
                        child: Row(
                          children: [
                            const Icon(Icons.bar_chart_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text('Bar Chart', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                : Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: _chartType == ChartType.pie 
                        ? PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: stats.map((item) {
                                final percentage = item['percentage'] as double;
                                final isLarge = percentage > 0.05;
                                return PieChartSectionData(
                                  color: item['color'],
                                  value: percentage,
                                  title: isLarge ? "${(percentage * 100).toStringAsFixed(1)}%" : "",
                                  radius: 50,
                                  titleStyle: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 1.0,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final subject = stats[group.x.toInt()][labelKey];
                                    final sales = stats[group.x.toInt()]['sales'];
                                    return BarTooltipItem(
                                      '$subject\n₹$sales',
                                      GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= stats.length) return const SizedBox.shrink();
                                      final item = stats[value.toInt()];
                                      String labelStr = item[labelKey].toString();
                                      if (labelStr.length > 5) {
                                        labelStr = labelStr.substring(0, 5) + "..";
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          labelStr,
                                          style: GoogleFonts.poppins(fontSize: 10, color: colorScheme.onSurfaceVariant),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: stats.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: item['percentage'] as double,
                                      color: item['color'],
                                      width: 20,
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: stats.map((item) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item[labelKey],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
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
                return InkWell(
                  onTap: labelKey == "standard" ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminStandardDetailsScreen(
                          standard: item[labelKey].toString(),
                        ),
                      ),
                    );
                  } : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
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
                        if (labelKey == "standard") ...[
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}
