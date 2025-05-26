// API manager for handling API requests and responses

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  static String baseUrl = dotenv.env['API_URL']!;

  static Map<String, String> baseHeaders = {
    'content-type': 'application/json',
    'accept': 'application/json',
    'authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
    "Device-ID": "01:01:01:01:01",
    "User-ID": "1"
  };

  static Future<Map<String, dynamic>> createUser(
      String email, String hashedPwd) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: baseHeaders,
      body: json.encode({
        'email': email,
        'password': hashedPwd,
        'username': email.split('@')[0],
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String hashedPwd) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: baseHeaders,
      body: json.encode({
        'email': email,
        'password': hashedPwd,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to login user, status code: ${response.statusCode}');
    }
  }

  // Method to fetch data from the API
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Method to post data to the API
  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: baseHeaders,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }
}
