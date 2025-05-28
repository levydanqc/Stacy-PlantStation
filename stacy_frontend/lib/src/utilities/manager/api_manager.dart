// API manager for handling API requests and responses

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/models/plant_data.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';

class ApiManager {
  static String baseUrl = dotenv.env['API_URL']!;

  static Future<Map<String, String>> getHeaders() async {
    final String uid = await StorageManager().getString('uid') ?? '';
    final String? bearerToken = dotenv.env['BEARER_TOKEN'];

    final Map<String, String> headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': 'Bearer $bearerToken',
      'uid': uid,
    };

    return headers;
  }

  static Future<Map<String, dynamic>> createUser(
      String email, String hashedPwd) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: await getHeaders(),
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
      headers: await getHeaders(),
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

  static Future<List<Plant>> getUserPlants() async {
    // final response = await http.get(Uri.parse('$baseUrl/user/plants'),
    //     headers: await getHeaders());

    // if (response.statusCode == 200) {
    //   List<dynamic> jsonList = json.decode(response.body);
    //   return jsonList.map((json) => Plant.fromJson(json)).toList();
    // } else {
    //   throw Exception('Failed to load user plants');
    // }

    return [
      Plant(
        plantName: "Mint",
        plantData: [
          PlantData(
            timestamp: DateTime.parse("2025-05-26 10:00:00"),
            temperature: 22.5,
            humidity: 60.0,
            moisture: 30.0,
            pressure: 1013.0,
            hic: 23.2,
            batteryVoltage: 3.7,
            batteryPercentage: 85.0,
          ),
          PlantData(
            timestamp: DateTime.parse("2025-05-26 11:00:00"),
            temperature: 23.0,
            humidity: 58.0,
            moisture: 32.0,
            pressure: 1012.5,
            hic: 22.8,
            batteryVoltage: 3.6,
            batteryPercentage: 80.0,
          ),
          PlantData(
            timestamp: DateTime.parse("2025-05-26 12:00:00"),
            temperature: 23.5,
            humidity: 57.0,
            moisture: 31.0,
            pressure: 1012.0,
            hic: 22.5,
            batteryVoltage: 3.5,
            batteryPercentage: 75.0,
          ),
        ],
      )
    ];
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }
}
