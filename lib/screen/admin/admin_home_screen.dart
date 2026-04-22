import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_product_history_screen.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_app_bar.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_dashboard.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_explore_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_add_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_more_screen.dart';
import 'package:dm_bhatt_classes_new/screen/shared/my_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  bool _isSuperAdmin = false;
  bool _isLoadingRole = true;

  final List<Widget> _allScreens = [
    const AdminDashboard(),
    const AdminExploreScreen(isTab: true),
    const AdminAddScreen(),
    const AdminMoreScreen(),
  ];

  final List<String> _allTitles = [
    "Dashboard",
    "Explore",
    "Quick Add",
    "More Options",
  ];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final response = await ApiService.getProfile();
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final rawRole = (userData['user'] != null ? userData['user']['role'] : userData['role'])?.toString().toLowerCase();
        
        if (rawRole == 'super admin' || rawRole == 'superadmin') {
          setState(() {
            _isSuperAdmin = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile for role check: $e");
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        try {
          final userData = jsonDecode(userDataStr);
          final rawRole = (userData['user'] != null ? userData['user']['role'] : userData['role'])?.toString().toLowerCase();
          
          if (rawRole == 'super admin' || rawRole == 'superadmin') {
            setState(() {
              _isSuperAdmin = true;
            });
          }
        } catch (_) {}
      }
    }
    setState(() {
      _isLoadingRole = false;
    });
  }

  List<Widget> get _screens {
    if (_isSuperAdmin) return _allScreens;
    return _allScreens.sublist(1);
  }

  List<String> get _titles {
    if (_isSuperAdmin) return _allTitles;
    return _allTitles.sublist(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        automaticallyImplyLeading: false,
        actions: [
          // If Explore tab (index 1 for super admin, index 0 for normal admin)
          if ((_isSuperAdmin && _currentIndex == 1) || (!_isSuperAdmin && _currentIndex == 0))
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProductHistoryScreen()),
                );
              },
            ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: [
          if (_isSuperAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: "Explore",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: "Add",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}

