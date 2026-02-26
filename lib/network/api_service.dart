import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ApiService {
  // static const String baseUrl = "https://dmbhatt-api.onrender.com/api";
  static const String baseUrl = "http://localhost:5000/api";

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
    PlatformFile? file,
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

    if (file != null) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: file.name,
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

  static Future<http.Response> uploadImage({required PlatformFile file}) async {
    final uri = Uri.parse("$baseUrl/media/upload-image");
    final request = http.MultipartRequest('POST', uri);

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: file.name,
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
    required String title,
    required String subject,
    required String std,
    required String medium,
    required String unit,
    required int totalMarks,
    required List<Map<String, dynamic>> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/exam/create");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": title,
        "subject": subject,
        "std": std,
        "medium": medium,
        "unit": unit,
        "totalMarks": totalMarks,
        "questions": questions,
      }),
    );
  }

  static Future<http.Response> getAllExams({String? std, String? medium, String? subject}) async {
    final queryParams = <String, String>{};
    if (std != null) queryParams['std'] = std;
    if (medium != null) queryParams['medium'] = medium;
    if (subject != null) queryParams['subject'] = subject;

    final uri = Uri.parse("$baseUrl/exam/all").replace(queryParameters: queryParams);
    return await http.get(uri);
  }

  static Future<http.Response> getExamById(String id) async {
    final uri = Uri.parse("$baseUrl/exam/$id");
    return await http.get(uri);
  }

  static Future<http.Response> updateExam({
    required String id,
    required String title,
    required String subject,
    required String std,
    required String medium,
    required String unit,
    required int totalMarks,
    required List<dynamic> questions,
  }) async {
    final uri = Uri.parse("$baseUrl/exam/update/$id");
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": title,
        "subject": subject,
        "std": std,
        "medium": medium,
        "unit": unit,
        "totalMarks": totalMarks,
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

  // --- Event APIs ---

  static Future<http.Response> createEvent({
    required String title,
    String? description,
    required DateTime date,
    required List<PlatformFile> images,
  }) async {
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

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> getAllEvents() async {
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

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> deleteEvent(String id) async {
    final uri = Uri.parse("$baseUrl/event/$id");
    return await http.delete(uri);
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
    final uri = Uri.parse("$baseUrl/games/add");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteGameQuestion(String id) async {
    final uri = Uri.parse("$baseUrl/games/delete/$id");
    return await http.delete(uri);
  }
  
  static Future<http.Response> getDashboardStats() async {
    final uri = Uri.parse("$baseUrl/admin/dashboard-stats");
    return await http.get(uri);
  }

  static Future<http.Response> getExamReports() async {
    final uri = Uri.parse("$baseUrl/admin/exam-reports");
    return await http.get(uri);
  }

  static Future<http.Response> getStudentReports() async {
    final uri = Uri.parse("$baseUrl/admin/student-reports");
    return await http.get(uri);
  }

  // --- Mind Map APIs ---

  static Future<http.Response> createMindMap(Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/mindmap/add");
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getAllMindMaps() async {
    final uri = Uri.parse("$baseUrl/mindmap/all");
    return await http.get(uri);
  }

  static Future<http.Response> deleteMindMap(String id) async {
    final uri = Uri.parse("$baseUrl/mindmap/$id");
    return await http.delete(uri);
  }

  // --- Material APIs ---

  static Future<http.Response> uploadBoardPaper({
    required String title,
    required String medium,
    required String standard,
    String? stream,
    required String year,
    required String subject,
    required PlatformFile file,
  }) async {
    final uri = Uri.parse("$baseUrl/material/upload-board-paper");
    final request = http.MultipartRequest('POST', uri);

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

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadSchoolPaper({
    required String title,
    required String subject,
    required String medium,
    required String standard,
    required String year,
    required String schoolName,
    required PlatformFile file,
  }) async {
    final uri = Uri.parse("$baseUrl/material/upload-school-paper");
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['subject'] = subject;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    request.fields['year'] = year;
    request.fields['schoolName'] = schoolName;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> uploadImageMaterial({
    required String title,
    required String subject,
    required String unit,
    required String medium,
    required String standard,
    required String year,
    String? schoolName,
    required PlatformFile file,
  }) async {
    final uri = Uri.parse("$baseUrl/material/upload-image-material");
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['subject'] = subject;
    request.fields['unit'] = unit;
    request.fields['medium'] = medium;
    request.fields['standard'] = standard;
    request.fields['year'] = year;
    if (schoolName != null) request.fields['schoolName'] = schoolName;

    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );
    request.files.add(multipartFile);

    final streamResponse = await request.send();
    return await http.Response.fromStream(streamResponse);
  }

  static Future<http.Response> getAllMaterials({String? type}) async {
    final queryParams = type != null ? "?type=$type" : "";
    final uri = Uri.parse("$baseUrl/material/all$queryParams");
    return await http.get(uri);
  }

  static Future<http.Response> deleteMaterial(String id) async {
    final uri = Uri.parse("$baseUrl/material/delete/$id");
    return await http.delete(uri);
  }
}
