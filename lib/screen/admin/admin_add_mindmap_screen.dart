import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';

class AdminAddMindMapScreen extends StatefulWidget {
  const AdminAddMindMapScreen({super.key});

  @override
  State<AdminAddMindMapScreen> createState() => _AdminAddMindMapScreenState();
}

class _AdminAddMindMapScreenState extends State<AdminAddMindMapScreen> {
  String? _selectedBoard;
  String? _selectedMedium;
  String? _selectedStd;
  String? _selectedSubject;
  String? _selectedStream;
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _isSaving = false;
  String? _editingMindMapId;

  // History State
  List<dynamic> _mindMaps = [];
  bool _isLoadingHistory = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterBoard;
  String? _selectedFilterStandard;
  String? _selectedFilterMedium;
  String? _selectedFilterStream;

  @override
  void initState() {
    super.initState();
    _fetchMindMaps();
  }

  Future<void> _fetchMindMaps() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    try {
      final response = await ApiService.getAllMindMaps();
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _mindMaps = jsonDecode(response.body);
          _isLoadingHistory = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
      debugPrint("Error fetching mind maps: $e");
    }
  }

  Future<void> _deleteMindMap(String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Mind Map", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this mind map?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final response = await ApiService.deleteMindMap(id);
                if (response.statusCode == 200) {
                  CustomToast.showSuccess(context, "Mind Map deleted successfully");
                  _fetchMindMaps();
                } else {
                  CustomToast.showError(context, "Failed to delete mind map");
                }
              } catch (e) {
                CustomToast.showError(context, "Error: $e");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  Map<String, dynamic> _mindMapData = {
    'name': '',
    'children': <Map<String, dynamic>>[]
  };

  void _clearForm() {
    setState(() {
      _editingMindMapId = null;
      _selectedBoard = null;
      _selectedMedium = null;
      _selectedStd = null;
      _selectedSubject = null;
      _selectedStream = null;
      _unitController.clear();
      _titleController.clear();
      _mindMapData = {
        'name': '',
        'children': <Map<String, dynamic>>[]
      };
    });
  }

  List<dynamic> _getFilteredMindMaps() {
    return _mindMaps.where((item) {
      final query = _searchController.text.toLowerCase();
      final title = (item['title'] ?? "").toString().toLowerCase();
      final subject = (item['subject'] ?? "").toString().toLowerCase();
      final matchesSearch = title.contains(query) || subject.contains(query);

      final matchBoard = _selectedFilterBoard == null || item['board'] == _selectedFilterBoard;
      final matchStd = _selectedFilterStandard == null || item['std'] == _selectedFilterStandard;
      final matchMedium = _selectedFilterMedium == null || item['medium'] == _selectedFilterMedium;
      final matchStream = _selectedFilterStream == null || item['stream'] == _selectedFilterStream;
      return matchesSearch && matchBoard && matchStd && matchMedium && matchStream;
    }).toList();
  }

  void _editMindMap(BuildContext context, Map<String, dynamic> item) {
    setState(() {
      _editingMindMapId = item['_id'];
      _selectedBoard = item['board'];
      _selectedMedium = item['medium'];
      
      if (!AcademicConstants.boards.contains(_selectedBoard)) _selectedBoard = null;
      if (!AcademicConstants.mediums.contains(_selectedMedium)) _selectedMedium = null;
      
      _selectedStd = item['std'];
      var stds = _selectedBoard == null ? [] : AcademicConstants.standards[_selectedBoard!] ?? [];
      if (!stds.contains(_selectedStd)) _selectedStd = null;
      
      var streams = ["Science", "Commerce"];
      _selectedStream = item['stream'] == 'None' || item['stream'] == '-' ? null : item['stream'];
      if (_selectedStream != null && !streams.contains(_selectedStream)) _selectedStream = null;
      
      _selectedSubject = item['subject'];
      var subjs = (_selectedBoard == null || _selectedStd == null) ? [] : AcademicConstants.subjects["$_selectedBoard-$_selectedStd"] ?? [];
      if (_selectedSubject != null && !subjs.contains(_selectedSubject)) _selectedSubject = null;
      
      _unitController.text = item['unit'] ?? '';
      _titleController.text = item['title'] ?? '';
      _mindMapData = Map<String, dynamic>.from(item['data'] ?? {
        'name': '',
        'children': <Map<String, dynamic>>[]
      });
    });
    DefaultTabController.of(context).animateTo(0);
  }

  void _showCopyDialog(BuildContext context, Map<String, dynamic> item) {
    String? dialogBoard = item['board'];
    String? dialogMedium = item['medium'];
    String? dialogStd = item['std'];
    String? dialogStream = item['stream'] == 'None' || item['stream'] == '-' ? null : item['stream'];
    String? dialogSubject = item['subject'];
    TextEditingController dialogUnit = TextEditingController(text: item['unit'] ?? '');
    TextEditingController dialogTitle = TextEditingController(text: (item['title'] ?? '') + " - Copy");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              title: Text("Clone Mind Map Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: dialogBoard,
                      decoration: const InputDecoration(labelText: "Board", prefixIcon: Icon(Icons.school)),
                      items: AcademicConstants.boards.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) => setDialogState(() {
                        dialogBoard = val;
                        dialogStd = null;
                        dialogSubject = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: dialogMedium,
                      decoration: const InputDecoration(labelText: "Medium", prefixIcon: Icon(Icons.language)),
                      items: AcademicConstants.mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setDialogState(() => dialogMedium = val),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: dialogStd,
                      decoration: const InputDecoration(labelText: "Standard", prefixIcon: Icon(Icons.grade)),
                      items: (dialogBoard == null ? <String>[] : AcademicConstants.standards[dialogBoard!] ?? <String>[]).map((std) => DropdownMenuItem(value: std, child: Text(std))).toList(),
                      onChanged: (val) => setDialogState(() {
                        dialogStd = val;
                        dialogSubject = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (dialogStd == "11" || dialogStd == "12") ...[
                      DropdownButtonFormField<String>(
                        value: dialogStream,
                        decoration: const InputDecoration(labelText: "Stream", prefixIcon: Icon(Icons.school)),
                        items: ["Science", "Commerce"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setDialogState(() => dialogStream = val),
                      ),
                      const SizedBox(height: 12),
                    ],
                    DropdownButtonFormField<String>(
                      value: dialogSubject,
                      decoration: const InputDecoration(labelText: "Subject", prefixIcon: Icon(Icons.book)),
                      items: (() {
                        if (dialogBoard == null || dialogStd == null) return <String>[];
                        String key = "$dialogBoard-$dialogStd";
                        if (dialogStd == "11" || dialogStd == "12") {
                          if (dialogStream == null) return <String>[];
                          key += "-$dialogStream";
                        }
                        return AcademicConstants.subjects[key] ?? <String>[];
                      }()).map((subj) => DropdownMenuItem(value: subj, child: Text(subj))).toList(),
                      onChanged: (val) => setDialogState(() => dialogSubject = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dialogUnit,
                      decoration: const InputDecoration(labelText: "Unit / Topic", prefixIcon: Icon(Icons.topic)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dialogTitle,
                      decoration: const InputDecoration(labelText: "Mind Map Title", prefixIcon: Icon(Icons.title)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    if (dialogBoard == null || dialogMedium == null || dialogStd == null || dialogSubject == null || dialogUnit.text.isEmpty || dialogTitle.text.isEmpty) {
                      CustomToast.showError(dialogContext, "Please fill all fields");
                      return;
                    }
                    Navigator.pop(dialogContext);
                    setState(() {
                      _editingMindMapId = null;
                      _selectedBoard = dialogBoard;
                      _selectedMedium = dialogMedium;
                      _selectedStd = dialogStd;
                      _selectedStream = dialogStream;
                      _selectedSubject = dialogSubject;
                      _unitController.text = dialogUnit.text;
                      _titleController.text = dialogTitle.text;
                      _mindMapData = jsonDecode(jsonEncode(item['data'])); // Deep copy
                    });
                    DefaultTabController.of(context).animateTo(0);
                    CustomToast.showSuccess(context, "Mind Map structure copied! Review and save.");
                  },
                  child: const Text("Copy & Edit Tree"),
                )
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _saveMindMap() async {
    if (_selectedBoard == null || _selectedMedium == null || _selectedStd == null || _selectedSubject == null || _unitController.text.isEmpty || 
        _titleController.text.isEmpty) {
      CustomToast.showError(context, "All fields (Board, Medium, Standard, Subject, Unit, Title) are required");
      return;
    }

    if ((_selectedStd == "11" || _selectedStd == "12") && _selectedStream == null) {
      CustomToast.showError(context, "Please select a Stream");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = {
        'board': _selectedBoard,
        'medium': _selectedMedium,
        'subject': _selectedSubject,
        'unit': _unitController.text,
        'title': _titleController.text,
        'std': _selectedStd,
        'stream': _selectedStream ?? "-",
        'data': _mindMapData,
      };

      final response = _editingMindMapId != null 
          ? await ApiService.updateMindMap(_editingMindMapId!, payload)
          : await ApiService.createMindMap(payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomToast.showSuccess(context, _editingMindMapId != null ? "Mind Map updated successfully" : "Mind Map created successfully");
        _clearForm();
        _fetchMindMaps();
      } else {
        CustomToast.showError(context, "Failed to save: ${response.body}");
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text("Add Mind Map", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            tabs: [
              Tab(text: _editingMindMapId != null ? 'Edit Mind Map' : 'Create New'),
              const Tab(text: 'Mind Map History'),
            ],
          ),
          actions: [
            if (_isSaving)
              const Padding(padding: EdgeInsets.all(8), child: CustomLoader(size: 32))
            else
              IconButton(icon: const Icon(Icons.check), onPressed: _saveMindMap),
          ],
        ),
        body: TabBarView(
          children: [
            // Create New Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_editingMindMapId != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.cancel, color: Colors.deepOrange),
                          label: const Text("Cancel Edit", style: TextStyle(color: Colors.deepOrange)),
                        )
                      ],
                    ),
                  _buildHeaderFields(),
                  const SizedBox(height: 24),
                  Text("Tree Builder", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildNodeEditor(_mindMapData, isRoot: true),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
            // History Tab
            Column(
              children: [
                _buildHistorySearchHeader(),
                Expanded(
                  child: _isLoadingHistory
                  ? const Center(child: CustomLoader())
                      : _getFilteredMindMaps().isEmpty
                          ? Center(child: Text("No mind maps found", style: GoogleFonts.poppins(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _getFilteredMindMaps().length,
                              itemBuilder: (context, index) {
                                final item = _getFilteredMindMaps()[index];
                                final String id = item['_id'];
                                
                                String displayDate = "--";
                                if (item['createdAt'] != null) {
                                   displayDate = item['createdAt'].toString().split('T')[0];
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.shade100,
                                      child: const Icon(Icons.account_tree, color: Colors.indigo),
                                    ),
                                    title: Text(item['title'] ?? 'Untitled', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text("Subject: ${item['subject'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade700)),
                                        Text("Standard: ${item['std'] ?? 'N/A'} ${item['stream'] ?? ''}", style: TextStyle(color: Colors.grey.shade700)),
                                        Text("Medium: ${item['medium'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade700)),
                                        Text("Date: $displayDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.content_copy, color: Colors.green),
                                          tooltip: "Copy / Clone",
                                          onPressed: () => _showCopyDialog(context, item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          tooltip: "Edit",
                                          onPressed: () => _editMindMap(context, item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: "Delete",
                                          onPressed: () => _deleteMindMap(id),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderFields() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedBoard,
              decoration: InputDecoration(
                labelText: "Board",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.school),
              ),
              items: AcademicConstants.boards.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() {
                _selectedBoard = val;
                _selectedStd = null;
                _selectedSubject = null;
              }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMedium,
              decoration: InputDecoration(
                labelText: "Medium",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.language),
              ),
              items: AcademicConstants.mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMedium = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStd,
              decoration: InputDecoration(
                labelText: "Standard",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.grade),
              ),
              items: (_selectedBoard == null ? <String>[] : AcademicConstants.standards[_selectedBoard!] ?? <String>[]).map((std) => DropdownMenuItem(value: std, child: Text(std))).toList(),
              onChanged: (val) => setState(() {
                _selectedStd = val;
                _selectedSubject = null;
              }),
            ),
            const SizedBox(height: 16),
            if (_selectedStd == "11" || _selectedStd == "12") ...[
              DropdownButtonFormField<String>(
                value: _selectedStream,
                decoration: InputDecoration(
                  labelText: "Stream",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school),
                ),
                items: ["Science", "Commerce"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStream = val),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.book),
              ),
              items: (() {
                if (_selectedBoard == null || _selectedStd == null) return <String>[];
                String key = "$_selectedBoard-$_selectedStd";
                if (_selectedStd == "11" || _selectedStd == "12") {
                  if (_selectedStream == null) return <String>[];
                  key += "-$_selectedStream";
                }
                return AcademicConstants.subjects[key] ?? <String>[];
              }()).map((subj) => DropdownMenuItem(value: subj, child: Text(subj))).toList(),
              onChanged: (val) => setState(() => _selectedSubject = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: "Unit / Topic",
                hintText: "e.g. Human Eye",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.topic),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Mind Map Title",
                hintText: "e.g. Detailed Eye Structure",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeEditor(Map<String, dynamic> node, {bool isRoot = false, VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.indigo.shade200, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => node['name'] = val,
                  controller: TextEditingController(text: node['name'])..selection = TextSelection.collapsed(offset: node['name'].length),
                  decoration: InputDecoration(
                    hintText: isRoot ? "Main Topic" : "Sub-Topic",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () {
                  setState(() {
                    (node['children'] as List).add({'name': '', 'children': []});
                  });
                },
              ),
              if (!isRoot)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
          if ((node['children'] as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: (node['children'] as List).asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> child = entry.value;
                  return _buildNodeEditor(
                    child,
                    onDelete: () {
                      setState(() {
                        (node['children'] as List).removeAt(idx);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorySearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search by Title or Subject...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHistoryFilterDropdown("Board", _selectedFilterBoard, AcademicConstants.boards, (val) => setState(() {
                           _selectedFilterBoard = val;
                           _selectedFilterStandard = null;
                         })),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHistoryFilterDropdown(
                  "Std", 
                  _selectedFilterStandard, 
                  _selectedFilterBoard == null 
                      ? (AcademicConstants.standards.isNotEmpty ? AcademicConstants.standards.values.first : <String>[])
                      : AcademicConstants.standards[_selectedFilterBoard!] ?? <String>[], 
                  (val) => setState(() => _selectedFilterStandard = val)
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHistoryFilterDropdown("Medium", _selectedFilterMedium, AcademicConstants.mediums, (val) => setState(() => _selectedFilterMedium = val)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryFilterDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          items: [
            DropdownMenuItem(value: null, child: Text("All $hint")),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
