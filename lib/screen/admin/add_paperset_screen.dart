import 'dart:convert';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class AddPapersetScreen extends StatefulWidget {
  const AddPapersetScreen({super.key});

  @override
  State<AddPapersetScreen> createState() => _AddPapersetScreenState();
}

class _AddPapersetScreenState extends State<AddPapersetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedSubject;
  String? _selectedMedium;
  DateTime? _selectedDate;
  
  bool _isEditing = false;
  int? _editingIndex;

  String? _selectedBoard;
  String? _selectedStandard;
  String? _selectedStream = 'None'; // Default

  final List<String> _streams = ["None", "Science", "General"];

  // Real Data
  List<dynamic> _paperSets = [];
  bool _isLoadingList = true;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    // TabController initialized in build via DefaultTabController? 
    // Wait, typical use is TabController in initState if using TabBar in AppBar bottom with a Controller.
    // The previous code used DefaultTabController in build (line 119). So no explicit controller needed if TabBarView uses DefaultTabController.
    // But for programmatic tab switching (Editor -> Form), we SHOULD use an explicit TabController.
    // I will switch to explicit TabController to support switching tabs on Edit.
    _tabController = TabController(length: 2, vsync: this);
    _fetchPaperSets();
  }

  @override 
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    _examNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaperSets() async {
    setState(() => _isLoadingList = true);
    try {
      final response = await ApiService.getAllPaperSets();
      if (response.statusCode == 200) {
        setState(() {
          _paperSets = jsonDecode(response.body);
          _isLoadingList = false;
        });
      } else {
        setState(() => _isLoadingList = false);
        CustomToast.showError(context, "Failed to load paper sets");
      }
    } catch (e) {
      setState(() => _isLoadingList = false);
      debugPrint("Error fetching paper sets: $e");
    }
  }

  Future<void> _createOrUpdatePaperSet() async {
    if (_formKey.currentState!.validate()) {
       if (_selectedBoard == null || _selectedStandard == null) {
         CustomToast.showError(context, "Please select Board and Standard");
         return;
       }
       
       showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (context) => const CustomLoader()
       );

       try {
         if (_isEditing && _editingId != null) {
            // Edit
            final response = await ApiService.editPaperSet(
              id: _editingId!,
              examName: _examNameController.text,
              board: _selectedBoard,
              date: _selectedDate!.toIso8601String(),
              subject: _selectedSubject,
              medium: _selectedMedium,
              standard: _selectedStandard,
              stream: _selectedStream,
            );
            
            Navigator.pop(context); // Hide loader

            if (response.statusCode == 200) {
              CustomToast.showSuccess(context, "Paper Set Updated Successfully");
              _resetForm();
              _fetchPaperSets();
            } else {
               CustomToast.showError(context, "Failed: ${response.body}");
            }

         } else {
            // Create
            final response = await ApiService.createPaperSet(
              examName: _examNameController.text,
              board: _selectedBoard!,
              date: _selectedDate!.toIso8601String(),
              subject: _selectedSubject!,
              medium: _selectedMedium!,
              standard: _selectedStandard!,
              stream: _selectedStream ?? "None",
            );

            Navigator.pop(context); // Hide loader

            if (response.statusCode == 201) {
              CustomToast.showSuccess(context, "Paper Set Created Successfully!");
              _resetForm();
              _fetchPaperSets();
            } else {
              CustomToast.showError(context, "Failed: ${response.body}");
            }
         }
       } catch (e) {
         Navigator.pop(context); // Hide loader
         CustomToast.showError(context, "Error: $e");
       }
    }
  }

  void _editPaperSet(int index) {
    final item = _paperSets[index];
    setState(() {
      _isEditing = true;
      _editingId = item['_id'];
      
      _examNameController.text = item['examName'] ?? "";
      _selectedBoard = item['board'];
      _selectedSubject = item['subject']; // Ensure item value matches dropdown list exactly
      _selectedMedium = item['medium'];
      _selectedStandard = item['standard'] ?? item['std']; // Backend might return 'std' or 'standard'
      _selectedStream = item['stream'] ?? "None";

      if (item['date'] != null) {
        try {
          _selectedDate = DateTime.parse(item['date']);
          _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        } catch (e) {
          debugPrint("Date parse error: $e");
        }
      }
    });

    // Check if dropdown values exist in lists, if not default to null or handle
    if (!AcademicConstants.boards.contains(_selectedBoard)) _selectedBoard = null;
    if (!AcademicConstants.mediums.contains(_selectedMedium)) _selectedMedium = null;
    if (_selectedBoard != null && !AcademicConstants.standards[_selectedBoard!]!.contains(_selectedStandard)) _selectedStandard = null;
    if (!AcademicConstants.subjects.containsKey("$_selectedBoard-$_selectedStandard") || !AcademicConstants.subjects["$_selectedBoard-$_selectedStandard"]!.contains(_selectedSubject)) _selectedSubject = null;
    if (!_streams.contains(_selectedStream)) _selectedStream = "None";

    _tabController.animateTo(0);
  }

  void _confirmDelete(int index) {
      final item = _paperSets[index];
      final String id = item['_id'];
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Delete Paper Set", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete ${item['examName']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                 Navigator.pop(ctx);
                 try {
                   final response = await ApiService.deletePaperSet(id);
                   if (response.statusCode == 200) {
                      CustomToast.showSuccess(context, "Deleted Successfully");
                      _fetchPaperSets();
                   } else {
                      CustomToast.showError(context, "Failed to delete");
                   }
                 } catch (e) {
                    CustomToast.showError(context, "Error: $e");
                 }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
            )
          ],
        ),
      );
  }

  void _updateExamName() {
    if (_selectedSubject != null && _selectedDate != null) {
      String formattedDate = DateFormat('ddMMMyyyy').format(_selectedDate!);
      setState(() {
        _examNameController.text = "${_selectedSubject}_$formattedDate";
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for editing
      lastDate: DateTime(2100),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _updateExamName();
    }
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingId = null;
      _examNameController.clear();
      _dateController.clear();
      _selectedBoard = null;
      _selectedSubject = null;
      _selectedMedium = null;
      _selectedStandard = null;
      _selectedStream = "None";
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Removed DefaultTabController to use explicit _tabController
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            "Manage Paper Set",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          elevation: 0,
          bottom: TabBar(
             controller: _tabController,
             labelColor: Colors.blue,
             unselectedLabelColor: Colors.grey,
             tabs: const [
               Tab(text: "Create New"),
               Tab(text: "History"),
             ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Create Form
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildSectionTitle(_isEditing ? "Edit Exam Details" : "Exam Details"),
                     const SizedBox(height: 24),
                     
                     // Date Picker
                    _buildTapField(
                      controller: _dateController,
                      label: "Date",
                      icon: Icons.calendar_today,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),

                    // Board Dropdown (NEW)
                    _buildDropdown(
                      label: "Board",
                      icon: Icons.school,
                      value: _selectedBoard,
                      items: AcademicConstants.boards,
                      onChanged: (val) {
                        setState(() {
                          _selectedBoard = val;
                          _selectedStandard = null;
                          _selectedSubject = null;
                        });
                        _updateExamName();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Standard Dropdown (NEW)
                    _buildDropdown(
                      label: "Standard",
                      icon: Icons.class_outlined,
                      value: _selectedStandard,
                      items: _selectedBoard == null ? [] : AcademicConstants.standards[_selectedBoard!] ?? [],
                      onChanged: (val) {
                        setState(() {
                           _selectedStandard = val;
                           _selectedSubject = null;
                        });
                        _updateExamName();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    _buildDropdown(
                      label: "Subject",
                      icon: Icons.book_outlined,
                      value: _selectedSubject,
                      items: (_selectedBoard == null || _selectedStandard == null) ? [] : AcademicConstants.subjects["$_selectedBoard-$_selectedStandard"] ?? [],
                      onChanged: (val) {
                        setState(() {
                          _selectedSubject = val;
                        });
                        _updateExamName();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Medium Dropdown
                    _buildDropdown(
                      label: "Medium",
                      icon: Icons.language,
                      value: _selectedMedium,
                      items: AcademicConstants.mediums,
                      onChanged: (val) {
                        setState(() => _selectedMedium = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stream Dropdown (NEW)
                    _buildDropdown(
                      label: "Stream",
                      icon: Icons.school_outlined,
                      value: _selectedStream,
                      items: _streams,
                      onChanged: (val) {
                        setState(() => _selectedStream = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Exam Name (Auto-Generated)
                    TextFormField(
                      controller: _examNameController,
                      readOnly: false,
                      style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                      decoration: InputDecoration(
                        labelText: "Exam Name (Auto-Suggested)",
                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Subject_Date",
                        prefixIcon: Icon(Icons.edit_note, color: Colors.blue.shade900),
                         filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createOrUpdatePaperSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: Text(
                          _isEditing ? "Update Paper Set" : "Create Paper Set",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: TextButton(
                            onPressed: _resetForm,
                            child: Text("Cancel Edit", style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Tab 2: History List
            _isLoadingList 
               ? const Center(child: CustomLoader()) 
               : _paperSets.isEmpty
                   ? Center(child: Text("No paper sets found", style: GoogleFonts.poppins(color: Colors.grey)))
                   : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _paperSets.length,
              itemBuilder: (context, index) {
                final item = _paperSets[index];
                
                // Format Date for display
                String displayDate = "Unknown Date";
                if (item['date'] != null) {
                    try {
                       displayDate = DateFormat('dd MMM yyyy').format(DateTime.parse(item['date']));
                    } catch (e) {
                       displayDate = item['date'];
                    }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                   color: Colors.grey.shade50,
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.description_outlined, color: Colors.orange.shade900),
                    ),
                    title: Text(item['examName'] ?? "Unnamed", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("${item['subject']} • $displayDate", style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPaperSet(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTapField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          validator: (v) => v!.isEmpty ? "Required" : null,
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
             labelStyle: GoogleFonts.poppins(color: Colors.grey),
            prefixIcon: Icon(icon, color: Colors.blue.shade900),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
             enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue.shade900),
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.grey),
              border: InputBorder.none,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (v) => v == null ? "Required" : null,
          ),
        ),
      ),
    );
  }
}
