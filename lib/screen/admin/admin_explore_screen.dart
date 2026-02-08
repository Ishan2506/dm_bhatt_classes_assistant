import 'dart:io';
import 'package:dm_bhatt_classes_new/screen/admin/admin_product_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class AdminExploreScreen extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  const AdminExploreScreen({super.key, this.productToEdit});

  @override
  State<AdminExploreScreen> createState() => _AdminExploreScreenState();
}

class _AdminExploreScreenState extends State<AdminExploreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _discountController;

  PlatformFile? _selectedFile;
  String? _fileType; // 'image' or 'pdf'

  String? _selectedCategory;
  final List<String> _categories = ["Material", "Diagram", "Phantom material", "Books", "Stationery"];

  String? _selectedSubject;
  final List<String> _subjects = ["Science", "Maths", "English", "Gujarati", "Social Science", "Sanskrit", "Computer"];

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?['name'] ?? "");
    _descriptionController = TextEditingController(text: widget.productToEdit?['description'] ?? "Mock Description"); 
    _priceController = TextEditingController(text: widget.productToEdit?['price']?.toString() ?? "");
    _originalPriceController = TextEditingController(text: widget.productToEdit?['originalPrice']?.toString() ?? "");
    _discountController = TextEditingController(); 

    if (_isEditing) {
      _selectedCategory = widget.productToEdit?['category'];
      _selectedSubject = "Science"; 
      _calculateDiscount();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          // Determine file type
          String extension = _selectedFile!.extension?.toLowerCase() ?? '';
          if (['jpg', 'jpeg', 'png'].contains(extension)) {
            _fileType = 'image';
          } else if (extension == 'pdf') {
            _fileType = 'pdf';
          }
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (!_isEditing && _selectedFile == null) {
        CustomToast.showError(context, "Please upload a file (image or PDF)");
        return;
      }
      if (_selectedCategory == null) {
        CustomToast.showError(context, "Please select a category");
        return;
      }
      
      // Call API
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (_isEditing) {
         ApiService.editExploreProduct(
          id: widget.productToEdit!['_id'],
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          subject: _selectedSubject,
          price: double.tryParse(_priceController.text),
          originalPrice: double.tryParse(_originalPriceController.text),
          discount: double.tryParse(_discountController.text),
          file: _selectedFile
         ).then((response) {
            Navigator.pop(context); // Hide loader
            if (response.statusCode == 200) {
               CustomToast.showSuccess(context, "Product Updated Successfully!");
               Navigator.pop(context); 
            } else {
               CustomToast.showError(context, "Failed: ${response.body}");
            }
         }).catchError((e) {
            Navigator.pop(context);
            CustomToast.showError(context, "Error: $e");
         });
      } else {
          ApiService.addExploreProduct(
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory!,
            subject: _selectedSubject,
            price: double.parse(_priceController.text),
            originalPrice: double.parse(_originalPriceController.text),
            discount: double.tryParse(_discountController.text) ?? 0.0,
            file: _selectedFile!,
          ).then((response) {
            Navigator.pop(context); // Hide loader
            if (response.statusCode == 201) {
               CustomToast.showSuccess(context, "Product Added Successfully!");
               // Reset
              _formKey.currentState!.reset();
              _nameController.clear();
              _descriptionController.clear();
              _priceController.clear();
              _originalPriceController.clear();
              _discountController.clear();
              setState(() {
                 _selectedFile = null;
                 _fileType = null;
                 _selectedCategory = null;
                 _selectedSubject = null;
              });
            } else {
              CustomToast.showError(context, "Failed: ${response.body}");
            }
          }).catchError((e) {
             Navigator.pop(context);
             CustomToast.showError(context, "Error: $e");
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Product" : "Add Product",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
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
        automaticallyImplyLeading: _isEditing,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (!_isEditing)
             TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProductHistoryScreen()),
                );
              },
              child: Text(
                "History", 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                )
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Picker (Images and PDFs)
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    image: (_selectedFile != null && _fileType == 'image')
                      ? DecorationImage(
                          image: kIsWeb 
                            ? NetworkImage(_selectedFile!.path!) as ImageProvider
                            : FileImage(File(_selectedFile!.path!)),
                          fit: BoxFit.cover,
                        )
                      : (widget.productToEdit != null && widget.productToEdit!['image'] != null)
                        ? DecorationImage(
                            image: NetworkImage(widget.productToEdit!['image']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (_selectedFile == null && (widget.productToEdit == null || widget.productToEdit!['image'] == null)) 
                    ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        _isEditing ? "Tap to Change File" : "Upload Product Image or PDF", 
                        style: GoogleFonts.poppins(color: Colors.grey.shade600)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Supported: JPG, PNG, PDF",
                        style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)
                      ),
                    ],
                  ) : (_selectedFile != null && _fileType == 'pdf')
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFile!.name,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB",
                          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    )
                    : null,
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
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.blue.shade200,
                  ),
                  child: Text(
                    _isEditing ? "Update Product" : "Add Product",
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
