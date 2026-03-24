import 'dart:io';
import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

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
  String? _selectedBoardBi;
  String? _selectedMediumBi;
  String? _selectedStdBi;
  String? _selectedStreamBi;
  String? _selectedYearBi;
  String? _selectedSubjectBi;
  PlatformFile? _boardPdfFile;

  // School Paper Fields
  final TextEditingController _schoolTitleController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  String? _selectedBoardSi;
  String? _selectedSubjectSi;
  String? _selectedMediumSi;
  String? _selectedStdSi;
  String? _selectedStreamSi;
  String? _selectedYearSi;
  PlatformFile? _schoolPdfFile;

  // Notes Fields
  final TextEditingController _notesTitleController = TextEditingController();
  String? _selectedBoardNi;
  String? _selectedSubjectNi;
  String? _selectedMediumNi;
  String? _selectedStdNi;
  String? _selectedStreamNi;
  String? _selectedYearNi;
  PlatformFile? _notesPdfFile;

  // Image Material Fields
  final TextEditingController _imageTitleController = TextEditingController();
  final TextEditingController _imageSchoolNameController = TextEditingController();
  String? _selectedBoardIm;
  String? _selectedSubjectIm;
  String? _selectedMediumIm;
  String? _selectedStdIm;
  String? _selectedStreamIm;
  String? _selectedYearIm;
  String? _selectedUnitIm;
  PlatformFile? _imageFile;
  String? _existingBoardFileUrl;
  String? _existingSchoolFileUrl;
  String? _existingNotesFileUrl;
  String? _existingImageFileUrl;

  String? _editingMaterialId;

  final List<String> _streams = ["Science", "Commerce"];
  final List<String> _pastYears = List.generate(10, (index) => (DateTime.now().year - 1 - index).toString());
  final List<String> _allYears = List.generate(10, (index) => (DateTime.now().year - index).toString());
  final List<String> _units = List.generate(20, (index) => (index + 1).toString());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _boardTitleController.dispose();
    _schoolTitleController.dispose();
    _schoolNameController.dispose();
    _notesTitleController.dispose();
    _imageTitleController.dispose();
    _imageSchoolNameController.dispose();
    super.dispose();
  }

  List<dynamic> _materialsHistory = [];
  bool _isHistoryLoading = false;

  Future<void> _fetchHistory() async {
    setState(() => _isHistoryLoading = true);
    try {
      final response = await ApiService.getAllMaterials();
      if (response.statusCode == 200) {
        setState(() => _materialsHistory = jsonDecode(response.body));
      }
    } catch (e) {
      CustomToast.showError(context, "Error fetching history: $e");
    } finally {
      setState(() => _isHistoryLoading = false);
    }
  }

  void _editMaterial(dynamic item) {
     setState(() {
       _editingMaterialId = item['_id'];
       String type = item['type'];

       if (type == 'BoardPaper') {
          _boardTitleController.text = item['title'] ?? "";
          _selectedBoardBi = item['board'];
          _selectedMediumBi = item['medium'];
          _selectedStdBi = item['standard'];
          _selectedStreamBi = item['stream'] ?? "None";
          _selectedYearBi = item['year'];
          _selectedSubjectBi = item['subject'];
          _tabController.animateTo(0);
       } else if (type == 'SchoolPaper') {
          _schoolTitleController.text = item['title'] ?? "";
          _selectedBoardSi = item['board'];
          _selectedSubjectSi = item['subject'];
          _selectedMediumSi = item['medium'];
          _selectedStdSi = item['standard'];
          _selectedStreamSi = item['stream'] ?? "None";
          _selectedYearSi = item['year'];
          _schoolNameController.text = item['schoolName'] ?? "";
          _tabController.animateTo(1);
       } else if (type == 'Notes') {
          _notesTitleController.text = item['title'] ?? "";
          _selectedBoardNi = item['board'];
          _selectedSubjectNi = item['subject'];
          _selectedMediumNi = item['medium'];
          _selectedStdNi = item['standard'];
          _selectedStreamNi = item['stream'] ?? "None";
          _selectedYearNi = item['year'];
          _tabController.animateTo(2);
       } else if (type == 'ImageMaterial') {
          _imageTitleController.text = item['title'] ?? "";
          _selectedBoardIm = item['board'];
          _selectedSubjectIm = item['subject'];
          _selectedMediumIm = item['medium'];
          _selectedStdIm = item['standard'];
          _selectedStreamIm = item['stream'] ?? "None";
          _selectedYearIm = item['year'];
          _selectedUnitIm = item['unit'];
          _imageSchoolNameController.text = item['schoolName'] ?? "";
          _tabController.animateTo(3);
       }

       // Store existing file URL
       if (type == 'BoardPaper') _existingBoardFileUrl = item['file'];
       if (type == 'SchoolPaper') _existingSchoolFileUrl = item['file'];
       if (type == 'Notes') _existingNotesFileUrl = item['file'];
       if (type == 'ImageMaterial') _existingImageFileUrl = item['file'];
     });
  }

  Future<void> _deleteMaterial(String id) async {
    try {
      final response = await ApiService.deleteMaterial(id);
      if (response.statusCode == 200) {
        CustomToast.showSuccess(context, "Deleted successfully");
        _fetchHistory();
      } else {
        CustomToast.showError(context, "Failed to delete");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    }
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
        if (type == 'notes') _notesPdfFile = result.files.first;
        if (type == 'image') _imageFile = result.files.first;
      });
    }
  }

  Future<void> _submitBoardPaper() async {
    if (_formKey.currentState!.validate() && (_boardPdfFile != null || _editingMaterialId != null)) {
      setState(() => _isLoading = true);
      try {
        final response = _editingMaterialId != null 
          ? await ApiService.updateMaterial(
              id: _editingMaterialId!,
              title: _boardTitleController.text,
              board: _selectedBoardBi!,
              medium: _selectedMediumBi!,
              standard: _selectedStdBi!,
              stream: _selectedStreamBi,
              year: _selectedYearBi!,
              subject: _selectedSubjectBi!,
              file: _boardPdfFile,
            )
          : await ApiService.uploadBoardPaper(
              title: _boardTitleController.text,
              board: _selectedBoardBi!,
              medium: _selectedMediumBi!,
              standard: _selectedStdBi!,
              stream: _selectedStreamBi,
              year: _selectedYearBi!,
              subject: _selectedSubjectBi!,
              file: _boardPdfFile!,
            );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, _editingMaterialId != null ? "Board Paper updated successfully" : "Board Paper added successfully");
          _resetForm();
          _fetchHistory();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_boardPdfFile == null && _editingMaterialId == null) {
      CustomToast.showError(context, "Please select a PDF file");
    }
  }

  Future<void> _submitSchoolPaper() async {
    if (_formKey.currentState!.validate() && (_schoolPdfFile != null || _editingMaterialId != null)) {
      setState(() => _isLoading = true);
      try {
        final response = _editingMaterialId != null
          ? await ApiService.updateMaterial(
              id: _editingMaterialId!,
              title: _schoolTitleController.text,
              board: _selectedBoardSi!,
              subject: _selectedSubjectSi!,
              medium: _selectedMediumSi!,
              standard: _selectedStdSi!,
              stream: _selectedStreamSi ?? "-",
              year: _selectedYearSi!,
              schoolName: _schoolNameController.text,
              file: _schoolPdfFile,
            )
          : await ApiService.uploadSchoolPaper(
              title: _schoolTitleController.text,
              board: _selectedBoardSi!,
              subject: _selectedSubjectSi!,
              medium: _selectedMediumSi!,
              standard: _selectedStdSi!,
              stream: _selectedStreamSi ?? "-",
              year: _selectedYearSi!,
              schoolName: _schoolNameController.text,
              file: _schoolPdfFile!,
            );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, _editingMaterialId != null ? "School Paper updated successfully" : "School Paper added successfully");
          _resetForm();
          _fetchHistory();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_schoolPdfFile == null && _editingMaterialId == null) {
      CustomToast.showError(context, "Please select a PDF file");
    }
  }

  Future<void> _submitNotes() async {
    if (_formKey.currentState!.validate() && (_notesPdfFile != null || _editingMaterialId != null)) {
      setState(() => _isLoading = true);
      try {
        final response = _editingMaterialId != null
          ? await ApiService.updateMaterial(
              id: _editingMaterialId!,
              title: _notesTitleController.text,
              board: _selectedBoardNi!,
              subject: _selectedSubjectNi!,
              medium: _selectedMediumNi!,
              standard: _selectedStdNi!,
              stream: _selectedStreamNi ?? "None",
              year: _selectedYearNi!,
              file: _notesPdfFile,
            )
          : await ApiService.uploadNotes(
              title: _notesTitleController.text,
              board: _selectedBoardNi!,
              subject: _selectedSubjectNi!,
              medium: _selectedMediumNi!,
              standard: _selectedStdNi!,
              stream: _selectedStreamNi ?? "None",
              year: _selectedYearNi!,
              file: _notesPdfFile!,
            );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, _editingMaterialId != null ? "Notes updated successfully" : "Notes added successfully");
          _resetForm();
          _fetchHistory();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_notesPdfFile == null && _editingMaterialId == null) {
      CustomToast.showError(context, "Please select a PDF file");
    }
  }

  Future<void> _submitImageMaterial() async {
    if (_formKey.currentState!.validate() && (_imageFile != null || _editingMaterialId != null)) {
      setState(() => _isLoading = true);
      try {
        final response = _editingMaterialId != null
          ? await ApiService.updateMaterial(
              id: _editingMaterialId!,
              title: _imageTitleController.text,
              board: _selectedBoardIm!,
              subject: _selectedSubjectIm!,
              unit: _selectedUnitIm!,
              medium: _selectedMediumIm!,
              standard: _selectedStdIm!,
              stream: _selectedStreamIm ?? "-",
              year: _selectedYearIm!,
              schoolName: _imageSchoolNameController.text.isNotEmpty ? _imageSchoolNameController.text : null,
              file: _imageFile,
            )
          : await ApiService.uploadImageMaterial(
              title: _imageTitleController.text,
              board: _selectedBoardIm!,
              subject: _selectedSubjectIm!,
              unit: _selectedUnitIm!,
              medium: _selectedMediumIm!,
              standard: _selectedStdIm!,
              stream: _selectedStreamIm ?? "-",
              year: _selectedYearIm!,
              schoolName: _imageSchoolNameController.text.isNotEmpty ? _imageSchoolNameController.text : null,
              file: _imageFile!,
            );

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, _editingMaterialId != null ? "Image Material updated successfully" : "Image Material added successfully");
          _resetForm();
          _fetchHistory();
        } else {
          CustomToast.showError(context, "Failed: ${response.body}");
        }
      } catch (e) {
        CustomToast.showError(context, "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_imageFile == null && _editingMaterialId == null) {
      CustomToast.showError(context, "Please select an image file");
    }
  }

  void _resetForm() {
    setState(() {
      _boardTitleController.clear();
      _schoolTitleController.clear();
      _schoolNameController.clear();
      _notesTitleController.clear();
      _imageTitleController.clear();
      _imageSchoolNameController.clear();
      _boardPdfFile = null;
      _schoolPdfFile = null;
      _notesPdfFile = null;
      _imageFile = null;
      _selectedBoardBi = null;
      _selectedMediumBi = null;
      _selectedStdBi = null;
      _selectedStreamBi = null;
      _selectedYearBi = null;
      _selectedSubjectBi = null;
      _selectedBoardSi = null;
      _selectedSubjectSi = null;
      _selectedMediumSi = null;
      _selectedStdSi = null;
      _selectedStreamSi = null;
      _selectedYearSi = null;
      _selectedBoardNi = null;
      _selectedSubjectNi = null;
      _selectedMediumNi = null;
      _selectedStdNi = null;
      _selectedStreamNi = null;
      _selectedYearNi = null;
      _selectedBoardIm = null;
      _selectedSubjectIm = null;
      _selectedMediumIm = null;
      _selectedStdIm = null;
      _selectedStreamIm = null;
      _selectedYearIm = null;
      _selectedUnitIm = null;
      _editingMaterialId = null;
      _existingBoardFileUrl = null;
      _existingSchoolFileUrl = null;
      _existingNotesFileUrl = null;
      _existingImageFileUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Material", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 4) _fetchHistory();
          },
          tabs: [
            Tab(text: _editingMaterialId != null && _tabController.index == 0 ? "Edit Board" : "Board"),
            Tab(text: _editingMaterialId != null && _tabController.index == 1 ? "Edit School" : "School"),
            Tab(text: _editingMaterialId != null && _tabController.index == 2 ? "Edit Notes" : "Notes"),
            Tab(text: _editingMaterialId != null && _tabController.index == 3 ? "Edit Images" : "Images"),
            const Tab(text: "History"),
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
                _buildNotesForm(),
                _buildImageForm(),
                _buildHistoryView(),
              ],
            ),
          ),
          if (_isLoading) Center(child: CustomLoader()),
        ],
      ),
    );
  }

  Widget _buildBoardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_editingMaterialId != null && _tabController.index == 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.cancel, color: Colors.deepOrange),
                  label: const Text("Cancel Edit", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          _buildTextField(_boardTitleController, "Paper Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Board", Icons.school, _selectedBoardBi, AcademicConstants.boards, (val) => setState(() {
            _selectedBoardBi = val;
            _selectedStdBi = null;
            _selectedSubjectBi = null;
          })),
          const SizedBox(height: 16),
          _buildDropdown("Standard", Icons.class_outlined, _selectedStdBi, _selectedBoardBi == null ? [] : (AcademicConstants.standards[_selectedBoardBi!] ?? []).where((std) => std == "10" || std == "12").toList(), (val) => setState(() {
             _selectedStdBi = val;
             _selectedSubjectBi = null;
          })),
          const SizedBox(height: 16),
          if (_selectedStdBi == "12" || _selectedStdBi == "11") ...[
            _buildDropdown("Stream", Icons.school_outlined, _selectedStreamBi, _streams, (val) => setState(() => _selectedStreamBi = val)),
            const SizedBox(height: 16),
          ],
          _buildDropdown("Medium", Icons.language, _selectedMediumBi, AcademicConstants.mediums, (val) => setState(() => _selectedMediumBi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectBi, (() {
            if (_selectedBoardBi == null || _selectedStdBi == null) return <String>[];
            String key = "$_selectedBoardBi-$_selectedStdBi";
            if (_selectedStdBi == "11" || _selectedStdBi == "12") {
              if (_selectedStreamBi == null || _selectedStreamBi == "None") return <String>[];
              key += "-$_selectedStreamBi";
            }
            return AcademicConstants.subjects[key] ?? <String>[];
          }()), (val) => setState(() => _selectedSubjectBi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Year", Icons.calendar_today, _selectedYearBi, _pastYears, (val) => setState(() => _selectedYearBi = val)),
          const SizedBox(height: 24),
          _buildFilePicker("PDF File", _boardPdfFile?.name, () => _pickFile('board'), existingFileUrl: _existingBoardFileUrl),
          const SizedBox(height: 32),
          _buildSubmitButton(_editingMaterialId != null ? "Update Board Paper" : "Upload Board Paper", _submitBoardPaper),
        ],
      ),
    );
  }

  Widget _buildSchoolForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_editingMaterialId != null && _tabController.index == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.cancel, color: Colors.deepOrange),
                  label: const Text("Cancel Edit", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          _buildTextField(_schoolTitleController, "Paper Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Board", Icons.school, _selectedBoardSi, AcademicConstants.boards, (val) => setState(() {
            _selectedBoardSi = val;
            _selectedStdSi = null;
            _selectedSubjectSi = null;
          })),
          const SizedBox(height: 16),
          _buildDropdown("Standard", Icons.class_outlined, _selectedStdSi, _selectedBoardSi == null ? [] : AcademicConstants.standards[_selectedBoardSi!] ?? [], (val) => setState(() {
             _selectedStdSi = val;
             _selectedSubjectSi = null;
          })),
          const SizedBox(height: 16),
          if (_selectedStdSi == "12" || _selectedStdSi == "11") ...[
            _buildDropdown("Stream", Icons.school_outlined, _selectedStreamSi, _streams, (val) => setState(() => _selectedStreamSi = val)),
            const SizedBox(height: 16),
          ],
          _buildDropdown("Medium", Icons.language, _selectedMediumSi, AcademicConstants.mediums, (val) => setState(() => _selectedMediumSi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectSi, (() {
            if (_selectedBoardSi == null || _selectedStdSi == null) return <String>[];
            String key = "$_selectedBoardSi-$_selectedStdSi";
            if (_selectedStdSi == "11" || _selectedStdSi == "12") {
              if (_selectedStreamSi == null || _selectedStreamSi == "None") return <String>[];
              key += "-$_selectedStreamSi";
            }
            return AcademicConstants.subjects[key] ?? <String>[];
          }()), (val) => setState(() => _selectedSubjectSi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Year", Icons.calendar_today, _selectedYearSi, _pastYears, (val) => setState(() => _selectedYearSi = val)),
          const SizedBox(height: 16),
          _buildTextField(_schoolNameController, "School Name", Icons.school),
          const SizedBox(height: 24),
          _buildFilePicker("PDF File", _schoolPdfFile?.name, () => _pickFile('school'), existingFileUrl: _existingSchoolFileUrl),
          const SizedBox(height: 32),
          _buildSubmitButton(_editingMaterialId != null ? "Update School Paper" : "Upload School Paper", _submitSchoolPaper),
        ],
      ),
    );
  }

  Widget _buildNotesForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_editingMaterialId != null && _tabController.index == 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.cancel, color: Colors.deepOrange),
                  label: const Text("Cancel Edit", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          _buildTextField(_notesTitleController, "Notes Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Board", Icons.school, _selectedBoardNi, AcademicConstants.boards, (val) => setState(() {
            _selectedBoardNi = val;
            _selectedStdNi = null;
            _selectedSubjectNi = null;
          })),
          const SizedBox(height: 16),
          _buildDropdown("Standard", Icons.class_outlined, _selectedStdNi, _selectedBoardNi == null ? [] : AcademicConstants.standards[_selectedBoardNi!] ?? [], (val) => setState(() {
             _selectedStdNi = val;
             _selectedSubjectNi = null;
          })),
          const SizedBox(height: 16),
          if (_selectedStdNi == "12" || _selectedStdNi == "11") ...[
            _buildDropdown("Stream", Icons.school_outlined, _selectedStreamNi, _streams, (val) => setState(() => _selectedStreamNi = val)),
            const SizedBox(height: 16),
          ],
          _buildDropdown("Medium", Icons.language, _selectedMediumNi, AcademicConstants.mediums, (val) => setState(() => _selectedMediumNi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectNi, (() {
            if (_selectedBoardNi == null || _selectedStdNi == null) return <String>[];
            String key = "$_selectedBoardNi-$_selectedStdNi";
            if (_selectedStdNi == "11" || _selectedStdNi == "12") {
              if (_selectedStreamNi == null || _selectedStreamNi == "None") return <String>[];
              key += "-$_selectedStreamNi";
            }
            return AcademicConstants.subjects[key] ?? <String>[];
          }()), (val) => setState(() => _selectedSubjectNi = val)),
          const SizedBox(height: 16),
          _buildDropdown("Year", Icons.calendar_today, _selectedYearNi, _allYears, (val) => setState(() => _selectedYearNi = val)),
          const SizedBox(height: 24),
          _buildFilePicker("PDF File", _notesPdfFile?.name, () => _pickFile('notes'), existingFileUrl: _existingNotesFileUrl),
          const SizedBox(height: 32),
          _buildSubmitButton(_editingMaterialId != null ? "Update Notes" : "Upload Notes", _submitNotes),
        ],
      ),
    );
  }

  Widget _buildImageForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_editingMaterialId != null && _tabController.index == 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.cancel, color: Colors.deepOrange),
                  label: const Text("Cancel Edit", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          _buildTextField(_imageTitleController, "Image Title", Icons.title),
          const SizedBox(height: 16),
          _buildDropdown("Board", Icons.school, _selectedBoardIm, AcademicConstants.boards, (val) => setState(() {
            _selectedBoardIm = val;
            _selectedStdIm = null;
            _selectedSubjectIm = null;
          })),
          const SizedBox(height: 16),
          _buildDropdown("Standard", Icons.class_outlined, _selectedStdIm, _selectedBoardIm == null ? [] : AcademicConstants.standards[_selectedBoardIm!] ?? [], (val) => setState(() {
             _selectedStdIm = val;
             _selectedSubjectIm = null;
          })),
          const SizedBox(height: 16),
          if (_selectedStdIm == "12" || _selectedStdIm == "11") ...[
            _buildDropdown("Stream", Icons.school_outlined, _selectedStreamIm, _streams, (val) => setState(() => _selectedStreamIm = val)),
            const SizedBox(height: 16),
          ],
          _buildDropdown("Medium", Icons.language, _selectedMediumIm, AcademicConstants.mediums, (val) => setState(() => _selectedMediumIm = val)),
          const SizedBox(height: 16),
          _buildDropdown("Subject", Icons.book_outlined, _selectedSubjectIm, (() {
            if (_selectedBoardIm == null || _selectedStdIm == null) return <String>[];
            String key = "$_selectedBoardIm-$_selectedStdIm";
            if (_selectedStdIm == "11" || _selectedStdIm == "12") {
              if (_selectedStreamIm == null || _selectedStreamIm == "None") return <String>[];
              key += "-$_selectedStreamIm";
            }
            return AcademicConstants.subjects[key] ?? <String>[];
          }()), (val) => setState(() => _selectedSubjectIm = val)),
          const SizedBox(height: 16),
          _buildDropdown("Unit", Icons.list_alt, _selectedUnitIm, _units, (val) => setState(() => _selectedUnitIm = val)),
          const SizedBox(height: 16),
          _buildDropdown("Year", Icons.calendar_today, _selectedYearIm, _allYears, (val) => setState(() => _selectedYearIm = val)),
          const SizedBox(height: 24),
          _buildFilePicker("Image File", _imageFile?.name, () => _pickFile('image'), isImage: true, existingFileUrl: _existingImageFileUrl),
          const SizedBox(height: 32),
          _buildSubmitButton(_editingMaterialId != null ? "Update Image Material" : "Upload Image Material", _submitImageMaterial),
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

  Widget _buildFilePicker(String label, String? fileName, VoidCallback onTap, {bool isImage = false, String? existingFileUrl}) {
    String? displayFileName = fileName;
    if (displayFileName == null && existingFileUrl != null) {
      displayFileName = "${existingFileUrl.split('/').last}";
    }

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
              child: Text(displayFileName ?? "Select $label", style: GoogleFonts.poppins(color: displayFileName == null ? Colors.grey : Colors.black)),
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

  Widget _buildHistoryView() {
    if (_isHistoryLoading && _materialsHistory.isEmpty) {
      return const Center(child: CustomLoader());
    }
    if (_materialsHistory.isEmpty) {
      return Center(child: Text("No history found", style: GoogleFonts.poppins(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _materialsHistory.length,
        itemBuilder: (context, index) {
          final material = _materialsHistory[index];
          IconData icon = Icons.description;
          if (material['type'] == 'ImageMaterial') icon = Icons.image;
          if (material['type'] == 'BoardPaper' || material['type'] == 'SchoolPaper' || material['type'] == 'Notes') icon = Icons.picture_as_pdf;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(icon, color: Colors.blue.shade900),
              ),
              title: Text(material['title'] ?? 'No Title', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text("${material['type']} • ${material['subject']}", style: GoogleFonts.poppins(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    tooltip: "Edit",
                    onPressed: () => _editMaterial(material),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Delete",
                    onPressed: () => _deleteMaterial(material['_id']),
                  ),
                ],
              ),
              onTap: () {
                // Future enhancement: Open PDF/Image
              },
            ),
          );
        },
      ),
    );
  }
}
