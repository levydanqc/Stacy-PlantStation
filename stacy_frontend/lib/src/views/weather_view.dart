import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // For WebSocket communication
import 'dart:convert'; // For jsonDecode

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({super.key});

  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  // IMPORTANT: Replace '<YOUR_SERVER_IP>' with the actual local IP address
  // of the machine running your Node.js server.
  // The port should match the HTTP_PORT in your server.js (e.g., 8080).
  final String _webSocketUrl =
      'ws://<YOUR_SERVER_IP>:8080'; // Example: 'ws://192.168.1.105:8080'

  WebSocketChannel? _channel; // Make channel nullable
  Map<String, dynamic> _weatherData = {}; // Store latest weather data
  String _connectionStatus = "Connecting..."; // Display connection status
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    setState(() {
      _connectionStatus = "Connecting...";
      _isConnected = false;
      _weatherData = {}; // Clear old data on reconnect attempt
    });

    try {
      // Close existing channel if any before creating a new one
      _channel?.sink.close();

      // Establish the WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      _isConnected =
          true; // Assume connected initially, stream listeners will update
      setState(() {
        _connectionStatus = "Connected";
      });
      print("WebSocket connection established to $_webSocketUrl");

      // Listen for incoming messages from the server
      _channel!.stream.listen(
        (message) {
          print("Received from WebSocket: $message");
          if (mounted) {
            // Check if the widget is still in the tree
            try {
              // Assuming server sends data as a JSON string
              final data = jsonDecode(message);
              if (data is Map<String, dynamic>) {
                setState(() {
                  _weatherData = data;
                  // Update status only if it changed
                  if (!_isConnected || _connectionStatus != "Connected") {
                    _connectionStatus = "Connected";
                    _isConnected = true;
                  }
                });
              } else {
                print("Received non-map JSON data: $data");
              }
            } catch (e) {
              print("Error decoding JSON: $e");
              // Optionally update status to show data format error
              // setState(() {
              //   _connectionStatus = "Data Error";
              // });
            }
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          if (mounted) {
            setState(() {
              _connectionStatus = "Error: ${error.toString()}";
              _isConnected = false;
            });
            // Optional: Implement retry logic here
            _scheduleReconnect();
          }
        },
        onDone: () {
          print("WebSocket connection closed");
          if (mounted) {
            setState(() {
              _connectionStatus = "Disconnected";
              _isConnected = false;
            });
            // Optional: Implement retry logic here if the closure was unexpected
            _scheduleReconnect();
          }
        },
        cancelOnError: true, // Automatically cancels subscription on error
      );
    } catch (e) {
      print("Failed to connect WebSocket: $e");
      if (mounted) {
        setState(() {
          _connectionStatus = "Connection Failed";
          _isConnected = false;
        });
        _scheduleReconnect();
      }
    }
  }

  // Optional: Simple reconnection logic
  void _scheduleReconnect() {
    if (!mounted) return; // Don't schedule if widget is disposed
    print("Scheduling reconnection in 5 seconds...");
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && !_isConnected) {
        // Check again if mounted and not connected
        print("Attempting to reconnect...");
        _connectWebSocket();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get temperature and humidity, providing default values if null
    final temperature = _weatherData['temperature']?.toStringAsFixed(2) ?? '--';
    final humidity = _weatherData['humidity']?.toStringAsFixed(2) ?? '--';

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Weather Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display Connection Status
              Text(
                'Status: $_connectionStatus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 30),

              // Display Weather Data (only if connected and data available)
              if (_isConnected && _weatherData.isNotEmpty) ...[
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Temperature',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$temperature °C',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Humidity',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$humidity %',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add more Card widgets here to display other data fields if needed
              ] else if (!_isConnected) ...[
                // Show a reconnect button or message when disconnected
                Text('Attempting to connect to the server...'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _connectWebSocket, // Manually trigger reconnect
                  child: Text('Retry Connection'),
                )
              ] else ...[
                // Show loading indicator while connected but waiting for first data
                Text('Connected. Waiting for data...'),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("Closing WebSocket connection.");
    _channel?.sink
        .close(); // Close the WebSocket connection when the widget is disposed
    super.dispose();
  }
}
