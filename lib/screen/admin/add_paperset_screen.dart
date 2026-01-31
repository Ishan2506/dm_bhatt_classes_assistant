import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  String? _selectedStandard;
  String? _selectedStream = 'None'; // Default

  final List<String> _subjects = ["Maths", "Science", "English", "Gujarati", "SS", "Computer"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _standards = ["8", "9", "10", "11", "12"];
  final List<String> _streams = ["None", "Science", "General"];

  // Mock History Data
  final List<Map<String, String>> _history = [
    {"name": "Maths_24Jan2024", "date": "24 Jan 2024", "subject": "Maths", "medium": "English"},
    {"name": "Science_20Jan2024", "date": "20 Jan 2024", "subject": "Science", "medium": "Gujarati"},
  ];

  Future<void> _createPaperSet() async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {
      final response = await ApiService.createPaperSet(
        examName: _examNameController.text,
        date: _selectedDate!.toIso8601String(),
        subject: _selectedSubject!,
        medium: _selectedMedium!,
        standard: _selectedStandard!,
        stream: _selectedStream ?? "None",
      );

      Navigator.pop(context); // Hide loader

      if (response.statusCode == 201) {
        CustomToast.showSuccess(context, "Paper Set Created Successfully!");
        // Reset
        setState(() {
          _examNameController.clear();
          _dateController.clear();
          _selectedSubject = null;
          _selectedMedium = null;
          _selectedStandard = null;
          _selectedStream = "None";
          _selectedDate = null;
        });
      } else {
        CustomToast.showError(context, "Failed: ${response.body}");
      }
    } catch (e) {
      Navigator.pop(context);
      CustomToast.showError(context, "Error: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Manage Paper Set",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: const TabBar(
             labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Create New"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Create Form
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildSectionTitle("Exam Details"),
                     const SizedBox(height: 24),

                     // Date Picker
                    _buildTapField(
                      controller: _dateController,
                      label: "Date",
                      icon: Icons.calendar_today,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    _buildDropdown(
                      label: "Subject",
                      icon: Icons.book_outlined,
                      value: _selectedSubject,
                      items: _subjects,
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
                      items: _mediums,
                      onChanged: (val) {
                        setState(() => _selectedMedium = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Standard Dropdown (NEW)
                    _buildDropdown(
                      label: "Standard",
                      icon: Icons.class_outlined,
                      value: _selectedStandard,
                      items: _standards,
                      onChanged: (val) {
                        setState(() => _selectedStandard = val);
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
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                      decoration: InputDecoration(
                        labelText: "Exam Name (Auto-Suggested)",
                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Subject_Date",
                        prefixIcon: Icon(Icons.edit_note, color: Colors.blue.shade900),
                         filled: true,
                        fillColor: Colors.blue.shade50,
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
                        onPressed: () {
                           if (_formKey.currentState!.validate()) {
                              if (_selectedStandard == null) {
                                CustomToast.showError(context, "Please select Standard");
                                return;
                              }
                              // Call API
                              _createPaperSet();
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: Text(
                          "Create Paper Set",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab 2: History List
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
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
                    title: Text(item['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("${item['subject']} • ${item['date']}", style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          ],
        ),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
             labelStyle: GoogleFonts.poppins(color: Colors.grey),
            prefixIcon: Icon(icon, color: Colors.blue.shade900),
            filled: true,
            fillColor: Colors.grey.shade50,
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
        color: Colors.grey.shade50,
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
                child: Text(item, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
