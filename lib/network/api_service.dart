import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "https://dmbhatt-api.onrender.com/api";

  static Future<http.Response> loginUser({
    required String role,
    required String loginCode,
    required String phoneNum,
  }) async {
    final uri = Uri.parse("$baseUrl/auth/login");
    // Ensure role is lowercase as backend expects 'admin', 'student', etc.
    final String formattedRole = role.toLowerCase();
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter-App',
      },
      body: jsonEncode({
        'role': formattedRole,
        'loginCode': loginCode,
        'phoneNum': phoneNum,
      }),
    );
    return response;
  }

  static Future<http.Response> addStudent({
    required String name,
    required String phone,
    required String password, // Added password
    required String parentPhone,
    required String standard,
    required String medium,
    String? stream,
    required String state,
    required String city,
    required String address,
    required String schoolName,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/admin/add-student");
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password; // Added password
    request.fields['parentPhone'] = parentPhone;
    request.fields['standard'] = standard;
    request.fields['medium'] = medium;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['state'] = state;
    request.fields['city'] = city;
    request.fields['address'] = address;
    request.fields['schoolName'] = schoolName;

    if (imageFile != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', imageFile.path); // Matched backend 'image'
      request.files.add(multipartFile);
    }

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> addAssistant({
    required String name,
    required String phone,
    required String password,
    required String aadharNumber,
    required String address,
  }) async {
    final uri = Uri.parse("$baseUrl/admin/add-assistant");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'password': password, // Added password
        'aadharNumber': aadharNumber, // Changed from aadharName
        'address': address,
      }),
    );
    return response;
  }
}
