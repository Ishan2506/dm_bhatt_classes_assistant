import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = "https://dmbhatt-api.onrender.com/api";
  // static const String baseUrl = "http://localhost:5000/api";

  static Future<http.Response> addExploreProduct({
    required String name,
    required String description,
    required String category,
    String? subject,
    required double price,
    required double originalPrice,
    required double discount,
    required XFile imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/explore/add");
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category'] = category;
    if (subject != null) request.fields['subject'] = subject;
    request.fields['price'] = price.toString();
    request.fields['originalPrice'] = originalPrice.toString();
    request.fields['discount'] = discount.toString();

    final bytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: imageFile.name,
    );
    request.files.add(multipartFile);

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getExploreProducts() async {
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
    XFile? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/explore/edit/$id");
    final request = http.MultipartRequest('PUT', uri);

    if (name != null) request.fields['name'] = name;
    if (description != null) request.fields['description'] = description;
    if (category != null) request.fields['category'] = category;
    if (subject != null) request.fields['subject'] = subject;
    if (price != null) request.fields['price'] = price.toString();
    if (originalPrice != null) request.fields['originalPrice'] = originalPrice.toString();
    if (discount != null) request.fields['discount'] = discount.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);
    }

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> deleteExploreProduct(String id) async {
    final uri = Uri.parse("$baseUrl/explore/delete/$id");
    return await http.delete(uri);
  }

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
    required String password,
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
    request.fields['password'] = password;
    request.fields['parentPhone'] = parentPhone;
    request.fields['standard'] = standard;
    request.fields['medium'] = medium;
    if (stream != null) request.fields['stream'] = stream;
    request.fields['state'] = state;
    request.fields['city'] = city;
    request.fields['address'] = address;
    request.fields['schoolName'] = schoolName;

    if (imageFile != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);
    }

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getAllStudents() async {
    final uri = Uri.parse("$baseUrl/admin/all-students");
    return await http.get(uri);
  }

  static Future<http.Response> editStudent({
    required String id,
    String? name,
    String? phone,
    String? password,
    String? parentPhone,
    String? standard,
    String? medium,
    String? stream,
    String? state,
    String? city,
    String? address,
    String? schoolName,
    File? imageFile,
  }) async {
    final uri = Uri.parse("$baseUrl/admin/edit-student/$id");
    final request = http.MultipartRequest('PUT', uri);

    if (name != null) request.fields['name'] = name;
    if (phone != null) request.fields['phone'] = phone;
    if (password != null && password.isNotEmpty) request.fields['password'] = password;
    if (parentPhone != null) request.fields['parentPhone'] = parentPhone;
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

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> deleteStudent(String id) async {
    final uri = Uri.parse("$baseUrl/admin/delete-student/$id");
    return await http.delete(uri);
  }

  static Future<http.Response> getAllAssistants() async {
    final uri = Uri.parse("$baseUrl/admin/all-assistants");
    return await http.get(uri);
  }

  static Future<http.Response> editAssistant({
    required String id,
    String? name,
    String? phone,
    String? password,
    String? address,
    String? aadharNumber,
  }) async {
    final uri = Uri.parse("$baseUrl/admin/edit-assistant/$id");
    final body = {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (password != null && password.isNotEmpty) 'password': password,
      if (address != null) 'address': address,
      if (aadharNumber != null) 'aadharNumber': aadharNumber,
    };
    return await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteAssistant(String id) async {
    final uri = Uri.parse("$baseUrl/admin/delete-assistant/$id");
    return await http.delete(uri);
  }

  static Future<http.Response> createPaperSet({
    required String examName,
    required String date,
    required String subject,
    required String medium,
    required String standard,
    required String stream,
  }) async {
    final uri = Uri.parse("$baseUrl/paperset/create");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'examName': examName,
        'date': date,
        'subject': subject,
        'medium': medium,
        'standard': standard,
        'stream': stream,
      }),
    );
  }

  static Future<http.Response> getAllPaperSets() async {
    final uri = Uri.parse("$baseUrl/paperset/all");
    return await http.get(uri);
  }

  static Future<http.Response> updatePaperSetStatus(String id, String status, {String performedBy = 'Assistant'}) async {
    final uri = Uri.parse("$baseUrl/paperset/update-status/$id");
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'performedBy': performedBy, 
      }),
    );
  }

  static Future<http.Response> getPaperSetLogs() async {
    final uri = Uri.parse("$baseUrl/paperset/logs");
    return await http.get(uri);
  }

  static Future<http.Response> editPaperSet({
    required String id,
    String? examName,
    String? date,
    String? subject,
    String? medium,
    String? standard,
    String? stream,
    // Add other fields if needed for edit
  }) async {
    final uri = Uri.parse("$baseUrl/paperset/edit-paperset/$id");
    final body = {
      if (examName != null) 'examName': examName,
      if (date != null) 'date': date,
      if (subject != null) 'subject': subject,
      if (medium != null) 'medium': medium,
      if (standard != null) 'std': standard, // Backend expects 'std' or 'standard'? Controller checks 'std'.
      if (stream != null) 'stream': stream,
    };
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deletePaperSet(String id) async {
    final uri = Uri.parse("$baseUrl/paperset/delete-paperset/$id");
    return await http.delete(uri);
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
        'password': password,
        'aadharNumber': aadharNumber,
        'address': address,
      }),
    );
    return response;
  }
  static Future<http.Response> forgetPassword({
    required String phone,
  }) async {
    final uri = Uri.parse("$baseUrl/auth/forget-password");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNum': phone,
      }),
    );
    return response;
  }

  static Future<http.Response> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final uri = Uri.parse("$baseUrl/auth/verify-otp");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNum': phone,
        'otp': otp,
      }),
    );
    return response;
  }

  static Future<http.Response> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    final uri = Uri.parse("$baseUrl/auth/reset-password");
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNum': phone,
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
    final uri = Uri.parse("$baseUrl/admin/import-students");
    final request = http.MultipartRequest('POST', uri);
    
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  // --- Exam APIs ---

  static Future<http.Response> uploadExamPdf({required List<int> bytes, required String filename}) async {
    final uri = Uri.parse("$baseUrl/exam/upload-pdf");
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> createExam({
    required String name,
    required String subject,
    required int totalMarks,
    required int duration,
    required List<Map<String, dynamic>> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/exam/create");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "subject": subject,
        "totalMarks": totalMarks,
        "duration": duration,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> getAllExams() async {
    final uri = Uri.parse("$baseUrl/exam/all");
    return await http.get(uri);
  }

  static Future<http.Response> getExamById(String id) async {
    final uri = Uri.parse("$baseUrl/exam/$id");
    return await http.get(uri);
  }

  static Future<http.Response> updateExam({
    required String id,
    required String name,
    required String subject,
    required int totalMarks,
    required int duration,
    required List<dynamic> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/exam/update/$id");
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "subject": subject,
        "totalMarks": totalMarks,
        "duration": duration,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> deleteExam(String id) async {
    final uri = Uri.parse("$baseUrl/exam/delete/$id");
    return await http.delete(uri);
  }

  // --- 5 Min Test APIs ---

  static Future<http.Response> createFiveMinTest({
    required String std,
    required String medium,
    String? stream,
    required String subject,
    required String unit,
    required String overview,
    required List<Map<String, dynamic>> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/fiveMinTest/create");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
    final uri = Uri.parse("$baseUrl/fiveMinTest/all");
    return await http.get(uri);
  }

  static Future<http.Response> updateFiveMinTest({
    required String id,
    required String std,
    required String medium,
    String? stream,
    required String subject,
    required String unit,
    required String overview,
    required List<Map<String, dynamic>> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/fiveMinTest/update/$id");
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
    final uri = Uri.parse("$baseUrl/fiveMinTest/delete/$id");
    return await http.delete(uri);
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
    final uri = Uri.parse("$baseUrl/topRanker/create");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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
    final uri = Uri.parse("$baseUrl/topRanker/update/$id");
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
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
    final uri = Uri.parse("$baseUrl/topRanker/delete/$id");
    return await http.delete(uri);
  }
}
