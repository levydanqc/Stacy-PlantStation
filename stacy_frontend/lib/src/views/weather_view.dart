// import 'dart:convert'; // For jsonDecode

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:stacy_frontend/src/models/plant.dart';
// import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
// import 'package:stacy_frontend/src/widgets/home/home_no_plants_view.dart';
// import 'package:stacy_frontend/src/widgets/home/home_show_plants.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// import '../services/logger.dart' show log;

// class WeatherView extends StatefulWidget {
//   const WeatherView({super.key});

//   static const routeName = '/weather';

//   @override
//   State<WeatherView> createState() => _WeatherViewState();
// }

// class _WeatherViewState extends State<WeatherView> {
//   final String _webSocketUrl = dotenv.env['WEBSOCKET_URL']!;

//   List<Map<String, dynamic>> _weatherData = [];

//   WebSocketChannel? _channel;
//   String _connectionStatus = "Connecting...";
//   bool _isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _connectWebSocket(); 
//   }

//   void _connectWebSocket() {
//     setState(() {
//       _connectionStatus = "Connecting...";
//       _isConnected = false;
//       _weatherData = [];
//     });

//     try {
//       _channel?.sink.close();

//       // Establish the WebSocket connection
//       _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
//       _isConnected =
//           true; // Assume connected initially, stream listeners will update
//       setState(() {
//         _connectionStatus = "Connected";
//       });
//       log.info("WebSocket connection established to $_webSocketUrl");

//       // get uid from StorageManager
//       StorageManager().getString('uid').then((uid) {
//         if (uid != null) {
//           _channel!.sink.add("{\"uid\": \"$uid\"}");
//           // Listen for incoming messages from the server
//           _channel!.stream.listen(
//             (message) {
//               log.info("Received from WebSocket: $message");
//               if (mounted) {
//                 try {
//                   final data = jsonDecode(message);
//                   // log.fine("Decoded JSON data: $data");
//                   if (data is List) {
//                     // If the data is a list, update the weatherData
//                     setState(() {
//                       _weatherData = List<Map<String, dynamic>>.from(data);
//                       _connectionStatus = "Data Received";
//                     });
//                   } else if (data is Map && data['type'] == 'update') {
//                     setState(() {
//                       // add to the existing weatherData and update temp and humidity
//                       _weatherData.add(Map<String, dynamic>.from(data));
//                       _weatherData[0]['temperature'] = data['temperature'];
//                       _weatherData[0]['humidity'] = data['humidity'];
//                       _connectionStatus = "Data Received";
//                     });
//                   } else if (data is String) {
//                     log.warning("Received string data: $data");
//                   } else {
//                     log.warning("Expected a list but got: ${data.runtimeType}");
//                     log.warning("Unexpected data format: $data");
//                   }
//                 } catch (e) {
//                   log.warning("Error decoding JSON: $e");
//                 }
//               }
//             },
//             onError: (error) {
//               log.warning("WebSocket Error: $error");
//               if (mounted) {
//                 setState(() {
//                   _connectionStatus = "Error: ${error.toString()}";
//                   _isConnected = false;
//                 });
//                 // Optional: Implement retry logic here
//                 _scheduleReconnect();
//               }
//             },
//             onDone: () {
//               log.info("WebSocket connection closed");
//               if (mounted) {
//                 setState(() {
//                   _connectionStatus = "Disconnected";
//                   _isConnected = false;
//                 });
//                 // Optional: Implement retry logic here if the closure was unexpected
//                 _scheduleReconnect();
//               }
//             },
//             cancelOnError: true, // Automatically cancels subscription on error
//           );
//         } else {
//           log.warning("UID is null, cannot subscribe to WebSocket.");
//         }
//       }).catchError((error) {
//         log.severe("Error retrieving UID: $error");
//       });
//     } catch (e) {
//       log.severe("Failed to connect WebSocket: $e");
//       if (mounted) {
//         setState(() {
//           _connectionStatus = "Connection Failed";
//           _isConnected = false;
//         });
//         _scheduleReconnect();
//       }
//     }
//   }

//   void _scheduleReconnect() {
//     if (!mounted) return; // Don't schedule if widget is disposed
//     log.info("Scheduling reconnection in 5 seconds...");
//     Future.delayed(Duration(seconds: 5), () {
//       if (mounted && !_isConnected) {
//         // Check again if mounted and not connected
//         log.info("Attempting to reconnect...");
//         _connectWebSocket();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get temperature and humidity, providing default values if null
//     // final temperature =
//     //     _weatherData.isNotEmpty && _weatherData[0]['temperature'] != null
//     //         ? _weatherData[0]['temperature'].toStringAsFixed(2)
//     //         : '--';
//     // final humidity =
//     //     _weatherData.isNotEmpty && _weatherData[0]['humidity'] != null
//     //         ? _weatherData[0]['humidity'].toStringAsFixed(2)
//     //         : '--';

