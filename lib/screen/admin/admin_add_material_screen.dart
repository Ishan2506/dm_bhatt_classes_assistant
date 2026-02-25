import 'dart:io';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAddMaterialScreen extends StatefulWidget {
  const AdminAddMaterialScreen({super.key});

  @override
  State<AdminAddMaterialScreen> createState() => _AdminAddMaterialScreenState();
}

class _AdminAddMaterialScreenState extends State<AdminAddMaterialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Board Paper Fields
  final TextEditingController _boardTitleController = TextEditingController();
  String? _selectedMediumBi;
  String? _selectedStdBi;
  String? _selectedStreamBi;
  String? _selectedYearBi;
  String? _selectedSubjectBi;
  PlatformFile? _boardPdfFile;

  // School Paper Fields
  final TextEditingController _schoolTitleController = TextEditingController();
  String? _selectedSubjectSi;
  DateTime? _selectedDateSi;
  PlatformFile? _schoolPdfFile;

  // Image Material Fields
  final TextEditingController _imageTitleController = TextEditingController();
  String? _selectedSubjectIm;
  String? _selectedUnitIm;
  PlatformFile? _imageFile;

  final List<String> _subjects = ["Mathematics", "Science", "English", "Social Science", "Gujarati", "Physics", "Chemistry", "Biology", "Accounts", "Statistics"];
  final List<String> _mediums = ["Gujarati", "English"];
  final List<String> _stds = ["10", "12"];
  final List<String> _streams = ["None", "Science", "General"];
  final List<String> _years = List.generate(10, (index) => (DateTime.now().year - index).toString());
  final List<String> _units = List.generate(20, (index) => (index + 1).toString());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _boardTitleController.dispose();
    _schoolTitleController.dispose();
    _imageTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type == 'image' ? FileType.image : FileType.custom,
      allowedExtensions: type == 'image' ? null : ['pdf'],
    );

    if (result != null) {
      setState(() {
        if (type == 'board') _boardPdfFile = result.files.first;
        if (type == 'school') _schoolPdfFile = result.files.first;
        if (type == 'image') _imageFile = result.files.first;
      });
    }
  }

  Future<void> _submitBoardPaper() async {
    if (_formKey.currentState!.validate() && _boardPdfFile != null) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.uploadBoardPaper(
          title: _boardTitleController.text,
          medium: _selectedMediumBi!,
          standard: _selectedStdBi!,
          stream: _selectedStreamBi,
          year: _selectedYearBi!,
          subject: _selectedSubjectBi!,
          file: _boardPdfFile!,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, "Board Paper added successfully");
          _resetForm();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_boardPdfFile == null) {
      CustomToast.showError(context, "Please select a PDF file");
    }
  }

  Future<void> _submitSchoolPaper() async {
    if (_formKey.currentState!.validate() && _schoolPdfFile != null) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.uploadSchoolPaper(
          title: _schoolTitleController.text,
          subject: _selectedSubjectSi!,
          file: _schoolPdfFile!,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, "School Paper added successfully");
          _resetForm();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_schoolPdfFile == null) {
      CustomToast.showError(context, "Please select a PDF file");
    }
  }

  Future<void> _submitImageMaterial() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.uploadImageMaterial(
          title: _imageTitleController.text,
          subject: _selectedSubjectIm!,
          unit: _selectedUnitIm!,
          file: _imageFile!,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, "Image Material added successfully");
          _resetForm();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_imageFile == null) {
      CustomToast.showError(context, "Please select an image file");
    }
  }

  void _resetForm() {
    setState(() {
      _boardTitleController.clear();
      _schoolTitleController.clear();
      _imageTitleController.clear();
      _boardPdfFile = null;
      _schoolPdfFile = null;
      _imageFile = null;
      _selectedMediumBi = null;
      _selectedStdBi = null;
      _selectedStreamBi = null;
      _selectedYearBi = null;
      _selectedSubjectBi = null;
      _selectedSubjectSi = null;
      _selectedDateSi = null;
      _selectedSubjectIm = null;
      _selectedUnitIm = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Material", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Board"),
            Tab(text: "School"),
            Tab(text: "Images"),
          ],
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoardForm(),
                _buildSchoolForm(),
                _buildImageForm(),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CustomLoader()),
        ],
      ),
    );
  }

  Widget _buildBoardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_boardTitleController, "Paper Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Medium", Icons.language, _selectedMediumBi, _mediums, (val) => setState(() => _selectedMediumBi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Standard", Icons.class_outlined, _selectedStdBi, _stds, (val) => setState(() => _selectedStdBi = val)),
          const SizedBox(height: 16),
          if (_selectedStdBi == "12") ...[
            _buildDropdown("Stream", Icons.school_outlined, _selectedStreamBi, _streams, (val) => setState(() => _selectedStreamBi = val)),
            const SizedBox(height: 16),
          ],
          _buildDropdown("Year", Icons.calendar_today, _selectedYearBi, _years, (val) => setState(() => _selectedYearBi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectBi, _subjects, (val) => setState(() => _selectedSubjectBi = val)),
          const SizedBox(height: 24),
          _buildFilePicker("PDF File", _boardPdfFile?.name, () => _pickFile('board')),
          const SizedBox(height: 32),
          _buildSubmitButton("Upload Board Paper", _submitBoardPaper),
        ],
      ),
    );
  }

  Widget _buildSchoolForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_schoolTitleController, "Paper Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectSi, _subjects, (val) => setState(() => _selectedSubjectSi = val)),
          const SizedBox(height: 24),
          _buildFilePicker("PDF File", _schoolPdfFile?.name, () => _pickFile('school')),
          const SizedBox(height: 32),
          _buildSubmitButton("Upload School Paper", _submitSchoolPaper),
        ],
      ),
    );
  }

  Widget _buildImageForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_imageTitleController, "Image Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectIm, _subjects, (val) => setState(() => _selectedSubjectIm = val)),
          const SizedBox(height: 16),
          _buildDropdown("Unit", Icons.list_alt, _selectedUnitIm, _units, (val) => setState(() => _selectedUnitIm = val)),
          const SizedBox(height: 24),
          _buildFilePicker("Image File", _imageFile?.name, () => _pickFile('image'), isImage: true),
          const SizedBox(height: 32),
          _buildSubmitButton("Upload Image Material", _submitImageMaterial),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _buildFilePicker(String label, String? fileName, VoidCallback onTap, {bool isImage = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isImage ? Icons.image : Icons.picture_as_pdf, color: Colors.blue.shade900),
            const SizedBox(width: 12),
            Expanded(
              child: Text(fileName ?? "Select $label", style: GoogleFonts.poppins(color: fileName == null ? Colors.grey : Colors.black)),
            ),
            const Icon(Icons.upload_file, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
