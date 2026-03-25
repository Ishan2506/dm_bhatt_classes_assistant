import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GenerateRedeemCodeScreen extends StatefulWidget {
  const GenerateRedeemCodeScreen({super.key});

  @override
  State<GenerateRedeemCodeScreen> createState() => _GenerateRedeemCodeScreenState();
}

class _GenerateRedeemCodeScreenState extends State<GenerateRedeemCodeScreen> {
  // Input State
  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedCreator;
  final TextEditingController _discountController = TextEditingController();

  final List<String> _creators = ['DMBHATT', 'ANKIT', 'RAVI', 'HARDIK', 'KEYUR', 'DEEP'];

  // History State
  List<Map<String, dynamic>> _history = [];
  final TextEditingController _searchController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('redeem_code_history');
    if (historyJson != null) {
      final List<dynamic> decodedList = jsonDecode(historyJson);
      setState(() {
        _history = List<Map<String, dynamic>>.from(decodedList);
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('redeem_code_history', jsonEncode(_history));
  }

  @override
  void dispose() {
    _discountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _generateCode() {
    if (_selectedBoard == null || _selectedStd == null || _selectedMedium == null || _selectedCreator == null || _discountController.text.isEmpty) {
      CustomToast.showError(context, "Please fill all required fields");
      return;
    }

    final discountValue = int.tryParse(_discountController.text);
    if (discountValue == null || discountValue <= 0 || discountValue > 60) {
      CustomToast.showError(context, "Discount must be a valid number between 1 and 60.");
      return;
    }

    if ((_selectedStd == "11" || _selectedStd == "12") && _selectedStream == null) {
      CustomToast.showError(context, "Please select a stream for Std 11/12");
      return;
    }

    // Generate a random 8-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String code = String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    setState(() {
      _history.insert(0, {
        'code': code,
        'creator': _selectedCreator,
        'discount': _discountController.text,
        'board': _selectedBoard,
        'std': _selectedStd,
        'medium': _selectedMedium,
        'stream': _selectedStream,
        'used': false,
        'date': DateTime.now().toIso8601String(),
      });
      // Clear inputs after success
      _selectedBoard = null;
      _selectedStd = null;
      _selectedMedium = null;
      _selectedStream = null;
      _selectedCreator = null;
      _discountController.clear();
    });

    _saveHistory();
    CustomToast.showSuccess(context, "Code Generated: $code");
  }

  void _confirmDelete(Map<String, dynamic> row) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Code", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete the code '${row['code']}'?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _history.remove(row);
              });
              _saveHistory();
              CustomToast.showSuccess(context, "Code deleted successfully");
            },
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCode(Map<String, dynamic> row) async {
    CustomToast.showSuccess(context, "Preparing voucher image...");
    try {
      final image = await _screenshotController.captureFromWidget(
        _buildShareableVoucher(row),
        delay: const Duration(milliseconds: 200),
        context: context,
      );
      
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/voucher_${row['code']}.png').create();
      await imagePath.writeAsBytes(image);
      
      await Share.shareXFiles([XFile(imagePath.path)], text: 'Here is your ${row['discount']}% discount code: ${row['code']}');
    } catch (e) {
      CustomToast.showError(context, "Error formatting voucher: $e");
    }
  }

  Widget _buildShareableVoucher(Map<String, dynamic> row) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF0D47A1), width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('ic_launcher.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.school, size: 40, color: Color(0xFF0D47A1))),
                const SizedBox(width: 12),
                Text("DM Bhatt Classes", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
              ],
            ),
            const SizedBox(height: 24),
            Text(row['code'], style: GoogleFonts.robotoMono(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue.shade900, letterSpacing: 4)),
            const SizedBox(height: 12),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
               child: Text("${row['discount']}% DISCOUNT", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green.shade800)),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                 if (row['board'] != null) _buildBadge(row['board']),
                 _buildBadge("Std ${row['std']}"),
                 if (row['medium'] != null) _buildBadge(row['medium']),
                 if (row['stream'] != null) _buildBadge(row['stream']),
              ],
            ),
            const SizedBox(height: 30),
            Text("Use this code during checkout in the App", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text("Generate Redeem Code", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Create Code"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Target Audience", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown("Board", _selectedBoard, AcademicConstants.boards, (v) => setState(() { _selectedBoard = v; _selectedStd = null; }))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown("Std", _selectedStd, _selectedBoard != null ? (AcademicConstants.standards[_selectedBoard!] ?? []) : [], (v) => setState(() => _selectedStd = v))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown("Medium", _selectedMedium, AcademicConstants.mediums, (v) => setState(() => _selectedMedium = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown("Stream", _selectedStream, ["Science", "Commerce"], (v) => setState(() => _selectedStream = v))),
            ],
          ),
          const SizedBox(height: 24),
          Text("Code Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown("Created By", _selectedCreator, _creators, (v) => setState(() => _selectedCreator = v))),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Discount %",
                    hintText: "e.g. 50",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _generateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1), // Primary Theme Color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Generate Code", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14)),
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final filtered = _history.where((item) {
      if (_searchQuery.isEmpty) return true;
      final matchCode = item['code']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchCreator = item['creator']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      return matchCode || matchCreator;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by Code or Creator...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                  : null,
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text("No codes generated yet", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final row = filtered[index];
                    final isUsed = row['used'] == true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      row['code'],
                                      style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0D47A1)),
                                    ),
                                    if (!isUsed) ...[
                                      const SizedBox(width: 12),
                                      InkWell(
                                        onTap: () => _shareCode(row),
                                        child: const Icon(Icons.share_outlined, color: Colors.blue, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      InkWell(
                                        onTap: () => _confirmDelete(row),
                                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                      ),
                                    ],
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUsed ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isUsed ? "USED" : "UNUSED",
                                    style: GoogleFonts.poppins(
                                      color: isUsed ? Colors.red.shade900 : Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.discount_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("${row['discount']}% Discount", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("By: ${row['creator']}", style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                              ],
                            ),
                            const Divider(height: 20),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildBadge(row['board'] ?? "-"),
                                _buildBadge("Std ${row['std']}"),
                                _buildBadge(row['medium'] ?? "-"),
                                if (row['stream'] != null) _buildBadge(row['stream']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(row['date'])),
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                              ),
                            )
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

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue.shade900)),
    );
  }
}
