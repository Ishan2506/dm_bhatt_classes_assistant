import 'dart:io';

import 'package:dm_bhatt_classes_new/screen/assistant/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _name = "Devarsh Shah";
  String _role = "Assistant";
  String _mobile = "+91 9106315912";
  String _aadhar = "XXXX-XXXX-1234";
  String _address = "123, Some Street, Ahmedabad.";
  File? _profileImage;

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: _name,
          role: _role,
          mobile: _mobile,
          aadhar: _aadhar,
          address: _address,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _name = result['name'];
        _mobile = result['mobile'];
        _aadhar = result['aadhar'];
        _address = result['address'];
        if (result['image'] != null) {
          _profileImage = result['image'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             Center(
              child: Stack(
                children: [
                   Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : "U", 
                              style: GoogleFonts.poppins(fontSize: 40, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _name,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _role,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildDetailItem(context, Icons.phone_outlined, "Mobile Number", _mobile),
            const SizedBox(height: 16),
            _buildDetailItem(context, Icons.credit_card_outlined, "Aadhar Number", _aadhar),
            const SizedBox(height: 16),
            _buildDetailItem(context, Icons.location_on_outlined, "Address", _address),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
