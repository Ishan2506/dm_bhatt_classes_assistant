import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
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

  final List<String> _subjects = ["Maths", "Science", "English", "Gujarati", "SS", "Computer"];
  final List<String> _mediums = ["English", "Gujarati"];

  // Mock History Data
  final List<Map<String, String>> _history = [
    {"name": "Maths_24Jan2024", "date": "24 Jan 2024", "subject": "Maths", "medium": "English"},
    {"name": "Science_20Jan2024", "date": "20 Jan 2024", "subject": "Science", "medium": "Gujarati"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _examNameController.dispose();
    _dateController.dispose();
    super.dispose();
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

  void _createOrUpdatePaperset() {
     if (_formKey.currentState!.validate()) {
         if (_isEditing) {
           CustomToast.showSuccess(context, "Paper Set Updated (Mock)");
           if (_editingIndex != null && _editingIndex! < _history.length) {
              setState(() {
                _history[_editingIndex!] = {
                  "name": _examNameController.text,
                  "date": _dateController.text,
                  "subject": _selectedSubject ?? "",
                  "medium": _selectedMedium ?? "",
                };
              });
           }
           _resetForm();
         } else {
           CustomToast.showSuccess(context, "Paper Set Created: ${_examNameController.text}");
           // In real app, refresh history here/add to list
           setState(() {
             _history.insert(0, {
                  "name": _examNameController.text,
                  "date": _dateController.text,
                  "subject": _selectedSubject ?? "",
                  "medium": _selectedMedium ?? "",
             });
           });
           _resetForm();
         }
     }
  }

  void _editPaperset(int index) {
     final item = _history[index];
     setState(() {
       _isEditing = true;
       _editingIndex = index;
       _examNameController.text = item['name'] ?? "";
       _dateController.text = item['date'] ?? "";
       _selectedSubject = item['subject'];
       _selectedMedium = item['medium'];
       
       // Parse date string to DateTime for picker
       try {
         _selectedDate = DateFormat('dd MMM yyyy').parse(item['date']!);
         _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!); // Reset format for field
       } catch (e) {
          debugPrint("Error parsing date: $e");
          _selectedDate = DateTime.now();
       }
     });
     _tabController.animateTo(0);
  }

  void _confirmDelete(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
             Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade900, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              "Delete Paperset",
               style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this paperset?",
           style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
             style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _history.removeAt(index);
              });
              CustomToast.showSuccess(context, "Paperset Deleted Successfully");
            },
           style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  void _resetForm() {
    _examNameController.clear();
    _dateController.clear();
    setState(() {
      _selectedSubject = null;
      _selectedMedium = null;
      _selectedDate = null;
      _isEditing = false;
      _editingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Manage Paper Set",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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

                  // Exam Name (Auto-Generated)
                  TextFormField(
                    controller: _examNameController,
                    readOnly: false, // User can edit if they want, but it's auto-suggested
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
                      onPressed: _createOrUpdatePaperset,
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
                        child: TextButton(
                          onPressed: _resetForm,
                          child: Text("Cancel Edit", style: TextStyle(color: Colors.red)),
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
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPaperset(index),
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
