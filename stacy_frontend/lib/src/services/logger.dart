// ignore_for_file: avoid_print

import 'package:logging/logging.dart';

final log = Logger('StacyLogger');
final logLevel = Level.ALL;

void setupLogger() {
  Logger.root.level = logLevel;
  Logger.root.onRecord.listen((LogRecord rec) {
    final String message = '${rec.level.name}: ${rec.message}';
    if (rec.level >= Level.SEVERE) {
      print('\x1B[31m$message\x1B[0m'); // Red for SEVERE
    } else if (rec.level >= Level.SHOUT) {
      print('\x1B[35m$message\x1B[0m'); // Magenta for SHOUT
    } else if (rec.level >= Level.WARNING) {
      print('\x1B[33m$message\x1B[0m'); // Yellow for WARNING
    } else if (rec.level >= Level.INFO) {
      print('\x1B[34m$message\x1B[0m'); // Blue for INFO
    } else if (rec.level >= Level.FINE) {
      print('\x1B[36m$message\x1B[0m'); // Cyan for FINE
    } else {
      print(message);
    }
  });
}
