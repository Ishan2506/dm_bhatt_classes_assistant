import 'dart:io';
import 'dart:convert';

import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/edit_profile_screen.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _assistantId = "";
  String _name = "User";
  String _role = "Assistant";
  String _mobile = "-";
  String _aadhar = "-";
  String _address = "-";
  bool _isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileFromApi();
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  String _readStringFromMap(Map<String, dynamic> map, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  Future<void> _loadProfileFromApi() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('user_role') ?? _role;
      final savedPhone = prefs.getString('user_phone') ?? '';
      final savedUserDataRaw = prefs.getString('user_data');
      final token = prefs.getString('auth_token') ?? '';

      Map<String, dynamic>? savedUserData;
      if (savedUserDataRaw != null && savedUserDataRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedUserDataRaw);
          if (decoded is Map<String, dynamic>) {
            savedUserData = decoded;
          }
        } catch (_) {}
      }

      final jwtPayload = token.isNotEmpty ? _decodeJwtPayload(token) : null;
      final jwtId = _readStringFromMap(jwtPayload ?? const {}, ['_id', 'id', 'userId']);
      final jwtPhone = _readStringFromMap(jwtPayload ?? const {}, ['phone', 'mobile', 'phoneNum']);

      final effectivePhone = savedPhone.isNotEmpty ? savedPhone : jwtPhone;

      Map<String, dynamic>? apiProfile;

      // Assistant profile from API list endpoint
      if (savedRole == "Assistant") {
        final response = await ApiService.getAllAssistants();
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          List<dynamic> assistantList = [];
          if (decoded is List) {
            assistantList = decoded;
          } else if (decoded is Map<String, dynamic>) {
            final rawList = decoded['assistants'] ?? decoded['data'] ?? decoded['items'] ?? decoded['result'];
            if (rawList is List) assistantList = rawList;
          }

          if (assistantList.isNotEmpty) {
            final normalizedSavedPhone = _normalizePhone(effectivePhone);
            final matchById = jwtId.isNotEmpty
                ? assistantList.firstWhere(
                    (item) {
                      if (item is! Map) return false;
                      final map = Map<String, dynamic>.from(item);
                      return _readStringFromMap(map, ['_id', 'id']) == jwtId;
                    },
                    orElse: () => null,
                  )
                : null;

            dynamic match = matchById;
            if (match == null && normalizedSavedPhone.isNotEmpty) {
              match = assistantList.firstWhere(
                (item) {
                  if (item is! Map) return false;
                  final map = Map<String, dynamic>.from(item);
                  final rawPhone = _readStringFromMap(map, ['phone', 'mobile', 'phoneNum']);
                  final normalizedApiPhone = _normalizePhone(rawPhone);
                  if (normalizedApiPhone.isEmpty) return false;
                  return normalizedApiPhone.endsWith(normalizedSavedPhone) ||
                      normalizedApiPhone == normalizedSavedPhone;
                },
                orElse: () => null,
              );
            }

            if (match is Map) {
              apiProfile = Map<String, dynamic>.from(match);
            }
          }
        }
      }

      final profile = apiProfile ?? savedUserData ?? jwtPayload ?? <String, dynamic>{};

      setState(() {
        _assistantId = _readStringFromMap(profile, ['_id', 'id']);
        _name = _readStringFromMap(profile, ['name', 'fullName', 'username'], fallback: _name);
        _role = _readStringFromMap(profile, ['role'], fallback: savedRole);
        _mobile = _readStringFromMap(profile, ['phone', 'mobile', 'phoneNum'], fallback: effectivePhone.isNotEmpty ? effectivePhone : '-');
        _aadhar = _readStringFromMap(profile, ['aadharNum', 'aadharNumber', 'aadhar'], fallback: '-');
        _address = _readStringFromMap(profile, ['address', 'location'], fallback: '-');
      });

      if (_mobile != '-' && _mobile.isNotEmpty) {
        await prefs.setString('user_phone', _mobile);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, "Failed to load profile");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          assistantId: _assistantId,
          name: _name,
          role: _role,
          mobile: _mobile,
          aadhar: _aadhar,
          address: _address,
        ),
      ),
    );

    if (result != null && result is Map) {
      _loadProfileFromApi();
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
        child: _isLoading
            ? const Center(child: Padding(
                padding: EdgeInsets.only(top: 120),
                child: CircularProgressIndicator(),
              ))
            : Column(
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
