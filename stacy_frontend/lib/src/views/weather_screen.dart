import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';

import '../../socker_manager/socket_manager.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  // show weather data in a simple text
  String weatherData = "Weather data will be shown here";
  String message = "Message will be shown here";

  void handleLocalBroadcast(String message) {
    setState(() {
      this.message = message;
    });
  }

  void _addBroadcastObservers() {
    FBroadcast.instance().register(
      "message_received",
      context: this,
      (value, callback) {
        handleLocalBroadcast(value as String);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _addBroadcastObservers();
    SocketManager.shared.connect();
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister("message_received");
    SocketManager.shared.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              weatherData,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
