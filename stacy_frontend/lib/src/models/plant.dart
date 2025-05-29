import 'package:stacy_frontend/src/models/plant_data.dart';

class Plant {
  final String plantName;
  final List<PlantData> plantData;

  Plant({
    required this.plantName,
    required this.plantData,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantName: json['plant_name'] as String,
      plantData: (json['plant_data'] as List)
          .map((item) => PlantData.fromJson(item))
          .toList(),
    );
  }
}
