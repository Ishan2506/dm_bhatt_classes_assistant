import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAssistantScreen extends StatefulWidget {
  const AddAssistantScreen({super.key});

  @override
  State<AddAssistantScreen> createState() => _AddAssistantScreenState();
}

class _AddAssistantScreenState extends State<AddAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isEditing = false;
  int? _editingIndex;
  
  // Real Data
  List<dynamic> _assistants = [];
  bool _isLoadingList = true;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAssistants();
  }
  
  Future<void> _fetchAssistants() async {
    setState(() => _isLoadingList = true);
    try {
      final response = await ApiService.getAllAssistants();
      if (response.statusCode == 200) {
        setState(() {
          _assistants = jsonDecode(response.body);
          _isLoadingList = false;
        });
      } else {
        setState(() => _isLoadingList = false);
        CustomToast.showError(context, "Failed to load assistants");
      }
    } catch (e) {
      setState(() => _isLoadingList = false);
      debugPrint("Error fetching assistants: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _aadharNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _createOrUpdateAssistant() async {
     if (_formKey.currentState!.validate()) {
        try {
          if (_isEditing && _editingId != null) {
              // Edit Logic
              CustomToast.showSuccess(context, "Updating Assistant...");
              
              final response = await ApiService.editAssistant(
                id: _editingId!,
                name: _nameController.text,
                phone: _phoneController.text,
                password: _passwordController.text, // Optional
                address: _addressController.text,
                aadharNumber: _aadharNumberController.text,
              );

               if (!mounted) return;

               if (response.statusCode == 200) {
                 CustomToast.showSuccess(context, "Assistant Updated Successfully");
                 _resetForm();
                 _fetchAssistants();
               } else {
                 final error = jsonDecode(response.body);
                 CustomToast.showError(context, error['message'] ?? "Failed to update assistant");
               }

          } else {
             // Create Logic
             CustomToast.showSuccess(context, "Adding Assistant...");

             final response = await ApiService.addAssistant(
                name: _nameController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
                aadharNumber: _aadharNumberController.text,
                address: _addressController.text,
              );

              if (!mounted) return;

              if (response.statusCode == 200 || response.statusCode == 201) {
                CustomToast.showSuccess(context, "Assistant Added Successfully");
                _resetForm();
                _fetchAssistants(); 
              } else {
                final error = jsonDecode(response.body);
                CustomToast.showError(context, error['message'] ?? "Failed to add assistant");
              }
          }
        } catch (e) {
          if (mounted) {
            CustomToast.showError(context, "Error: $e");
          }
        }
     }
  }

  void _editAssistant(int index) {
    final item = _assistants[index];
    setState(() {
      _isEditing = true;
      _editingId = item['_id'];
      _nameController.text = item['name'] ?? "";
      _phoneController.text = item['phone'] ?? "";
      _aadharNumberController.text = item['aadharNum'] ?? "";
      _addressController.text = item['address'] ?? "";
      _passwordController.clear();
    });
    _tabController.animateTo(0);
  }

  void _confirmDelete(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = _assistants[index];
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
              "Delete Assistant", 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
                final response = await ApiService.deleteAssistant(id);
                if (!mounted) return;

                if (response.statusCode == 200) {
                   CustomToast.showSuccess(context, "Assistant Deleted Successfully");
                   _fetchAssistants();
                } else {
                   CustomToast.showError(context, "Failed to delete assistant");
                }
              } catch (e) {
                 if (mounted) CustomToast.showError(context, "Error: $e");
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
    _aadharNumberController.clear();
    _addressController.clear();
    setState(() {
      _isEditing = false;
      _editingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Manage Assistant",
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
                  _buildSectionTitle("Personal Details"),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    validator: (v) => v!.length != 10 ? "Invalid Number" : null,
                  ),
                  const SizedBox(height: 16),

                   _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onVisibilityChanged: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (v) => (!_isEditing && v!.length < 6) ? "Min 6 chars" : null, // Optional on Edit
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _aadharNumberController,
                    label: "Aadhar Number",
                    icon: Icons.credit_card_outlined,
                    inputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                    validator: (v) => v!.length != 12 ? "Invalid Aadhar Number" : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _addressController,
                    label: "Address",
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createOrUpdateAssistant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: Text(
                        _isEditing ? "Update Assistant" : "Create Assistant",
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
          _isLoadingList 
             ? const Center(child: CustomLoader()) 
             : _assistants.isEmpty 
                 ? Center(child: Text("No assistants found", style: GoogleFonts.poppins(color: Colors.grey)))
                 : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _assistants.length,
            itemBuilder: (context, index) {
              final item = _assistants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Colors.grey.shade50,
                 shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text((item['name'] != null && item['name'].isNotEmpty) ? item['name'][0] : "?", style: TextStyle(color: Colors.blue.shade900)),
                  ),
                  title: Text(item['name'] ?? "Unknown", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text("${item['phone']} • Aadhar: ${item['aadharNum'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editAssistant(index),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: onVisibilityChanged,
                ) 
              : null,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5),
        ),
      ),
    );
  }
}
