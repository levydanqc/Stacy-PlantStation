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
      plantName: json['plantName'] as String,
      plantData: (json['plantData'] as List)
          .map((item) => PlantData.fromJson(item))
          .toList(),
    );
  }
}
