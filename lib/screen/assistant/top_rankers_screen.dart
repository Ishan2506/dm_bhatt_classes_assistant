import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopRankersScreen extends StatefulWidget {
  const TopRankersScreen({super.key});

  @override
  State<TopRankersScreen> createState() => _TopRankersScreenState();
}

class _TopRankersScreenState extends State<TopRankersScreen> {
  // --- MOCK DATABASE ---
  
  // All Students (Simulating existing student database)
  final List<Map<String, String>> _studentDatabase = [
    {"name": "Rohan Mehta", "std": "9", "stream": "General", "medium": "English", "image": "R"},
    {"name": "Ayesha Khan", "std": "9", "stream": "General", "medium": "English", "image": "A"},
    {"name": "Suresh Patel", "std": "9", "stream": "General", "medium": "Gujarati", "image": "S"},
    {"name": "Aditya Raj", "std": "10", "stream": "Science", "medium": "English", "image": "A"},
    {"name": "Priya Sharma", "std": "10", "stream": "Science", "medium": "English", "image": "P"},
    {"name": "Rahul Verma", "std": "10", "stream": "Commerce", "medium": "English", "image": "R"},
    {"name": "Sneha Gupta", "std": "12", "stream": "Science", "medium": "English", "image": "S"},
    {"name": "Karan Shah", "std": "12", "stream": "Commerce", "medium": "Gujarati", "image": "K"},
  ];

  // Existing Rankers (Simulating Ranker History)
  final List<Map<String, dynamic>> _rankers = [
    {
      "name": "Hanshika M Dave",
      "marks": "98/100",
      "subject": "English",
      "rank": "1st",
      "std": "10",
      "stream": "Science",
      "medium": "English",
      "color": Colors.blue.shade800
    },
     {
      "name": "Ansh K Shah",
      "marks": "97/100",
      "subject": "Maths",
      "rank": "2nd",
      "std": "10",
      "stream": "Science",
      "medium": "English",
      "color": Colors.red.shade800
    },
  ];

  // --- SELECTION STATE ---
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;

  // Dropdown Options
  final List<String> _standards = ["9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "Arts", "General"];


  // --- ADD RANKER LOGIC ---

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  Map<String, String>? _selectedStudentForAdd;

  void _showAddRankerDialog() {
    // Validation: Must select Filters first
    if (_selectedStandard == null || _selectedMedium == null || _selectedStream == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Standard, Medium, and Stream to add a ranker.", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade700,
        )
      );
      return;
    }

    // Validation: Max 5 Rankers
    final currentRankers = _getFilteredRankers();
    if (currentRankers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maximum 5 rankers allowed for this category.", style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange.shade800,
        )
      );
      return;
    }
    
    // Filter Mock Database for Autocomplete
    final eligibleStudents = _studentDatabase.where((s) => 
      s['std'] == _selectedStandard && 
      s['medium'] == _selectedMedium && 
      s['stream'] == _selectedStream
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
                "Add Top Ranker",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Std $_selectedStandard • $_selectedMedium • $_selectedStream",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Student Search (Autocomplete)
              Autocomplete<Map<String, String>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Map<String, String>>.empty();
                  }
                  return eligibleStudents.where((Map<String, String> option) {
                    return option['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (Map<String, String> option) => option['name']!,
                onSelected: (Map<String, String> selection) {
                  _selectedStudentForAdd = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: _inputDecoration("Search Student Name", Icons.search),
                    validator: (v) => _selectedStudentForAdd == null ? "Please select a valid student" : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 48,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Text(option['name']![0], style: TextStyle(color: Colors.blue.shade900)),
                              ),
                              title: Text(option['name']!, style: GoogleFonts.poppins()),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: _inputDecoration("Subject", Icons.book),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rankController,
                      decoration: _inputDecoration("Rank (e.g. 1st)", Icons.emoji_events),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                decoration: _inputDecoration("Marks (e.g. 98/100)", Icons.grade),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedStudentForAdd != null) {
                    setState(() {
                      _rankers.add({
                        "name": _selectedStudentForAdd!['name'],
                        "subject": _subjectController.text,
                        "rank": _rankController.text,
                        "marks": _marksController.text,
                        "std": _selectedStandard,
                        "medium": _selectedMedium,
                        "stream": _selectedStream,
                        "color": Colors.purple.shade700, 
                      });
                    });
                    
                    // Reset
                    _selectedStudentForAdd = null;
                    _subjectController.clear();
                    _rankController.clear();
                    _marksController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "Add Ranker",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade900),
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  List<Map<String, dynamic>> _getFilteredRankers() {
    if (_selectedStandard == null || _selectedMedium == null || _selectedStream == null) {
      return [];
    }
    return _rankers.where((r) => 
      r['std'] == _selectedStandard && 
      r['medium'] == _selectedMedium && 
      r['stream'] == _selectedStream
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRankers = _getFilteredRankers();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Manage Top Rankers",
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
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRankerDialog,
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Ranker", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: Column(
        children: [
          // FILTERS SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Category", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown("Standard", _standards, _selectedStandard, (v) => setState(() => _selectedStandard = v)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown("Medium", _mediums, _selectedMedium, (v) => setState(() => _selectedMedium = v)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown("Stream", _streams, _selectedStream, (v) => setState(() => _selectedStream = v)),
              ],
            ),
          ),

          // LIST SECTION
          Expanded(
            child: _selectedStandard == null || _selectedMedium == null || _selectedStream == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list, size: 64, color: isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade100),
                      const SizedBox(height: 16),
                      Text(
                        "Please select filters to view rankers",
                        style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                )
              : filteredRankers.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "No Top Rankers added yet for this category.",
                            style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRankers.length,
                      itemBuilder: (context, index) {
                        return _buildRankerCard(filteredRankers[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
      style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
      dropdownColor: theme.cardColor,
    );
  }

  // Adapted from StudentDashboardWidgets
  Widget _buildRankerCard(Map<String, dynamic> ranker) {
    // ... same as before
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = ranker['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: color.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    child: Text(
                      ranker['name'][0], // Initials if no image
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${ranker['subject']} • ${ranker['rank']}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ranker['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        "${ranker['marks']} Marks",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
                    // Logic to remove ranker
                    setState(() {
                      _rankers.remove(ranker);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
