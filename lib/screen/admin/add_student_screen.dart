import 'dart:io';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isEditing = false; // To track if we are in edit mode
  int? _editingIndex; // To track which item is being edited (mock)

  // Selection States
  String? _selectedBoard;
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedState;
  String? _selectedCity;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Data Lists
  final List<String> _streams = ["Science", "Commerce", "General"];
  
  final Map<String, List<String>> _stateCityMap = {
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
    "Rajasthan": ["Jaipur", "Udaipur", "Jodhpur", "Kota"],
  };

  // Real Data
  List<dynamic> _students = [];
  bool _isLoadingList = true;
  String? _editingId; // Store backend ID for editing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoadingList = true);
    try {
      final response = await ApiService.getAllStudents();
      if (response.statusCode == 200) {
        setState(() {
          _students = jsonDecode(response.body);
          _isLoadingList = false;
        });
      } else {
        setState(() => _isLoadingList = false);
        CustomToast.showError(context, "Failed to load students");
      }
    } catch (e) {
      setState(() => _isLoadingList = false);
      debugPrint("Error fetching students: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _parentPhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    }
  }

  Future<void> _createOrUpdateStudent() async {
      if (_formKey.currentState!.validate()) {
        try {
          CustomLoader.show(context); // Show Loader
          
          if (_isEditing && _editingId != null) {
             // Edit Logic
             final response = await ApiService.editStudent(
                id: _editingId!,
                name: _nameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                password: _passwordController.text, // Optional in edit
                parentPhone: _parentPhoneController.text,
                board: _selectedBoard,
                standard: _selectedStandard,
                medium: _selectedMedium,
                stream: _selectedStream,
                state: _selectedState,
                city: _selectedCity ?? "",
                imageFile: _imageFile,
             );

             if (!mounted) return;
             CustomLoader.hide(context);

             if (response.statusCode == 200) {
               CustomToast.showSuccess(context, 'Student Updated Successfully');
               _resetForm();
               _fetchStudents(); // Refresh list
             } else {
               final error = jsonDecode(response.body);
               CustomToast.showError(context, error['message'] ?? "Failed to update student");
             }

          } else {
              // Create Logic
              final response = await ApiService.addStudent(
                name: _nameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
                parentPhone: _parentPhoneController.text,
                board: _selectedBoard ?? "",
                standard: _selectedStandard ?? "",
                medium: _selectedMedium ?? "",
                stream: _selectedStream,
                state: _selectedState ?? "Gujarat",
                city: _selectedCity ?? "",
                imageFile: _imageFile,
              );

              if (!mounted) return;
              CustomLoader.hide(context); // Hide Loader

              if (response.statusCode == 200 || response.statusCode == 201) {
                CustomToast.showSuccess(context, 'Student Added Successfully');
                _resetForm();
                _fetchStudents(); // Refresh list
              } else {
                 final error = jsonDecode(response.body);
                 CustomToast.showError(context, error['message'] ?? "Failed to add student");
              }
          }
        } catch (e) {
          if (mounted) {
            CustomLoader.hide(context); // Hide on Error too (if likely shown)
            CustomToast.showError(context, "Error: $e");
          }
        }
      }
  }
  
  void _editStudent(int index) {
     final item = _students[index];
     setState(() {
       _isEditing = true;
       _editingId = item['_id']; // MongoDB ID
       _nameController.text = item['name'] ?? "";
       _phoneController.text = item['phone'] ?? "";
       _parentPhoneController.text = item['parentPhone'] ?? "";
       _emailController.text = item['email'] ?? "";
       
       // Handle dropdowns safely
       _selectedBoard = item['board'] != null && AcademicConstants.boards.contains(item['board']) ? item['board'] : null;
       _selectedStandard = item['std'] != null && _selectedBoard != null && AcademicConstants.standards[_selectedBoard!] != null && AcademicConstants.standards[_selectedBoard!]!.contains(item['std']) ? item['std'] : null;
       _selectedMedium = item['medium'] != null && AcademicConstants.mediums.contains(item['medium']) ? item['medium'] : null;
       _selectedStream = item['stream'] != null && _streams.contains(item['stream']) ? item['stream'] : null;
       
       _selectedState = item['state'];
       _selectedCity = item['city'] != null && _selectedState != null && _stateCityMap[_selectedState!] != null && _stateCityMap[_selectedState!]!.contains(item['city']) ? item['city'] : null;
       
       // Note: Image handling would require showing network image if available, skipped for brevity in form setup.
       // Password remains empty for security, user enters only if changing.
     });
     _tabController.animateTo(0); // Switch to "Create New" tab form
  }

  void _confirmDelete(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = _students[index];
    final String id = item['_id'];

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
              "Delete Student",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87, // Adaptive color
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete ${item['name']}? This action cannot be undone.",
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                CustomLoader.show(context);
                final response = await ApiService.deleteStudent(id);
                if (!mounted) return;
                CustomLoader.hide(context);

                if (response.statusCode == 200) {
                   CustomToast.showSuccess(context, "Student Deleted Successfully");
                   _fetchStudents();
                } else {
                   CustomToast.showError(context, "Failed to delete student");
                }
              } catch (e) {
                 if (mounted) CustomLoader.hide(context);
                 CustomToast.showError(context, "Error: $e");
              }
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
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _parentPhoneController.clear();
    _emailController.clear();
    setState(() {
      _imageFile = null;
      _selectedBoard = null;
      _selectedStandard = null;
      _selectedMedium = null;
      _selectedStream = null;
      _isEditing = false;
      _editingId = null;
      _selectedState = null;
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Manage Student",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
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
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              // TODO: Show network image if editing and _imageFile is null
                              backgroundImage: _imageFile != null 
                                  ? FileImage(_imageFile!) 
                                  : const AssetImage("assets/images/user_placeholder.png") as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      hint: "Name", 
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hint: "Email", 
                      icon: Icons.email_outlined, 
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      hint: "Phone Number", 
                      icon: Icons.phone_outlined, 
                      inputType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      validator: (val) => val!.length != 10 ? "Invalid phone" : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: _isPasswordVisible,
                      onVisibilityChanged: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (val) => (!_isEditing && val!.length < 6) ? "Min 6 chars" : null, // Optional on edit mostly
                    ),
                    const SizedBox(height: 16),

                    // Parent's Mobile
                    _buildTextField(
                      controller: _parentPhoneController,
                      hint: "Parent's Mobile Number", 
                      icon: Icons.family_restroom_outlined, 
                      inputType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                       validator: (val) => (val != null && val.isNotEmpty && val.length != 10) ? "Invalid phone" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "Board",
                      icon: Icons.school,
                      value: _selectedBoard,
                      items: AcademicConstants.boards,
                      onChanged: (val) => setState(() {
                         _selectedBoard = val;
                         _selectedStandard = null; // reset standard on board change
                      }),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "Standard",
                      icon: Icons.school_outlined,
                      value: _selectedStandard,
                      items: _selectedBoard == null ? [] : AcademicConstants.standards[_selectedBoard!] ?? [],
                      onChanged: (val) => setState(() => _selectedStandard = val),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "Medium",
                      icon: Icons.language,
                      value: _selectedMedium,
                      items: AcademicConstants.mediums,
                      onChanged: (val) => setState(() => _selectedMedium = val),
                    ),
                     const SizedBox(height: 16),
                     
                     if (_selectedStandard == "11" || _selectedStandard == "12") ...[
                       _buildDropdown(
                        hint: "Stream",
                        icon: Icons.science_outlined,
                        value: _selectedStream,
                        items: _streams,
                        onChanged: (val) => setState(() => _selectedStream = val),
                      ),
                      const SizedBox(height: 16),
                     ],

                    _buildDropdown(
                      hint: "State",
                      icon: Icons.map_outlined,
                      value: _selectedState,
                      items: _stateCityMap.keys.toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedState = val;
                          _selectedCity = null; // Reset city on state change
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "City",
                      icon: Icons.location_city,
                      value: _selectedCity,
                      items: _selectedState == null ? [] : _stateCityMap[_selectedState!] ?? [],
                      onChanged: (val) => setState(() => _selectedCity = val),
                    ),
                    const SizedBox(height: 16),


                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createOrUpdateStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _isEditing ? "Update Student" : "Add Student",
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
            
            // Tab 2: History (Now Real List)
            _isLoadingList 
               ? const Center(child: CustomLoader()) 
               : _students.isEmpty 
                   ? Center(child: Text("No students found", style: GoogleFonts.poppins(color: Colors.grey)))
                   : RefreshIndicator(
                       onRefresh: _fetchStudents,
                       child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final item = _students[index];
                final String name = item['name'] ?? "Unknown";
                final String? email = item['email'];
                final String std = item['std'] ?? "?";
                final String? stream = item['stream'];
                final String phone = item['phone'] ?? "";
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                   color: Colors.grey.shade50,
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                       backgroundColor: Colors.blue.shade100,
                       child: Text(name.isNotEmpty ? name[0] : "?", style: TextStyle(color: Colors.blue.shade900)),
                    ),
                    title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("${email != null ? '$email • ' : ''}Std: $std ${ (stream != null && stream != 'None' && stream != 'none' && stream != '-') ? '($stream)' : ''} • $phone", style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editStudent(index),
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
          ),
          ],
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint, 
    required IconData icon, 
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isPassword = false, 
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold), 
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.black54),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: onVisibilityChanged,
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Text(hint, style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          dropdownColor: Colors.white, 
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
