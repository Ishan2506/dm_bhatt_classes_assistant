import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAssistantScreen extends StatefulWidget {
  const AddAssistantScreen({super.key});

  @override
  State<AddAssistantScreen> createState() => _AddAssistantScreenState();
}

class _AddAssistantScreenState extends State<AddAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // Mock History Data
  final List<Map<String, String>> _history = [
    {"name": "Ravi Patel", "role": "Assistant", "date": "24 Jan 2024"},
    {"name": "Priya Shah", "role": "Assistant", "date": "20 Jan 2024"},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadharNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Manage Assistant",
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
                      controller: _aadharNameController,
                      label: "Aadhar Card Name",
                      icon: Icons.credit_card_outlined,
                      validator: (v) => v!.isEmpty ? "Required" : null,
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
                        onPressed: () {
                           if (_formKey.currentState!.validate()) {
                              CustomToast.showSuccess(context, "Assistant Added Successfully");
                              // In real app, refresh history here
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: Text(
                          "Create Assistant",
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(item['name']![0], style: TextStyle(color: Colors.blue.shade900)),
                    ),
                    title: Text(item['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("Added on ${item['date']}", style: GoogleFonts.poppins(fontSize: 12)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5),
        ),
      ),
    );
  }
}
