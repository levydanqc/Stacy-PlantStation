class PlantData {
  // final int healthPercentage;
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double moisture;
  final double pressure;
  final double hic;
  final double batteryVoltage;
  final double batteryPercentage;

  PlantData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.pressure,
    required this.hic,
    required this.batteryVoltage,
    required this.batteryPercentage,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw ArgumentError('JSON data for the PlantData cannot be empty');
    }
    for (var key in [
      'temperature',
      'humidity',
      'moisture',
      'pressure',
      'hic',
      'batteryVoltage',
      'batteryPercentage',
      'timestamp'
    ]) {
      if (!json.containsKey(key)) {
        throw ArgumentError('JSON data for PlantData is missing "$key" key');
      }
    }

    if (json['temperature'] == null || json['temperature'] is! num) {
      throw ArgumentError('Invalid or missing "temperature" in JSON data');
    }
    if (json['humidity'] == null || json['humidity'] is! num) {
      throw ArgumentError('Invalid or missing "humidity" in JSON data');
    }
    if (json['moisture'] == null || json['moisture'] is! num) {
      throw ArgumentError('Invalid or missing "moisture" in JSON data');
    }
    if (json['pressure'] == null || json['pressure'] is! num) {
      throw ArgumentError('Invalid or missing "pressure" in JSON data');
    }
    if (json['hic'] == null || json['hic'] is! num) {
      throw ArgumentError('Invalid or missing "hic" in JSON data');
    }
    if (json['batteryVoltage'] == null || json['batteryVoltage'] is! num) {
      throw ArgumentError('Invalid or missing "batteryVoltage" in JSON data');
    }
    if (json['batteryPercentage'] == null ||
        json['batteryPercentage'] is! num) {
      throw ArgumentError(
          'Invalid or missing "batteryPercentage" in JSON data');
    }
    if (json['timestamp'] == null || json['timestamp'] is! String) {
      throw ArgumentError('Invalid or missing "timestamp" in JSON data');
    }

    return PlantData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      moisture: (json['moisture'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      hic: (json['hic'] as num).toDouble(),
      batteryVoltage: (json['batteryVoltage'] as num).toDouble(),
      batteryPercentage: (json['batteryPercentage'] as num).toDouble(),
    );
  }
}
