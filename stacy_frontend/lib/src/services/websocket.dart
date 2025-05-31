import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final String _webSocketUrl = dotenv.env['WEBSOCKET_URL']!;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;

  // StreamController to expose incoming data to listeners
  // Using .broadcast() allows multiple widgets/services to listen
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  // StreamController to expose connection status messages
  final _statusController = StreamController<String>.broadcast();
  Stream<String> get statusStream => _statusController.stream;

  // Internal state to track connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected; // Public getter for connection status

  // Method to establish the WebSocket connection
  Future<void> connect() async {
    _statusController.add("Connecting...");
    _isConnected = false;
    _reconnectTimer?.cancel();

    try {
      // Close any existing channel before creating a new one
      _channel?.sink.close();

      // Establish the WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      _isConnected = true; // Optimistically assume connected
      _statusController.add("Connected");
      log.info("WebSocket connection established to $_webSocketUrl");

      // Get UID from StorageManager and send it immediately after connection
      // This is crucial for your server to identify the client
      StorageManager().getString('uid').then((uid) {
        if (uid != null) {
          // Send UID as a JSON string
          _channel!.sink.add(jsonEncode({"uid": uid}));
          log.info("Sent UID: $uid to WebSocket server.");
        } else {
          log.warning("UID is null, cannot send to WebSocket server.");
        }
      }).catchError((error) {
        log.severe("Error retrieving UID from StorageManager: $error");
      });

      // Listen for incoming messages from the server
      _channel!.stream.listen(
        (message) {
          try {
            final dynamic decodedData = jsonDecode(message);

            // Your original weather_view.dart had specific handling for List and Map.
            // We'll generalize to Map<String, dynamic> for the stream,
            // assuming the server sends single JSON objects for updates.
            // If the server sends a list, you might need to iterate or decide
            // how to present it to the stream.
            if (decodedData is Map<String, dynamic>) {
              _dataController
                  .add(decodedData); // Add decoded map data to the stream
            } else if (decodedData is List && decodedData.isNotEmpty) {
              // If server sends a list, and you want to process each item
              // Or just take the first item if it's the primary data
              for (var item in decodedData) {
                if (item is Map<String, dynamic>) {
                  _dataController.add(item);
                }
              }
              log.info(
                  "Received a list of data, processed as individual maps.");
            } else {
              log.warning(
                  "Received unexpected data type or empty list: ${decodedData.runtimeType} - $decodedData");
            }
          } catch (e) {
            log.warning("Error decoding JSON from WebSocket: $e");
          }
        },
        onError: (error) {
          log.warning("WebSocket Error: $error");
          _statusController.add("Error: ${error.toString()}");
          _isConnected = false;
          _scheduleReconnect(); // Attempt to reconnect on error
        },
        onDone: () {
          log.info("WebSocket connection closed");
          _statusController.add("Disconnected");
          _isConnected = false;
          _scheduleReconnect(); // Attempt to reconnect if connection closes unexpectedly
        },
        cancelOnError: true, // Automatically cancels subscription on error
      );
    } catch (e) {
      log.severe("Failed to connect WebSocket: $e");
      _statusController.add("Connection Failed");
      _isConnected = false;
      _scheduleReconnect(); // Schedule reconnect if initial connection fails
    }
  }

  // Method to send messages via WebSocket
  void sendMessage(String message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
      log.info("Sent message: $message");
    } else {
      log.warning("Cannot send message: WebSocket not connected.");
    }
  }

  // Method to close the WebSocket connection
  void disconnect() {
    log.info("Closing WebSocket connection.");
    _reconnectTimer?.cancel(); // Cancel any pending reconnect attempts
    // Close with a normal closure code (1000) and reason
    _channel?.sink.close(1000, 'Disconnected by client');
    _isConnected = false;
    _statusController.add("Disconnected");
  }

  // Schedules a reconnection attempt after a delay
  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return; // Already scheduled
    }
    log.info("Scheduling reconnection in 5 seconds...");
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        // Only try to reconnect if not already connected
        log.info("Attempting to reconnect...");
        connect();
      }
    });
  }

  // Dispose method to be called when the service is no longer needed (e.g., app shutdown)
  void dispose() {
    log.info("Disposing WebSocketService.");
    disconnect(); // Ensure channel is closed
    _dataController.close(); // Close the data stream
    _statusController.close(); // Close the status stream
    _reconnectTimer?.cancel(); // Cancel any pending reconnect attempts
    _channel = null; // Clear the channel reference
    _isConnected = false; // Reset connection state
  }
}
