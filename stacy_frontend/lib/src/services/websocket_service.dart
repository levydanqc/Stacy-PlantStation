// // services/websocket_service.dart
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// import 'package:stacy_frontend/src/services/logger.dart';

// class WebSocketService {
//   final String _webSocketUrl = dotenv.env['WEBSOCKET_URL']!;
//   WebSocketChannel? _channel;

//   final _messageController = StreamController<dynamic>.broadcast();
//   final _errorController = StreamController<dynamic>.broadcast();
//   final _doneController = StreamController<void>.broadcast();

//   Stream<dynamic> get messages => _messageController.stream;
//   Stream<dynamic> get errors => _errorController.stream;
//   Stream<void> get done => _doneController.stream;

//   bool _isConnecting =
//       false; // Flag to prevent multiple concurrent connect calls

//   // Connects to the WebSocket and sets up listeners.
//   // Returns a Future<bool> indicating if the initial connection attempt was successful.
//   Future<bool> connect() async {
//     // If a connection attempt is already in progress, prevent redundant calls.
//     if (_isConnecting) {
//       log.info('WebSocketService: Connection process already active.');
//       return false; // Indicate that no new connection was initiated
//     }

//     _isConnecting = true; // Mark as connecting

//     try {
//       // Attempt to close any existing channel gracefully before establishing a new one.
//       // Awaiting sink.close() ensures it attempts to complete the close handshake.
//       if (_channel != null) {
//         log.info(
//             'WebSocketService: Closing existing channel before new connection.');
//         await _channel!.sink.close();
//         _channel = null; // Clear the old channel reference
//       }

//       log.info("WebSocketService: Attempting to connect to $_webSocketUrl");
//       _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));

//       // Wait for the connection to be established. This future completes when
//       // the WebSocket is ready for use, or throws an error if it fails.
//       await _channel!.ready;
//       log.info("WebSocketService: Connection established.");

//       // Get UID from StorageManager and send it immediately after connection
//       final uid = await StorageManager().getString('uid');
//       if (uid != null) {
//         // Encode UID as a JSON string
//         _channel!.sink.add(jsonEncode({"uid": uid}));
//         log.info("WebSocketService: Sent UID: $uid");
//       } else {
//         log.warning(
//             "WebSocketService: UID is null, cannot send to WebSocket server.");
//       }

//       // Set up internal listeners that feed into the public StreamControllers
//       _channel!.stream.listen(
//         (message) {
//           _messageController.add(message);
//         },
//         onError: (error) {
//           _errorController.add(error);
//           log.warning("WebSocketService: Stream error caught: $error");
//           _isConnecting = false; // Reset connecting flag on stream error
//         },
//         onDone: () {
//           _doneController.add(null); // Signal that the channel is done
//           log.info("WebSocketService: Stream completed (onDone).");
//           _isConnecting = false; // Reset connecting flag on stream completion
//         },
//         cancelOnError: true, // Automatically cancels subscription on error
//       );

//       _isConnecting = false; // Connection attempt complete and successful
//       return true; // Indicate successful connection
//     } catch (e) {
//       log.severe("WebSocketService: Failed to connect WebSocket: $e");
//       _isConnecting = false; // Reset connecting flag on failure
//       _errorController
//           .add(e); // Also push the error to the error stream for listeners
//       return false; // Indicate failed connection
//     }
//   }

//   // Sends a raw message to the WebSocket server
//   void sendMessage(String message) {
//     // Check if _channel is not null, implying it was successfully connected.
//     // The state management in WeatherView (_isConnected) will guide whether to call this.
//     if (_channel != null) {
//       try {
//         _channel!.sink.add(message);
//         log.info("WebSocketService: Sent message: $message");
//       } catch (e) {
//         log.severe("WebSocketService: Error sending message: $e");
//         _errorController.add(e); // Propagate error to listeners
//       }
//     } else {
//       log.warning(
//           "WebSocketService: Cannot send message, channel is not initialized or closed.");
//     }
//   }

//   // Closes the WebSocket connection
//   void disconnect() {
//     log.info("WebSocketService: Disconnecting WebSocket.");
//     // Attempt to close the sink. The `onDone` listener will be triggered.
//     _channel?.sink
//         .close(1000, 'Client disconnected'); // 1000 is normal closure code
//     _isConnecting = false; // Ensure connecting flag is reset
//   }

//   // Dispose method to close all stream controllers when the service is no longer needed
//   void dispose() {
//     log.info("WebSocketService: Disposing service.");
//     disconnect(); // Ensure channel is closed first
//     _messageController.close();
//     _errorController.close();
//     _doneController.close();
//   }
// }
