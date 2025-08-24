// lib\services\api_service.dart
// Handles API calls (submit, fetch, etc.)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/registration_data.dart';

class ApiService {
  // static const String baseUrl = 'http://127.0.0.1:5566/api';
  static const String baseUrl = "http://localhost:5566"; // Go Fiber API URL

  static Future<Map<String, dynamic>> submitRegistration(RegistrationData reg) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reg.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit form: ${response.body}');
    }
  }
}
