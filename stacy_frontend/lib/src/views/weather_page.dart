// // weather_view.dart
// import 'dart:async'; // Import for StreamSubscription
// import 'dart:convert'; // For jsonDecode

// import 'package:flutter/material.dart';
// import 'package:stacy_frontend/src/models/plant.dart';
// import 'package:stacy_frontend/src/services/logger.dart';
// import 'package:stacy_frontend/src/services/websocket_service.dart';

// class WeatherPage extends StatefulWidget {
//   const WeatherPage({super.key});

//   static const routeName = '/websocket';

//   @override
//   State<WeatherPage> createState() => _WeatherPageState();
// }

// class _WeatherPageState extends State<WeatherPage> {
//   // Instantiate the WebSocketService
//   final WebSocketService _webSocketService = WebSocketService();

//   List<Plant> _weatherData = [];

//   // WebSocketChannel? _channel; // No longer directly managed here
//   String _connectionStatus = "Connecting...";
//   bool _isConnected = false;

//   // Stream subscriptions to manage lifecycle
//   StreamSubscription? _messageSubscription;
//   StreamSubscription? _errorSubscription;
//   StreamSubscription? _doneSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _subscribeToWebSocketService(); // Set up listeners first
//     _connectWebSocket(); // Then initiate the connection
//   }

//   // New method to subscribe to the service's streams
//   void _subscribeToWebSocketService() {
//     _messageSubscription = _webSocketService.messages.listen((message) {
//       // log.info("WeatherPage: Received from WebSocket (via service): $message");
//       if (mounted) {
//         try {
//           final data = jsonDecode(message);
//           // log.fine("WeatherPage: Decoded JSON data: $data");
//           if (data.containsKey('type')) {
//             if (data['type'] == 'initial_data') {
//               setState(() {
//                 _weatherData.clear();
//                 _weatherData.addAll((data['plants'] as List)
//                     .map((plant) => Plant.fromJson(plant))
//                     .toList());
//                 _connectionStatus = "Data Received";
//               });
//             } else if (data['type'] == 'update') {
//               setState(() {
//                 _weatherData.add(Plant.fromJson(data['plants']));
//                 _connectionStatus = "Data Received";
//               });
//             } else {
//               log.warning("Received unknown data type: ${data['type']}");
//               return; // Ignore unknown types
//             }
//           } else {
//             log.warning("Received unexpected data format: $data");
//             return; // Ignore unexpected data formats
//           }
//         } catch (e) {
//           log.warning("WeatherPage: Error decoding JSON: $e");
//         }
//       }
//     });

//     _errorSubscription = _webSocketService.errors.listen((error) {
//       log.warning("WeatherPage: WebSocket Error (from service): $error");
//       if (mounted) {
//         setState(() {
//           _connectionStatus = "Error: ${error.toString()}";
//           _isConnected = false;
//         });
//         _scheduleReconnect();
//       }
//     });

//     _doneSubscription = _webSocketService.done.listen((_) {
//       log.info("WeatherPage: WebSocket connection closed (from service)");
//       if (mounted) {
//         setState(() {
//           _connectionStatus = "Disconnected";
//           _isConnected = false;
//         });
//         _scheduleReconnect(); // Reconnect if closure was unexpected
//       }
//     });
//   }

//   void _connectWebSocket() {
//     setState(() {
//       _connectionStatus = "Connecting...";
//       _isConnected = false;
//       _weatherData = [];
//     });

//     _webSocketService.connect().then((connected) {
//       if (mounted) {
//         setState(() {
//           _isConnected = connected;
//           _connectionStatus = connected ? "Connected" : "Connection Failed";
//         });
//         if (!connected) {
//           _scheduleReconnect(); // Schedule reconnect if initial connection failed
//         } else {
//           log.info("WeatherPage: Initial connection attempt successful.");
//         }
//       }
//     }).catchError((e) {
//       log.severe("WeatherPage: Error during _webSocketService.connect: $e");
//       if (mounted) {
//         setState(() {
//           _connectionStatus = "Connection Failed: $e";
//           _isConnected = false;
//         });
//         _scheduleReconnect();
//       }
//     });
//   }

//   void _scheduleReconnect() {
//     if (!mounted) return;
//     log.info("WeatherPage: Scheduling reconnection in 5 seconds...");
//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted && !_isConnected) {
//         log.info("WeatherPage: Attempting to reconnect...");
//         _connectWebSocket();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get temperature and humidity, providing default values if null
//     final temperature = _weatherData.isNotEmpty ?
//             _weatherData[1].plantData.first.temperature : '--';
//     final humidity = _weatherData.isNotEmpty ?
//             _weatherData[1].plantData.first.humidity : '--';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Weather Data'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // Display Connection Status
//               Text(
//                 'Status: $_connectionStatus',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: _isConnected ? Colors.green : Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Display Weather Data (only if connected and data available)
//               if (_isConnected && _weatherData.isNotEmpty) ...[
//                 Card(
//                   elevation: 4.0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Temperature',
//                           style: Theme.of(context).textTheme.headlineSmall,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '$temperature °C',
//                           style: Theme.of(context)
//                               .textTheme
//                               .displaySmall
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Card(
//                   elevation: 4.0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Humidity',
//                           style: Theme.of(context).textTheme.headlineSmall,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '$humidity %',
//                           style: Theme.of(context)
//                               .textTheme
//                               .displaySmall
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Add more Card widgets here to display other data fields if needed
//               ] else if (!_isConnected) ...[
//                 // Show a reconnect button or message when disconnected
//                 const Text('Attempting to connect to the server...'),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _connectWebSocket, // Manually trigger reconnect
//                   child: const Text('Retry Connection'),
//                 )
//               ] else ...[
//                 // Show loading indicator while connected but waiting for first data
//                 const Text('Connected. Waiting for data...'),
//                 const SizedBox(height: 20),
//                 const CircularProgressIndicator(),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     log.info("WeatherPage: Disposing widget, cancelling subscriptions.");
//     _messageSubscription?.cancel();
//     _errorSubscription?.cancel();
//     _doneSubscription?.cancel();
//     // It's generally good practice to dispose of singletons too if they are no longer needed
//     // for the entire application's lifecycle, but often WebSocketService lives as long as the app.
//     // If you plan for the WebSocketService to persist across the app, don't call dispose here.
//     // If this is the ONLY place it's used and the app shuts down, then calling dispose is appropriate.
//     // For now, I'm assuming it might be used elsewhere or managed by a higher-level provider.
//     // If you need to ensure the service closes when the app closes,
//     // consider using WidgetsBindingObserver in your main app widget or a Provider.
//     // _webSocketService.dispose(); // Uncomment if you want service to dispose with this widget
//     super.dispose();
//   }
// }
