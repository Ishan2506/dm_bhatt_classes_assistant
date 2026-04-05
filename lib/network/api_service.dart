import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dm_bhatt_classes_new/main.dart';
import 'package:dm_bhatt_classes_new/utils/connectivity_service.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://103.212.121.139:5000/api";

  /// Helper to get the full URL for a file (image, pdf, etc.)
  static String getFileUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith('http')) return url;
    
    // Remove /api from baseUrl to get the server root
    final serverRoot = baseUrl.replaceAll('/api', '');
    
    // If it's a relative path from our server
    if (url.startsWith('uploads/')) {
        return "$serverRoot/$url";
    }
    
    return url;
  }

  static Future<bool> _checkConnectivity() async {
    final isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      if (navigatorKey.currentContext != null) {
        CustomToast.showError(navigatorKey.currentContext!, "Internet connection is required");
      }
      return false;
    }
    return true;
  }

  static Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final Map<String, String> headers = {
      'User-Agent': 'Flutter-App',
    };

    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> getProfile() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/profile");
    return await http.get(uri, headers: await _getHeaders());
  }

  static Future<http.Response> editProfile({
    String? firstName,
    String? phoneNum,
    String? email,
    File? imageFile,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/profile");
    final request = http.MultipartRequest('PUT', uri);

    if (firstName != null) request.fields['firstName'] = firstName;
    if (phoneNum != null) request.fields['phoneNum'] = phoneNum;
    if (email != null) request.fields['email'] = email;

    if (imageFile != null) {
      final multipartFile = await http.MultipartFile.fromPath('photo', imageFile.path);
      request.files.add(multipartFile);
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> addExploreProduct({
    required String name,
    required String description,
    required String category,
    String? subject,
    required double price,
    required double originalPrice,
    required double discount,
    required PlatformFile file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/explore/add");
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category'] = category;
    if (subject != null) request.fields['subject'] = subject;
    request.fields['price'] = price.toString();
    request.fields['originalPrice'] = originalPrice.toString();
    request.fields['discount'] = discount.toString();

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getExploreProducts() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/explore/all");
    return await http.get(uri);
  }

  static Future<http.Response> editExploreProduct({
    required String id,
    String? name,
    String? description,
    String? category,
    String? subject,
    double? price,
    double? originalPrice,
    double? discount,
    PlatformFile? file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/explore/edit/$id");
    final request = http.MultipartRequest('PUT', uri);

    if (name != null) request.fields['name'] = name;
    if (description != null) request.fields['description'] = description;
    if (category != null) request.fields['category'] = category;
    if (subject != null) request.fields['subject'] = subject;
    if (price != null) request.fields['price'] = price.toString();
    if (originalPrice != null) request.fields['originalPrice'] = originalPrice.toString();
    if (discount != null) request.fields['discount'] = discount.toString();

    if (file != null) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: file.name,
      );
      request.files.add(multipartFile);
    }
    
    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> deleteExploreProduct(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/explore/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  static Future<http.Response> loginUser({
    required String role,
    required String loginCode,
    required String phoneNum,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
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
    String? email,
    required String phone,
    required String password,
    required String parentPhone,
    required String board,
    required String standard,
    required String medium,
    String? stream,
    required String state,
    required String city,
    String? address,
    String? schoolName,
    File? imageFile,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/add-student");
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['parentPhone'] = parentPhone;
    request.fields['board'] = board;
    request.fields['standard'] = standard;
    request.fields['medium'] = medium;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['state'] = state;
    request.fields['city'] = city;
    request.fields['address'] = address ?? "";
    request.fields['schoolName'] = schoolName ?? "";

    if (imageFile != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getAllStudents() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/all-students");
    return await http.get(uri);
  }

  static Future<http.Response> editStudent({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? parentPhone,
    String? board,
    String? standard,
    String? medium,
    String? stream,
    String? state,
    String? city,
    String? address,
    String? schoolName,
    File? imageFile,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/edit-student/$id");
    final request = http.MultipartRequest('PUT', uri);

    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (phone != null) request.fields['phone'] = phone;
    if (password != null && password.isNotEmpty) request.fields['password'] = password;
    if (parentPhone != null) request.fields['parentPhone'] = parentPhone;
    if (board != null) request.fields['board'] = board;
    if (standard != null) request.fields['standard'] = standard;
    if (medium != null) request.fields['medium'] = medium;
    if (stream != null) request.fields['stream'] = stream;
    if (state != null) request.fields['state'] = state;
    if (city != null) request.fields['city'] = city;
    if (address != null) request.fields['address'] = address;
    if (schoolName != null) request.fields['schoolName'] = schoolName;

    if (imageFile != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> deleteStudent(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/delete-student/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }



  static Future<http.Response> createPaperSet({
    required String examName,
    required String date,
    required String board,
    required String subject,
    required String medium,
    required String standard,
    required String stream,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/create");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'examName': examName,
        'date': date,
        'board': board,
        'subject': subject,
        'medium': medium,
        'standard': standard,
        'stream': stream,
      }),
    );
  }

  static Future<http.Response> getAllPaperSets() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/all");
    return await http.get(uri);
  }

  static Future<http.Response> updatePaperSetStatus(String id, String status, {String performedBy = 'Admin'}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/update-status/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'status': status,
        'performedBy': performedBy, 
      }),
    );
  }

  static Future<http.Response> getPaperSetLogs() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/logs");
    return await http.get(uri);
  }

  static Future<http.Response> editPaperSet({
    required String id,
    String? examName,
    String? date,
    String? board,
    String? subject,
    String? medium,
    String? standard,
    String? stream,
    // Add other fields if needed for edit
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/edit-paperset/$id");
    final body = {
      if (examName != null) 'examName': examName,
      if (date != null) 'date': date,
      if (board != null) 'board': board,
      if (subject != null) 'subject': subject,
      if (medium != null) 'medium': medium,
      if (standard != null) 'std': standard, // Backend expects 'std' or 'standard'? Controller checks 'std'.
      if (stream != null) 'stream': stream,
    };
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deletePaperSet(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/paperset/delete-paperset/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }


  static Future<http.Response> forgetPassword({
    required String email,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/auth/forget-password");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    return response;
  }

  static Future<http.Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/auth/verify-otp");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
    return response;
  }

  static Future<http.Response> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/auth/reset-password");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );
    return response;
  }
  static Future<http.Response> updatePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/auth/update-password");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    return response;
  }

  static Future<http.Response> importStudents({required List<int> bytes, required String filename}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/import-students");
    final request = http.MultipartRequest('POST', uri);
    
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadImage({required PlatformFile file}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/media/upload-image");
    final request = http.MultipartRequest('POST', uri);

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  // --- Exam APIs ---

  static Future<http.Response> uploadExamPdf({required List<int> bytes, required String filename}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/exam/upload-pdf");
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> createExam({
    required String title,
    required String subject,
    required String board,
    required String std,
    required String medium,
    String? stream,
    required String unit,
    required int totalMarks,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/exam/create");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "title": title,
        "subject": subject,
        "board": board,
        "std": std,
        "medium": medium,
        "stream": stream ?? "-",
        "unit": unit,
        "totalMarks": totalMarks,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> getAllExams({String? board, String? std, String? medium, String? stream, String? subject}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final queryParams = <String, String>{};
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null) queryParams['stream'] = stream;
    if (subject != null) queryParams['subject'] = subject;

    final uri = Uri.parse("$baseUrl/exam/all").replace(queryParameters: queryParams);
    return await http.get(uri);
  }

  static Future<http.Response> getExamById(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/exam/$id");
    return await http.get(uri);
  }

  static Future<http.Response> updateExam({
    required String id,
    required String title,
    required String subject,
    required String board,
    required String std,
    required String medium,
    String? stream,
    required String unit,
    required int totalMarks,
    required List<dynamic> questions,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/exam/update/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "title": title,
        "subject": subject,
        "board": board,
        "std": std,
        "medium": medium,
        "stream": stream ?? "-",
        "unit": unit,
        "totalMarks": totalMarks,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> deleteExam(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/exam/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  // --- 5 Min Test APIs ---

  static Future<http.Response> createFiveMinTest({
    required String title,
    required String board,
    required String std,
    required String medium,
    String? stream,
    required String subject,
    required String unit,
    required String overview,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/fiveMinTest/create");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "title": title,
        "board": board,
        "std": std,
        "medium": medium,
        "stream": stream ?? "-",
        "subject": subject,
        "unit": unit,
        "overview": overview,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> getAllFiveMinTests() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/fiveMinTest/all");
    return await http.get(uri);
  }

  static Future<http.Response> updateFiveMinTest({
    required String id,
    required String title,
    required String board,
    required String std,
    required String medium,
    String? stream,
    required String subject,
    required String unit,
    required String overview,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/fiveMinTest/update/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "title": title,
        "board": board,
        "std": std,
        "medium": medium,
        "stream": stream ?? "-",
        "subject": subject,
        "unit": unit,
        "overview": overview,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> deleteFiveMinTest(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/fiveMinTest/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  static Future<http.Response> uploadFiveMinTestPdf({required List<int> bytes, required String filename}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/fiveMinTest/upload-pdf");
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  // --- Top Ranker APIs ---

  static Future<http.Response> createTopRanker({
    required String studentName,
    required String percentage,
    required String subject,
    required String rank,
    required String standard,
    required String medium,
    String? stream,
    String? photo,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/topRanker/create");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "studentName": studentName,
        "percentage": percentage,
        "subject": subject,
        "rank": rank,
        "standard": standard,
        "medium": medium,
        "stream": stream ?? "-",
        "photo": photo,
      }),
    );
  }

  static Future<http.Response> getAllTopRankers() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/topRanker/all");
    return await http.get(uri);
  }

  static Future<http.Response> updateTopRanker({
    required String id,
    required String studentName,
    required String percentage,
    required String subject,
    required String rank,
    required String standard,
    required String medium,
    String? stream,
    String? photo,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/topRanker/update/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "studentName": studentName,
        "percentage": percentage,
        "subject": subject,
        "rank": rank,
        "standard": standard,
        "medium": medium,
        "stream": stream ?? "-",
        "photo": photo,
      }),
    );
  }

  static Future<http.Response> deleteTopRanker(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/topRanker/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  // --- Event APIs ---

  static Future<http.Response> createEvent({
    required String title,
    String? description,
    required DateTime date,
    required List<PlatformFile> images,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/event/create");
    final request = http.MultipartRequest("POST", uri);

    request.fields['title'] = title;
    if (description != null) {
      request.fields['description'] = description;
    }
    request.fields['date'] = date.toIso8601String();

    for (var image in images) {
      // For web, use bytes. For mobile, use path.
      if (image.bytes != null) {
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            image.bytes!,
            filename: image.name,
          );
          request.files.add(multipartFile);
      } else if (image.path != null) {
           final multipartFile = await http.MultipartFile.fromPath(
            'images',
            image.path!,
             filename: image.name,
          );
          request.files.add(multipartFile);
      }
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> getAllEvents() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/event/all");
    return await http.get(uri);
  }

  static Future<http.Response> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? date,
    List<PlatformFile>? newImages,
    List<String>? existingImages,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/event/update/$id");
    final request = http.MultipartRequest("PUT", uri);

    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (date != null) request.fields['date'] = date.toIso8601String();
    
    // Send existing images to keep (backend will filter out missing ones)
    if (existingImages != null) {
      for (var img in existingImages) {
        request.fields['existingImages'] = img; // Sending multiple fields with same name for array
      }
      // If only one image, or to ensure it's treated as array, backend needs to handle it.
      // Often better to send as JSON string if simple fields. 
      // Current backend logic: `const keptImages = Array.isArray(existingImages) ? existingImages : [existingImages];`
      // This works with multiple fields of same name in some frameworks, but explicit array syntax might be safer.
      // Let's rely on standard multipart behavior or change backend to parse JSON. 
      // For safety, let's keep it simple. If multiple, it sends multiple.
    }

    if (newImages != null) {
      for (var image in newImages) {
         if (image.bytes != null) {
            final multipartFile = http.MultipartFile.fromBytes(
              'images',
              image.bytes!,
              filename: image.name,
            );
            request.files.add(multipartFile);
        } else if (image.path != null) {
             final multipartFile = await http.MultipartFile.fromPath(
              'images',
              image.path!,
               filename: image.name,
            );
            request.files.add(multipartFile);
        }
      }
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> deleteEvent(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/event/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  // --- Game APIs ---

  static Future<http.Response> addGameQuestion({
    required String gameType,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    required String difficulty,
    Map<String, dynamic>? meta,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/add");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "gameType": gameType,
        "questionText": questionText,
        "options": options,
        "correctAnswer": correctAnswer,
        "difficulty": difficulty,
        "meta": meta ?? {},
      }),
    );
  }

  static Future<http.Response> getGameQuestions(String gameType) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/$gameType");
    return await http.get(uri);
  }

  static Future<http.Response> editGameQuestion({
    required String id,
    String? gameType,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? difficulty,
    Map<String, dynamic>? meta,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/edit/$id");
    final body = {
      if (gameType != null) "gameType": gameType,
      if (questionText != null) "questionText": questionText,
      if (options != null) "options": options,
      if (correctAnswer != null) "correctAnswer": correctAnswer,
      if (difficulty != null) "difficulty": difficulty,
      if (meta != null) "meta": meta,
    };
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteGameQuestion(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  static Future<http.Response> getGameTypes() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/types");
    return await http.get(uri);
  }

  static Future<http.Response> importGameQuestions({required List<int> bytes, required String filename, String? gameType}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/games/import");
    final request = http.MultipartRequest('POST', uri);
    
    if (gameType != null) {
      request.fields['gameType'] = gameType;
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  
  static Future<http.Response> getDashboardStats() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/dashboard-stats");
    return await http.get(uri);
  }

  static Future<http.Response> getExamReports({String? type, String? board, String? std, String? medium, String? stream, String? studentId}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    
    final Map<String, String> queryParams = {};
    if (type != null) queryParams['type'] = type;
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null) queryParams['stream'] = stream;
    if (studentId != null) queryParams['studentId'] = studentId;

    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    final uri = Uri.parse("$baseUrl/admin/exam-reports$queryString");
    return await http.get(uri);
  }

  static Future<http.Response> getStudentReports({String? board, String? std, String? medium, String? stream}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);

    final Map<String, String> queryParams = {};
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null) queryParams['stream'] = stream;

    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    final uri = Uri.parse("$baseUrl/admin/student-reports$queryString");
    return await http.get(uri);
  }

  // --- Mind Map APIs ---

  static Future<http.Response> createMindMap(Map<String, dynamic> data) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/mindmap/add");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> updateMindMap(String id, Map<String, dynamic> data) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/mindmap/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getAllMindMaps() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/mindmap/all");
    return await http.get(uri);
  }

  static Future<http.Response> deleteMindMap(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/mindmap/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  // --- One Liner Exam APIs ---

  static Future<http.Response> createOneLinerExam(Map<String, dynamic> data) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/onelinerexam/add");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getAllOneLinerExams() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/onelinerexam/all");
    return await http.get(uri);
  }

  static Future<http.Response> deleteOneLinerExam(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/onelinerexam/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  static Future<http.Response> updateOneLinerExam(String id, Map<String, dynamic> data) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/onelinerexam/$id");
    return await http.put(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  // --- Material APIs ---

  static Future<http.Response> uploadBoardPaper({
    required String title,
    required String board,
    required String medium,
    required String standard,
    String? stream,
    required String year,
    required String subject,
    required PlatformFile file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/upload-board-paper");
    final request = http.MultipartRequest('POST', uri);

    request.fields['board'] = board;
    request.fields['title'] = title;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['year'] = year;
    request.fields['subject'] = subject;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadSchoolPaper({
    required String title,
    required String board,
    required String subject,
    required String medium,
    required String standard,
    String? stream,
    required String year,
    required String schoolName,
    required PlatformFile file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/upload-school-paper");
    final request = http.MultipartRequest('POST', uri);

    request.fields['board'] = board;
    request.fields['title'] = title;
    request.fields['subject'] = subject;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['year'] = year;
    request.fields['schoolName'] = schoolName;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadImageMaterial({
    required String title,
    required String board,
    required String subject,
    required String unit,
    required String medium,
    required String standard,
    String? stream,
    required String year,
    String? schoolName,
    required PlatformFile file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/upload-image-material");
    final request = http.MultipartRequest('POST', uri);

    request.fields['board'] = board;
    request.fields['title'] = title;
    request.fields['subject'] = subject;
    request.fields['unit'] = unit;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['year'] = year;
    if (schoolName != null) request.fields['schoolName'] = schoolName;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadNotes({
    required String title,
    required String board,
    required String standard,
    required String medium,
    String? stream,
    required String subject,
    required String year,
    required PlatformFile file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/upload-notes");
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['board'] = board;
    request.fields['standard'] = standard;
    request.fields['medium'] = medium;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['subject'] = subject;
    request.fields['year'] = year;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> updateMaterial({
    required String id,
    required String title,
    required String board,
    required String subject,
    required String medium,
    required String standard,
    String? stream,
    required String year,
    String? schoolName,
    String? unit,
    PlatformFile? file,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/update/$id");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['board'] = board;
    request.fields['title'] = title;
    request.fields['subject'] = subject;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['year'] = year;
    if (schoolName != null) request.fields['schoolName'] = schoolName;
    if (unit != null) request.fields['unit'] = unit;

    if (file != null) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      );
      request.files.add(multipartFile);
    }

    request.headers.addAll(await _getHeaders(isJson: false));

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getAllMaterials({String? type}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final queryParams = type != null ? "?type=$type" : "";
    final uri = Uri.parse("$baseUrl/material/all$queryParams");
    return await http.get(uri);
  }

  static Future<http.Response> deleteMaterial(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/material/delete/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }
  static Future<http.Response> getStandardDetailedStats(String standard) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/dashboard/standard-stats/$standard");
    return await http.get(uri);
  }

  static Future<http.Response> getReferAndEarnReports({String? board, String? std, String? medium, String? stream}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);

    final Map<String, String> queryParams = {};
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null) queryParams['stream'] = stream;

    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    final uri = Uri.parse("$baseUrl/admin/refer-earn-report$queryString");
    return await http.get(uri);
  }

  static Future<http.Response> getUpgradePlanReports({String? board, String? std, String? medium, String? stream}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);

    final Map<String, String> queryParams = {};
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null) queryParams['stream'] = stream;

    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    final uri = Uri.parse("$baseUrl/admin/upgrade-plan-report$queryString");
    return await http.get(uri);
  }

  // --- Redeem Code APIs ---

  static Future<http.Response> generateRedeemCode({
    required double discount,
    String? board,
    String? std,
    String? medium,
    String? stream,
    required String createdBy,
  }) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/generate-redeem-code");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        "discount": discount,
        "board": board,
        "std": std,
        "medium": medium,
        "stream": stream,
        "createdBy": createdBy,
      }),
    );
  }

  static Future<http.Response> getRedeemCodes() async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/redeem-codes");
    return await http.get(uri);
  }

  static Future<http.Response> deleteRedeemCode(String id) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/delete-redeem-code/$id");
    return await http.delete(uri, headers: await _getHeaders());
  }

  // --- Leaderboard APIs ---

  static Future<http.Response> getAdminLeaderboard({String? board, String? std, String? medium, String? stream}) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);

    final Map<String, String> queryParams = {};
    if (board != null) queryParams['board'] = board;
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (stream != null && stream != 'None') queryParams['stream'] = stream;

    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    final uri = Uri.parse("$baseUrl/admin/leaderboard$queryString");
    return await http.get(uri);
  }

  static Future<http.Response> toggleStudentGiftStatus(String userId) async {
    if (!await _checkConnectivity()) return http.Response('{"error": "No internet connection"}', 503);
    final uri = Uri.parse("$baseUrl/admin/toggle-gift-status");
    return await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({"userId": userId}),
    );
  }
}
