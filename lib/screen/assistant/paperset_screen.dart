import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PapersetScreen extends StatefulWidget {
  const PapersetScreen({super.key});

  @override
  State<PapersetScreen> createState() => _PapersetScreenState();
}

class _PapersetScreenState extends State<PapersetScreen> {
  // Dummy Data acting as "Admin created" papers
  final List<Map<String, dynamic>> _papers = [
    {
      "id": "1",
      "subject": "Maths Paper",
      "date": "25th January 2024",
      "batch": "Std 10",
      "stream": "English",
      "medium": "GSEB",
      "status": "Collected",
      "color": Colors.blue,
    },
    {
      "id": "2",
      "subject": "Science Test",
      "date": "28th January 2024",
      "batch": "Std 12",
      "stream": "Science",
      "medium": "English",
      "status": "Collected", // Changed from Created as we are removing it from options
      "color": Colors.green,
    },
    {
      "id": "3",
      "subject": "English Grammar",
      "date": "30th January 2024",
      "batch": "Std 9",
      "stream": "General",
      "medium": "Gujarati",
      "status": "Checked",
      "color": Colors.orange,
    },
  ];

  final List<String> _validStatuses = ["Collected", "Checked", "Rechecked"];

  String _selectedStatus = "All";
  final List<String> _filterOptions = ["All", "Collected", "Checked", "Rechecked"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final filteredPapers = _selectedStatus == "All" 
        ? _papers 
        : _papers.where((p) => p["status"] == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Paperset Management",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: theme.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        }
                      },
                      selectedColor: Colors.blue.shade900,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      labelStyle: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // List Section
          Expanded(
            child: filteredPapers.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No papers found",
                        style: GoogleFonts.poppins(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPapers.length,
                  itemBuilder: (context, index) {
                    final paper = filteredPapers[index];
                    return _buildPaperCard(paper);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(Map<String, dynamic> paper) {
    // Determine index in original list for updating
    final originalIndex = _papers.indexOf(paper);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper["subject"],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Slightly larger
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${paper["date"]} • ${paper["batch"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        "${paper["stream"]} • ${paper["medium"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(paper["status"]),
              ],
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Action:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openStatusUpdateDialog(originalIndex),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: Text("Update Status", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade50,
                    foregroundColor: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case "Created":
        bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
        break;
      case "Collected":
        bgColor = isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade100;
        textColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;
        break;
      case "Checked":
        bgColor = isDark ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade100;
        textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade900;
        break;
      case "Rechecked":
        bgColor = isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade100;
        textColor = isDark ? Colors.green.shade200 : Colors.green.shade900;
        break;
      default:
        bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade300 : Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _openStatusUpdateDialog(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update Status",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900, // Kept branding color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                 "Select the new status for ${_papers[index]["subject"]}",
                 style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _validStatuses.map((status) {
                  final isSelected = _papers[index]["status"] == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _papers[index]["status"] = status;
                        });
                        Navigator.pop(context);
                      }
                    },
                    selectedColor: Colors.blue.shade100,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.blue.shade900 : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Optional: For Admin role simulation to "Create"
  // Optional: For Admin role simulation to "Create"
  // void _showCreatePaperDialog() {
  //   final subjectController = TextEditingController();
  //   final batchController = TextEditingController();
  //   final streamController = TextEditingController();
  //   final mediumController = TextEditingController();
  //   
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Create New Paper", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: subjectController,
  //               decoration: const InputDecoration(labelText: "Subject / Reason"),
  //             ),
  //             TextField(
  //               controller: batchController,
  //               decoration: const InputDecoration(labelText: "Batch / Standard"),
  //             ),
  //             TextField(
  //               controller: streamController,
  //               decoration: const InputDecoration(labelText: "Stream"),
  //             ),
  //             TextField(
  //               controller: mediumController,
  //               decoration: const InputDecoration(labelText: "Medium"),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (subjectController.text.isNotEmpty) {
  //               setState(() {
  //                 _papers.add({
  //                   "id": DateTime.now().millisecondsSinceEpoch.toString(),
  //                   "subject": subjectController.text,
  //                   "date": "25th Jan (Today)", // Simplified for demo
  //                   "batch": batchController.text,
  //                   "stream": streamController.text,
  //                   "medium": mediumController.text,
  //                   "status": "Collected", // Default starting status now
  //                   "color": Colors.purple,
  //                 });
  //               });
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: const Text("Create"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
