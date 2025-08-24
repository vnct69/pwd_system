// lib\services\api_service.dart
// Handles API calls (submit, fetch, etc.)

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/registration_data.dart';

// class ApiService {
//   static const String baseUrl = "http://localhost:5566"; // your Go Fiber API URL
//   // final String apiUrl = "http://localhost:5566/api/registration";


//   static Future<bool> submitRegistration(Registration data) async {
//     final url = Uri.parse("$baseUrl/register");

//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(data.toJson()),
//     );

//     return response.statusCode == 200;
//   }
// }