//     return SafeArea(
//       child: Builder(
//         builder: _buildView,
//       ),
//     );

//     // return Scaffold(
//     //   appBar: AppBar(
//     //     title: Text('Live Weather Data'),
//     //   ),
//     //   body: Center(
//     //     child: Padding(
//     //       padding: const EdgeInsets.all(20.0),
//     //       child: Column(
//     //         mainAxisAlignment: MainAxisAlignment.center,
//     //         children: <Widget>[
//     //           // Display Connection Status
//     //           Text(
//     //             'Status: $_connectionStatus',
//     //             style: TextStyle(
//     //               fontSize: 16,
//     //               fontWeight: FontWeight.w500,
//     //               color: _isConnected ? Colors.green : Colors.red,
//     //             ),
//     //           ),
//     //           SizedBox(height: 30),

//     //           // Display Weather Data (only if connected and data available)
//     //           if (_isConnected && _weatherData.isNotEmpty) ...[
//     //             Card(
//     //               elevation: 4.0,
//     //               shape: RoundedRectangleBorder(
//     //                   borderRadius: BorderRadius.circular(10)),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.all(16.0),
//     //                 child: Column(
//     //                   children: [
//     //                     Text(
//     //                       'Temperature',
//     //                       style: Theme.of(context).textTheme.headlineSmall,
//     //                     ),
//     //                     SizedBox(height: 8),
//     //                     Text(
//     //                       '$temperature °C',
//     //                       style: Theme.of(context)
//     //                           .textTheme
//     //                           .displaySmall
//     //                           ?.copyWith(fontWeight: FontWeight.bold),
//     //                     ),
//     //                   ],
//     //                 ),
//     //               ),
//     //             ),
//     //             SizedBox(height: 20),
//     //             Card(
//     //               elevation: 4.0,
//     //               shape: RoundedRectangleBorder(
//     //                   borderRadius: BorderRadius.circular(10)),
//     //               child: Padding(
//     //                 padding: const EdgeInsets.all(16.0),
//     //                 child: Column(
//     //                   children: [
//     //                     Text(
//     //                       'Humidity',
//     //                       style: Theme.of(context).textTheme.headlineSmall,
//     //                     ),
//     //                     SizedBox(height: 8),
//     //                     Text(
//     //                       '$humidity %',
//     //                       style: Theme.of(context)
//     //                           .textTheme
//     //                           .displaySmall
//     //                           ?.copyWith(fontWeight: FontWeight.bold),
//     //                     ),
//     //                   ],
//     //                 ),
//     //               ),
//     //             ),
//     //             // Add more Card widgets here to display other data fields if needed
//     //           ] else if (!_isConnected) ...[
//     //             // Show a reconnect button or message when disconnected
//     //             Text('Attempting to connect to the server...'),
//     //             SizedBox(height: 20),
//     //             ElevatedButton(
//     //               onPressed: _connectWebSocket, // Manually trigger reconnect
//     //               child: Text('Retry Connection'),
//     //             )
//     //           ] else ...[
//     //             // Show loading indicator while connected but waiting for first data
//     //             Text('Connected. Waiting for data...'),
//     //             SizedBox(height: 20),
//     //             CircularProgressIndicator(),
//     //           ]
//     //         ],
//     //       ),
//     //     ),
//     //   ),
//     // );
//   }

//   @override
//   void dispose() {
//     log.info("Closing WebSocket connection.");
//     _channel?.sink
//         .close(); // Close the WebSocket connection when the widget is disposed
//     super.dispose();
//   }

//   Widget _buildView(context) {
//     if (_isConnected && _weatherData.isNotEmpty) {
//       return buildPlantsDisplayView(
//           context, _weatherData.cast<Plant>(), PageController(), 0);
//     } else if (_isConnected && _weatherData.isEmpty) {
//       return buildNoPlantsView(context);
//     } else if (!_isConnected) {
//       // Offer an option to connect again
//       return Column(
//         children: [
//           Text('Attempting to connect to the server...'),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Retry connection logic
//               // _webSocketService.connect();
//               _connectWebSocket();
//               setState(() {
//                 _connectionStatus = "Reconnecting...";
//               });
//             },
//             child: Text('Retry Connection'),
//           ),
//         ],
//       );
//     } else {
//       // Show loading indicator while connected but waiting for first data
//       return Column(children: [
//         Text('Connected. Waiting for data...'),
//         SizedBox(height: 20),
//         CircularProgressIndicator(),
//       ]);
//     }
//   }
// }
