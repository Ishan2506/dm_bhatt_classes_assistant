import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  late Future<List<dynamic>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _fetchEvents();
    });
  }

  Future<List<dynamic>> _fetchEvents() async {
    try {
      final response = await ApiService.getAllEvents();
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _deleteEvent(String id) async {
    CustomLoader.show(context);
    try {
      final response = await ApiService.deleteEvent(id);
      if (!mounted) return;
      CustomLoader.hide(context);
      
      if (response.statusCode == 200) {
        CustomToast.showSuccess(context, "Event deleted successfully");
        _refreshEvents();
      } else {
        CustomToast.showError(context, "Failed to delete event");
      }
    } catch (e) {
      if (!mounted) return;
      CustomLoader.hide(context);
      CustomToast.showError(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Manage Events",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No events found",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event, color: theme.primaryColor),
                  ),
                  title: Text(
                    event['title'] ?? "No Title",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    event['date'] != null 
                        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(event['date'])) 
                        : "No Date",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEventDialog(event: event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, event['_id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: theme.primaryColor,
        label: Text("Add Event", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this event?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(id);
            },
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog({Map<String, dynamic>? event}) {
    showDialog(
      context: context, 
      builder: (context) => AddEventDialog(event: event),
    ).then((val) {
      if (val == true) {
        _refreshEvents();
      }
    });
  }
}

class AddEventDialog extends StatefulWidget {
  final Map<String, dynamic>? event;
  const AddEventDialog({super.key, this.event});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<PlatformFile> _selectedFiles = [];
  List<String> _existingImages = []; // Stores URLs of existing images to keep

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!['title'] ?? '';
      _descriptionController.text = widget.event!['description'] ?? '';
      if (widget.event!['date'] != null) {
        _selectedDate = DateTime.parse(widget.event!['date']);
      }
      if (widget.event!['images'] != null) {
        _existingImages = List<String>.from(widget.event!['images']);
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFiles.isEmpty && _existingImages.isEmpty) {
        CustomToast.showError(context, "Please select at least one image");
        return;
      }

      CustomLoader.show(context);
      try {
        http.Response response;
        if (widget.event == null) {
          // Create new
           response = await ApiService.createEvent(
            title: _titleController.text,
            description: _descriptionController.text,
            date: _selectedDate,
            images: _selectedFiles,
          );
        } else {
          // Update existing
           response = await ApiService.updateEvent(
            id: widget.event!['_id'],
            title: _titleController.text,
            description: _descriptionController.text,
            date: _selectedDate,
            newImages: _selectedFiles.isNotEmpty ? _selectedFiles : null,
            existingImages: _existingImages,
          );
        }

        if (!mounted) return;
        CustomLoader.hide(context);

        if (response.statusCode == 201 || response.statusCode == 200) {
          CustomToast.showSuccess(context, widget.event == null ? "Event created successfully" : "Event updated successfully");
          Navigator.pop(context, true);
        } else {
          CustomToast.showError(context, "Failed to save event: ${response.statusCode}");
        }
      } catch (e) {
        if (!mounted) return;
        CustomLoader.hide(context);
        CustomToast.showError(context, "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.event == null ? "Add New Event" : "Edit Event", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Event Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                   TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                   ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}", style: GoogleFonts.poppins()),
                    trailing: const Icon(Icons.calendar_today),
                     onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                   ),
                  const SizedBox(height: 16),
                  
                  // Existing Images Section
                  if (_existingImages.isNotEmpty) ...[
                    Text("Existing Photos (${_existingImages.length})", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _existingImages.map((imageUrl) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl, // Assuming Cloudinary URL or reachable URL
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey.shade300, child: const Icon(Icons.broken_image, size: 20)),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _existingImages.remove(imageUrl);
                                });
                              },
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Upload functionality
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                           const Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey),
                           const SizedBox(height: 8),
                           Text("Upload New Photos (${_selectedFiles.length} selected)", style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedFiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedFiles.map((file) => Chip(
                          label: Text(file.name, style: const TextStyle(fontSize: 10)),
                          onDeleted: () {
                            setState(() {
                              _selectedFiles.remove(file);
                            });
                          },
                        )).toList(),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: Text(widget.event == null ? "Add" : "Save", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      );
  }
}
