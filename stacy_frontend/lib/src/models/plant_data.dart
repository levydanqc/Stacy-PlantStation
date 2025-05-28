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
