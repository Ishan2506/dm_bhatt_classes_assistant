import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/academic_constants.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';

class AdminLeaderboardScreen extends StatefulWidget {
  const AdminLeaderboardScreen({super.key});

  @override
  State<AdminLeaderboardScreen> createState() => _AdminLeaderboardScreenState();
}

class _AdminLeaderboardScreenState extends State<AdminLeaderboardScreen> {
  String? _selectedBoard;
  String? _selectedStd;
  String? _selectedMedium;
  String? _selectedStream;

  // Mock Leaderboard State (Top 5)
  late List<Map<String, dynamic>> _leaderboard;

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    _leaderboard = [
      {
        "id": "1",
        "name": "Arjun Patel",
        "points": 5420,
        "avatar": "https://i.pravatar.cc/150?u=arjun",
        "isGifted": false
      },
      {
        "id": "2",
        "name": "Priya Sharma",
        "points": 4890,
        "avatar": "https://i.pravatar.cc/150?u=priya",
        "isGifted": true
      },
      {
        "id": "3",
        "name": "Rohan Desai",
        "points": 4750,
        "avatar": "https://i.pravatar.cc/150?u=rohan",
        "isGifted": false
      },
      {
        "id": "4",
        "name": "Neha Joshi",
        "points": 4200,
        "avatar": "https://i.pravatar.cc/150?u=neha",
        "isGifted": false
      },
      {
        "id": "5",
        "name": "Dev Shah",
        "points": 3950,
        "avatar": "https://i.pravatar.cc/150?u=dev",
        "isGifted": false
      },
    ];
  }

  void _applyFilters() {
    if (_selectedBoard == null || _selectedStd == null || _selectedMedium == null) {
      CustomToast.showError(context, "Please select at least Board, Std, and Medium to fetch the leaderboard.");
      return;
    }
    
    // In a real app, you'd fetch API data here based on the filters.
    // For now, we simulate a loading/refresh state.
    setState(() {
      _leaderboard.shuffle(); // Just shuffle mock data to simulate a new list
    });
    CustomToast.showSuccess(context, "Leaderboard updated for Std $_selectedStd $_selectedMedium medium.");
  }

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF0D47A1); // Default Primary Blue
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          "Student Leaderboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: _buildLeaderboardList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Board", AcademicConstants.boards, _selectedBoard, (val) {
                  setState(() => _selectedBoard = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown("Std", _selectedBoard != null ? (AcademicConstants.standards[_selectedBoard!] ?? []) : [], _selectedStd, (val) {
                  setState(() {
                    _selectedStd = val;
                    if (val != "11" && val != "12") _selectedStream = null;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown("Medium", AcademicConstants.mediums, _selectedMedium, (val) {
                  setState(() => _selectedMedium = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: (_selectedStd == "11" || _selectedStd == "12")
                    ? _buildFilterDropdown("Stream", ["Science", "Commerce", "Arts"], _selectedStream, (val) {
                        setState(() => _selectedStream = val);
                      })
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text("Fetch Top 5 Leaders", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue.shade900),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final student = _leaderboard[index];
        final rank = index + 1;
        final rankColor = _getRankColor(index);
        final bool isGifted = student['isGifted'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: rankColor.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: rankColor.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      "#$rank",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(student['avatar']),
                  onBackgroundImageError: (e, s) {},
                  child: student['avatar'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                const SizedBox(width: 16),

                // Name and Points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.orange.shade400, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${student['points']} pts",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Gifted Toggle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _leaderboard[index]['isGifted'] = !isGifted;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isGifted ? Colors.green.shade50 : Colors.white,
                      border: Border.all(
                        color: isGifted ? Colors.green : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGifted ? Icons.check_circle : Icons.card_giftcard,
                          color: isGifted ? Colors.green : Colors.grey.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGifted ? "Gifted" : "Give Gift",
                          style: GoogleFonts.poppins(
                            color: isGifted ? Colors.green : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
