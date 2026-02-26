import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';

class AdminAddMindMapScreen extends StatefulWidget {
  const AdminAddMindMapScreen({super.key});

  @override
  State<AdminAddMindMapScreen> createState() => _AdminAddMindMapScreenState();
}

class _AdminAddMindMapScreenState extends State<AdminAddMindMapScreen> {
  String? _selectedSubject;
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedStd;
  bool _isSaving = false;

  final List<String> _stds = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _subjects = ["Science", "Maths", "English", "Gujarati", "Social Science", "Sanskrit", "Hindi", "Other"];

  Map<String, dynamic> _mindMapData = {
    'name': 'Main Topic',
    'children': <Map<String, dynamic>>[]
  };

  Future<void> _saveMindMap() async {
    if (_selectedSubject == null || _unitController.text.isEmpty || 
        _titleController.text.isEmpty || _selectedStd == null) {
      CustomToast.showError(context, "All fields (Standard, Subject, Unit, Title) are required");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await ApiService.createMindMap({
        'subject': _selectedSubject,
        'unit': _unitController.text,
        'title': _titleController.text,
        'std': _selectedStd,
        'data': _mindMapData,
      });

      if (response.statusCode == 201) {
        CustomToast.showSuccess(context, "Mind Map created successfully");
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Mind Map", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.indigo.shade700]))),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white))
          else
            IconButton(icon: const Icon(Icons.check, color: Colors.white), onPressed: _saveMindMap),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              value: _selectedStd,
              decoration: InputDecoration(
                labelText: "Standard",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.grade),
              ),
              items: _stds.map((std) => DropdownMenuItem(value: std, child: Text(std))).toList(),
              onChanged: (val) => setState(() => _selectedStd = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.book),
              ),
              items: _subjects.map((subj) => DropdownMenuItem(value: subj, child: Text(subj))).toList(),
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
                    hintText: "Node Name",
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
                    (node['children'] as List).add({'name': 'New Child', 'children': []});
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
}
