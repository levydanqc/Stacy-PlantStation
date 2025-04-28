import 'package:flutter/material.dart';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

TextEditingController _controller = TextEditingController();

// ignore: must_be_immutable
class WebSocketScreen extends StatelessWidget {
  final IOWebSocketChannel webSocketChannel =
      IOWebSocketChannel.connect(Uri.parse('ws://192.168.50.226:3000'));

  // Method to send data to the server
  void _sendMessage(IOWebSocketChannel webSocketChannel) {
    if (_controller.text.isNotEmpty) {
      webSocketChannel.sink.add(_controller.text);
      _controller.text = '';
    }
  }

  WebSocketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Example'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: webSocketChannel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('No connection');
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.active:
                return Text('Received: ${snapshot.data}');
              case ConnectionState.done:
                return const Text('Connection closed');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendMessage(webSocketChannel),
        child: const Icon(Icons.send),
      ),
    );
  }
}
