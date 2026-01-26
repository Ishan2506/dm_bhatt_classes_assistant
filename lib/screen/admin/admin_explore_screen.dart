import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class AdminExploreScreen extends StatefulWidget {
  const AdminExploreScreen({super.key});

  @override
  State<AdminExploreScreen> createState() => _AdminExploreScreenState();
}

class _AdminExploreScreenState extends State<AdminExploreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  final List<String> _categories = ["Material", "Diagram", "Phantom material", "Books", "Stationery"];

  String? _selectedSubject;
  final List<String> _subjects = ["Science", "Maths", "English", "Gujarati", "Social Science", "Sanskrit", "Computer"];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    }
  }

  void _calculateDiscount() {
    if (_priceController.text.isNotEmpty && _originalPriceController.text.isNotEmpty) {
      try {
        double price = double.parse(_priceController.text);
        double original = double.parse(_originalPriceController.text);
        if (original > 0) {
          int discount = ((original - price) / original * 100).round();
          _discountController.text = discount.toString();
        }
      } catch (e) {
        // Ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add Product",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    image: _imageFile != null ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ) : null,
                  ),
                  child: _imageFile == null ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text("Upload Product Image", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                    ],
                  ) : null,
                ),
              ),
              const SizedBox(height: 24),

              Text("Product Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                hint: "Product Title",
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                hint: "Description",
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      hint: "Category",
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      hint: "Subject",
                      value: _selectedSubject,
                      items: _subjects,
                      onChanged: (val) => setState(() => _selectedSubject = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

               Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      hint: "MRP",
                      icon: Icons.price_change_outlined,
                      inputType: TextInputType.number,
                      onChanged: (val) => _calculateDiscount(),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      hint: "Price",
                      icon: Icons.currency_rupee,
                      inputType: TextInputType.number,
                      onChanged: (val) => _calculateDiscount(),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               _buildTextField(
                controller: _discountController,
                hint: "Discount %",
                icon: Icons.percent,
                inputType: TextInputType.number,
                readOnly: true, // Auto-calculated
              ),

              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_imageFile == null) {
                        CustomToast.showError(context, "Please upload an image");
                        return;
                      }
                      if (_selectedCategory == null) {
                        CustomToast.showError(context, "Please select a category");
                        return;
                      }
                      
                      // Mock Submission
                      CustomToast.showSuccess(context, "Product Added Successfully!");
                      
                      // Reset Form
                      _formKey.currentState!.reset();
                      _nameController.clear();
                      _descriptionController.clear();
                      _priceController.clear();
                      _originalPriceController.clear();
                      _discountController.clear();
                      setState(() {
                         _imageFile = null;
                         _selectedCategory = null;
                         _selectedSubject = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.blue.shade200,
                  ),
                  child: Text(
                    "Add Product",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        readOnly: readOnly,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
