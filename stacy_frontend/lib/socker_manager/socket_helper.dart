import 'package:fbroadcast/fbroadcast.dart';

class SocketHelper {
  static handleSocketResponse(String response) {
    var responseArray = response.split(':');
    if (responseArray.first == 'message') {
      sendLocal(responseArray.last);
    } else if (response.contains('Request served by')) {
      sendLocal('connected');
    } else if (response.isEmpty) {
      sendLocal('disconnected');
    }
  }

  static void sendLocal(String message) {
    FBroadcast.instance().broadcast("message_received", value: message);
  }
}