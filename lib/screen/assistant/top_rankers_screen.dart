import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopRankersScreen extends StatefulWidget {
  const TopRankersScreen({super.key});

  @override
  State<TopRankersScreen> createState() => _TopRankersScreenState();
}

class _TopRankersScreenState extends State<TopRankersScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = false;
  List<dynamic> _allRankers = [];

  // --- SELECTION STATE ---
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;

  // Dropdown Options
  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];

  // --- ADD/EDIT FORM CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  
  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchRankers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _marksController.dispose();
    _rankController.dispose();
    super.dispose();
  }

  Future<void> _fetchRankers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAllTopRankers();
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _allRankers = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
         if (!mounted) return;
         setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC ---

  List<dynamic> _getFilteredRankers() {
    if (_selectedStandard == null || _selectedMedium == null) {
      return [];
    }
    // Check stream requirement for 11/12
    if ((_selectedStandard == "11" || _selectedStandard == "12") && _selectedStream == null) {
      return [];
    }

    return _allRankers.where((r) {
      final stdMatch = r['standard'] == _selectedStandard;
      final medMatch = r['medium'] == _selectedMedium;
      
      bool streamMatch = true;
      if (_selectedStandard == "11" || _selectedStandard == "12") {
        streamMatch = r['stream'] == _selectedStream;
      }
      
      return stdMatch && medMatch && streamMatch;
    }).toList();
  }

  void _showAddEditDialog({Map<String, dynamic>? ranker}) {
    // Validation: Must select Filters first to know where to add
    // OR allow selecting in dialog. Let's force selection on screen first for simplicity & context.
    if (_selectedStandard == null || _selectedMedium == null) {
      CustomToast.showError(context, "Please select Standard and Medium first.");
      return;
    }
    if ((_selectedStandard == "11" || _selectedStandard == "12") && _selectedStream == null) {
      CustomToast.showError(context, "Please select a Stream first.");
      return;
    }

    _isEditing = ranker != null;
    _editingId = ranker?['_id'];
    
    // Pre-fill or Clear
    if (_isEditing) {
      _nameController.text = ranker!['studentName'] ?? "";
      _subjectController.text = ranker['subject'] ?? "";
      _rankController.text = ranker['rank'] ?? "";
      _marksController.text = ranker['percentage'] ?? "";
    } else {
      _nameController.clear();
      _subjectController.clear();
      _rankController.clear();
      _marksController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
                _isEditing ? "Edit Top Ranker" : "Add Top Ranker",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Std $_selectedStandard • $_selectedMedium${(_selectedStandard == "11" || _selectedStandard == "12") ? " • $_selectedStream" : ""}",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Student Name", Icons.person),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: _inputDecoration("Subject", Icons.book),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rankController,
                      decoration: _inputDecoration("Rank (e.g. 1st)", Icons.emoji_events),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                decoration: _inputDecoration("Marks/Percentage", Icons.grade),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRanker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _isEditing ? "Update Ranker" : "Add Ranker",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRanker() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context); // Close sheet immediately
      setState(() => _isLoading = true);

      try {
        if (_isEditing) {
          final response = await ApiService.updateTopRanker(
            id: _editingId!,
            studentName: _nameController.text,
            percentage: _marksController.text, // Using marks/percentage field
            subject: _subjectController.text,
            rank: _rankController.text,
            standard: _selectedStandard!,
            medium: _selectedMedium!,
            stream: (_selectedStandard == "11" || _selectedStandard == "12") ? _selectedStream : "-",
          );
          
          if (response.statusCode == 200) {
            if (!mounted) return;
            CustomToast.showSuccess(context, "Ranker Updated Successfully");
            _fetchRankers();
          } else {
            if (!mounted) return;
            CustomToast.showError(context, "Failed: ${response.body}");
          }
        } else {
          final response = await ApiService.createTopRanker(
            studentName: _nameController.text,
            percentage: _marksController.text,
            subject: _subjectController.text,
            rank: _rankController.text,
            standard: _selectedStandard!,
            medium: _selectedMedium!,
            stream: (_selectedStandard == "11" || _selectedStandard == "12") ? _selectedStream : "-",
          );

          if (response.statusCode == 201) {
            if (!mounted) return;
            CustomToast.showSuccess(context, "Ranker Added Successfully");
            _fetchRankers();
          } else {
            if (!mounted) return;
            CustomToast.showError(context, "Failed: ${response.body}");
          }
        }
      } catch (e) {
        if (!mounted) return;
        CustomToast.showError(context, "Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRanker(String id) async {
    // Confirmation Dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Ranker"),
        content: const Text("Are you sure you want to delete this ranker?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.deleteTopRanker(id);
        if (response.statusCode == 200) {
          CustomToast.showSuccess(context, "Deleted Successfully");
          _fetchRankers();
        } else {
          CustomToast.showError(context, "Failed to delete");
        }
      } catch (e) {
         CustomToast.showError(context, "Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade900),
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRankers = _getFilteredRankers();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Manage Top Rankers",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Ranker", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: _isLoading 
        ? const Center(child: CustomLoader()) 
        : Column(
          children: [
            // FILTERS SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Category", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Standard", _standards, _selectedStandard, (v) {
                          setState(() {
                            _selectedStandard = v;
                            // Reset stream if changed from 11/12 to lower std
                            if (_selectedStandard != "11" && _selectedStandard != "12") {
                              _selectedStream = null;
                            } else {
                              _selectedStream = null; // Reset selection anyway when std changes
                            }
                          });
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown("Medium", _mediums, _selectedMedium, (v) => setState(() => _selectedMedium = v)),
                      ),
                    ],
                  ),
                  
                  if (_selectedStandard == "11" || _selectedStandard == "12") ...[
                    const SizedBox(height: 12),
                    _buildDropdown("Stream", _streams, _selectedStream, (v) => setState(() => _selectedStream = v)),
                  ]
                ],
              ),
            ),

            // LIST SECTION
            Expanded(
              child: (_selectedStandard == null || _selectedMedium == null) || 
                     ((_selectedStandard == "11" || _selectedStandard == "12") && _selectedStream == null)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list, size: 64, color: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade100),
                        const SizedBox(height: 16),
                        Text(
                          "Please select filters to view rankers",
                          style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  )
                : filteredRankers.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No Top Rankers added yet for this category.",
                              style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRankers.length,
                        itemBuilder: (context, index) {
                          return _buildRankerCard(filteredRankers[index]);
                        },
                      ),
            ),
          ],
        ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
      style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
      dropdownColor: theme.cardColor,
    );
  }

  Widget _buildRankerCard(Map<String, dynamic> ranker) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = Colors.blue.shade800; // Static color since we don't save per-user color preference

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: color.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    child: Text(
                      ranker['studentName'][0].toUpperCase(), 
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${ranker['subject']} • ${ranker['rank']}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ranker['studentName'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        "${ranker['percentage']}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditDialog(ranker: ranker),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteRanker(ranker['_id']),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
