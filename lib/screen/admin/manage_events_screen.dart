import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  // Mock List
  final List<Map<String, dynamic>> _events = [
     {
        "title": "Annual Function 2025",
        "date": "Jan 15, 2025",
      },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      body: _events.isEmpty 
          ? Center(
              child: Text(
                "No events found",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
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
                      event['title'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      event['date'],
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        // Delete logic
                         setState(() {
                           _events.removeAt(index);
                         });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: theme.primaryColor,
        label: Text("Add Event", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Add New Event", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Event Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: "Event Date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            // Upload functionality placeholder
            Container(
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
                   Text("Upload Photos", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _events.add({
                    "title": titleController.text,
                    "date": dateController.text.isEmpty ? "Upcoming" : dateController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: Text("Add", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
