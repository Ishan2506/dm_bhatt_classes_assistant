import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dm_bhatt_classes_new/network/api_service.dart';

class AcademicConstants {
  static const List<String> boards = ["GSEB", "CBSE"];

  static Map<String, List<String>> standards = {};
  static Map<String, List<String>> subjects = {};

  static Future<void> loadFromServer() async {
    try {
      // 1. Fetch Standards
      final stdRes = await http.get(Uri.parse("${ApiService.baseUrl}/superadmin/standards"));
      if (stdRes.statusCode == 200) {
        List<dynamic> fetchedStandards = jsonDecode(stdRes.body);
        List<String> allStds = fetchedStandards.map((s) => s['name'].toString()).toList();
        
        // Broadcast across both boards since the backend handles subjects agnostic of board
        standards["GSEB"] = allStds;
        standards["CBSE"] = allStds;
      }

      // 2. Fetch Subjects
      final subRes = await http.get(Uri.parse("${ApiService.baseUrl}/superadmin/subjects"));
      if (subRes.statusCode == 200) {
        List<dynamic> fetchedSubjects = jsonDecode(subRes.body);
        Map<String, List<String>> newSubjectsMap = {};

        for(var sub in fetchedSubjects) {
          final standardInfo = sub['standardId'];
          if (standardInfo == null) continue;

          final String stdName = standardInfo['name']?.toString() ?? "";
          if (stdName.isEmpty) continue;

          final String streamName = (sub['stream'] != null && sub['stream'] != 'None') ? sub['stream'].toString() : "";
          
          final String gsebKey = streamName.isNotEmpty ? "GSEB-$stdName-$streamName" : "GSEB-$stdName";
          final String cbseKey = streamName.isNotEmpty ? "CBSE-$stdName-$streamName" : "CBSE-$stdName";

          if (!newSubjectsMap.containsKey(gsebKey)) newSubjectsMap[gsebKey] = [];
          if (!newSubjectsMap.containsKey(cbseKey)) newSubjectsMap[cbseKey] = [];
          
          final String subName = sub['name'].toString();
          if (!newSubjectsMap[gsebKey]!.contains(subName)) newSubjectsMap[gsebKey]!.add(subName);
          if (!newSubjectsMap[cbseKey]!.contains(subName)) newSubjectsMap[cbseKey]!.add(subName);
        }

        // Only override if data successfully collected
        if (newSubjectsMap.isNotEmpty) {
          subjects = newSubjectsMap;
        }
      }
    } catch(e) {
      debugPrint("Failed to load academic constants from server: \$e");
    }
  }

  static const List<String> mediums = ["English", "Gujarati"];
  static const List<String> marks = [
    "5", "10", "15", "20", "25", "30", "35", "40", "45", "50",
    "55", "60", "65", "70", "75", "80", "85", "90", "95", "100"
  ];
  static const List<String> oneLinerMarks = [
    "5", "10", "15", "20", "25", "30", "35", "40", "45", "50",
    "55", "60", "65", "70", "75", "80", "85", "90", "95", "100"
  ];
}
