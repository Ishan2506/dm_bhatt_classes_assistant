import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class UpgradePlanReportScreen extends StatefulWidget {
  const UpgradePlanReportScreen({super.key});

  @override
  State<UpgradePlanReportScreen> createState() => _UpgradePlanReportScreenState();
}

class _UpgradePlanReportScreenState extends State<UpgradePlanReportScreen> {
  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;

  // Mock Report State
  late List<Map<String, dynamic>> _allData;
  late List<Map<String, dynamic>> _reportData;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    _allData = [
      {
        "student": "Aakash Patel",
        "plan": "Class 12th Science",
        "date": "2026-03-24",
        "amount": "₹999",
      },
      {
        "student": "Ravi Kumar",
        "plan": "Class 11th Commerce",
        "date": "2026-03-22",
        "amount": "₹1,499",
      },
      {
        "student": "Sneha Joshi",
        "plan": "Class 10th Board Package",
        "date": "2026-03-15",
        "amount": "₹899",
      },
    ];
    _reportData = List.from(_allData);
  }

  void _applyFilters() {
    if (_selectedBoard == null || _selectedStd == null || _selectedMedium == null) {
      CustomToast.showError(context, "Please select at least Board, Std, and Medium to fetch the report.");
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          final query = _searchController.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            _reportData = _allData.where((r) => 
                r['student'].toString().toLowerCase().contains(query)
            ).toList();
          } else {
            _reportData = List.from(_allData)..shuffle();
          }
          _isLoading = false;
        });
        CustomToast.showSuccess(context, "Upgrade Plan Report updated.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          "Upgrade Plan Report",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildReportList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Board", AcademicConstants.boards, _selectedBoard, (val) {
                  setState(() => _selectedBoard = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown("Std", _selectedBoard != null ? (AcademicConstants.standards[_selectedBoard!] ?? []) : [], _selectedStd, (val) {
                  setState(() {
                    _selectedStd = val;
                    if (val != "11" && val != "12") _selectedStream = null;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Medium", AcademicConstants.mediums, _selectedMedium, (val) {
                  setState(() => _selectedMedium = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: (_selectedStd == "11" || _selectedStd == "12")
                    ? _buildFilterDropdown("Stream", ["Science", "Commerce", "Arts"], _selectedStream, (val) {
                        setState(() => _selectedStream = val);
                      })
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search by Student Name",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade900, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text("Fetch Report", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue.shade900),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReportList() {
    if (_reportData.isEmpty) {
      return Center(
        child: Text("No upgrade records found for this criteria.", 
          style: GoogleFonts.poppins(color: Colors.grey.shade600)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final record = _reportData[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade700.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.amber.shade700.withOpacity(0.2), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _showUpgradeDetailView(context, record);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade700, size: 24),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['student'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record['plan'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "on ${record['date']}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  record['amount'],
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
    );
  }

  void _showUpgradeDetailView(BuildContext context, Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Icon(Icons.auto_awesome_rounded, size: 64, color: Colors.amber.shade500),
              const SizedBox(height: 16),
              Text("Standard Upgrade Details", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildDetailRow("Student Name", record['student'], Icons.person, Colors.blue),
              _buildDetailRow("Upgraded Standard", record['plan'], Icons.school_rounded, Colors.green),
              _buildDetailRow("Date Authorized", record['date'], Icons.calendar_today, Colors.orange),
              _buildDetailRow("Amount Paid", record['amount'], Icons.currency_rupee_rounded, Colors.amber.shade700),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Close", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
