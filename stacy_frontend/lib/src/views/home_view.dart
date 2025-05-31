import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/models/plant_data.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/services/websocket.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/widgets/home/home_no_plants_view.dart';
import 'package:stacy_frontend/src/widgets/home/home_show_plants.dart';

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  static const String routeName = '/home';
  int currentPage = 0;

  HomeView({super.key, this.currentPage = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Plant>> _plantsFuture;
  late PageController _pageController;

  final WebSocketService _webSocketService = WebSocketService();
  final List<Plant> _weatherData = [];

  @override
  void initState() {
    super.initState();

    _plantsFuture = ApiManager.getUserPlants();
    _pageController = PageController(initialPage: widget.currentPage);

    _pageController.addListener(() {
      setState(() {
        widget.currentPage = _pageController.page!.round();
      });
    });

    _webSocketService.initSetState(setState);
    _webSocketService.connect();
    _subscribeToWebSocketService();
  }

  void _subscribeToWebSocketService() {
    _webSocketService.dataStream.listen((data) {
      if (mounted) {
        // Only update state if the widget is still in the tree
        // Update weather data.
        if (data.containsKey('type')) {
          if (data['type'] == 'initial_data') {
            setState(() {
              _weatherData.clear();
              _weatherData.addAll((data['plants'] as List)
                  .map((plant) => Plant.fromJson(plant))
                  .toList());
            });
          } else if (data['type'] == 'update') {
            setState(() {
              final plantName = data['plants']['plant_name'];
              final existingPlantIndex = _weatherData
                  .indexWhere((plant) => plant.plantName == plantName);
              if (existingPlantIndex != -1) {
                _weatherData[existingPlantIndex].plantData.add(
                      PlantData.fromJson(data['plants']['plant_data']),
                    );
              } else {
                log.severe("Received update for unknown plant: $plantName");
              }
            });
          } else {
            log.warning("Received unknown data type: ${data['type']}");
            return;
          }
        } else {
          log.warning("Received unexpected data format: $data");
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> hasPlantInDatabase() async {
    final plants = await _plantsFuture;
    return plants.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    log.fine('Building HomeView');
    return SafeArea(
      child: Builder(
        builder: _buildView,
      ),
    );
  }

  Widget _buildView(context) {
    log.finest('Run HomeView _buildView');

    if (_webSocketService.isConnected && _weatherData.isNotEmpty) {
      return buildPlantsDisplayView(
          context, _weatherData, _pageController, widget.currentPage);
    } else if (_webSocketService.isConnected && _weatherData.isEmpty) {
      return buildNoPlantsView(context);
    } else if (!_webSocketService.isConnected) {
      return Column(
        children: [
          Text('Attempting to connect to the server...'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Retry connection logic
              _webSocketService.connect();
              setState(() {
              });
            },
            child: Text('Retry Connection'),
          ),
        ],
      );
    } else {
      // Show loading indicator while connected but waiting for first data
      return Column(children: [
        Text('Connected. Waiting for data...'),
        SizedBox(height: 20),
        CircularProgressIndicator(),
      ]);
    }
  }
}
