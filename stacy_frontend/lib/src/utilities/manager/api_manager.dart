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

  static Future<String> getUid() async {
    final String? uid = await StorageManager().getString('uid');
    if (uid == null || uid.isEmpty) {
      throw Exception('User ID not found in storage');
    }
    return uid;
  }

  static Future<String> getBearerToken() async {
    final String? bearerToken = await SecureStorageManager().getBearerToken();
    if (bearerToken == null || bearerToken.isEmpty) {
      throw Exception('Bearer token not found in secure storage');
    }
    return bearerToken;
  }

  static Future<Map<String, String>> getHeaders(
      {String contentType = 'application/json',
      String? uid,
      String? bearerToken}) async {
    final Map<String, String> headers = {
      'content-type': contentType,
      'accept': 'application/json',
      'authorization': 'Bearer $bearerToken',
      'uid': uid ?? '',
    };

    return headers;
  }

  static Future<Map<String, dynamic>> signUp(String email, String pwd) async {
    String uid = await getUid();
    String bearerToken = await getBearerToken();

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: await getHeaders(uid: uid, bearerToken: bearerToken),
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
      log.fine('Bearer token: $bearerToken');
      await SecureStorageManager().setBearerToken(bearerToken);
      return json.decode(response.body);
    } else {
      throw Exception(
          json.decode(response.body)['error'] ?? 'Failed to login user');
    }
  }

  static Future<List<Plant>> getUserPlants() async {
    String uid = await getUid();
    String bearerToken = await getBearerToken();
    final Map<String, String> headers =
        await getHeaders(uid: uid, bearerToken: bearerToken);

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
      await StorageManager().logout();
      throw Exception('Invalid or expired token, user logged out');
    }

    log.warning(
        'Failed to load user plants, status code: ${response.statusCode}');
    throw Exception(
        'Failed to load user plants, status code: ${response.statusCode}');
  }

  // sendProvisioningRequest
  static Future<int> sendProvisioningRequest(
      String ssid, String password) async {
    final String deviceIP = dotenv.env['DEVICE_IP']!;
    final String uid = await getUid();
    final String bearerToken = await getBearerToken();

    final uri = Uri.parse('http://$deviceIP/credentials');

    final headers =
        await getHeaders(contentType: 'application/x-www-form-urlencoded');
    try {
      final response = await http.post(uri, headers: headers, body: {
        'ssid': ssid,
        'password': password,
        'uid': uid,
        'bearer_token': bearerToken,
      });

      log.info("Sending json to $deviceIP :");
      log.info({
        'ssid': ssid,
        'password': password,
        'uid': uid,
        'bearer_token': bearerToken,
      });

      if (response.statusCode == 200) {
        log.info('Device provisioned successfully');
      } else {
        log.warning('Failed to provision device: ${response.body}');
      }
      return response.statusCode;
    } catch (e) {
      log.severe('Error sending provisioning request: $e');
      rethrow;
    }
  }
}
