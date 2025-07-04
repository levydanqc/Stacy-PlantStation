// API manager for handling API requests and responses

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart' show log;
import 'package:stacy_frontend/src/utilities/manager/secure_storage_manager.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';

class ApiManager {
  static String baseUrl = dotenv.env['API_URL']!;

  static Future<Map<String, String>> getHeaders() async {
    final String uid = await StorageManager().getString('uid') ?? '';
    final String? bearerToken = await SecureStorageManager().getBearerToken();

    final Map<String, String> headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': 'Bearer $bearerToken',
      'uid': uid,
    };

    return headers;
  }

  static Future<Map<String, dynamic>> signUp(String email, String pwd) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: await getHeaders(),
      body: json.encode({
        'email': email,
        'password': pwd,
      }),
    );

    if (response.statusCode == 201) {
      log.info('User created successfully: ${response.body}');
      final String? bearerToken = response.headers['auth_token'];
      if (bearerToken == null) {
        throw Exception('Bearer token not found in response headers');
      }

      await SecureStorageManager().setBearerToken(bearerToken);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String pwd) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await getHeaders(),
      body: json.encode({
        'email': email,
        'password': pwd,
      }),
    );

    if (response.statusCode == 200) {
      log.info('User logged in successfully: ${response.body}');
      final String? bearerToken = response.headers['auth_token'];
      if (bearerToken == null) {
        throw Exception('Bearer token not found in response headers');
      }

      await SecureStorageManager().setBearerToken(bearerToken);
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to login user, status code: ${response.statusCode} and body: ${response.body}');
    }
  }

  static Future<List<Plant>> getUserPlants() async {
    final Map<String, String> headers = await getHeaders();
    final String uid = headers['uid']!;

    final response = await http.get(Uri.parse('$baseUrl/users/$uid/plants'),
        headers: headers);

    if (response.statusCode == 200) {
      log.info('User plants fetched successfully');

      final List<dynamic> plantsJson = json.decode(response.body)['plants'];

      final List<Plant> plants = plantsJson.map((plant) {
        return Plant.fromJson(plant);
      }).toList();

      return plants;
    }

    if (response.statusCode == 403) {
      log.warning('Invalid or expired token, logging out user');
      await StorageManager().logoutUser();
      throw Exception('Invalid or expired token, user logged out');
    }

    log.warning(
        'Failed to load user plants, status code: ${response.statusCode}');
    throw Exception(
        'Failed to load user plants, status code: ${response.statusCode}');
  }
}
