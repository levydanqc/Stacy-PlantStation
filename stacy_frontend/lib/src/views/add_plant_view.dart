import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:wifi_iot/wifi_iot.dart';

class AddPlantView extends StatefulWidget {
  const AddPlantView({super.key});
  static const String routeName = '/add-plant';

  @override
  State<AddPlantView> createState() => _AddPlantViewState();
}

class _AddPlantViewState extends State<AddPlantView> {
  final String deviceSSID = "Stacy PlantStation";
  final String deviceIP = "192.168.4.1";
  bool isConnecting = false;
  bool isPolling = false;
  String connectionStatus = "";
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    startPollingProvisionRequest();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> connectToPlantStation() async {
    setState(() {
      isConnecting = true;
      connectionStatus = "Requesting Wi-Fi permissions...";
    });

    await Permission.location.request();

    final success = await WiFiForIoTPlugin.connect(
      deviceSSID,
      security: NetworkSecurity.NONE,
      joinOnce: true,
      withInternet: false,
    );

    if (success) {
      setState(() {
        connectionStatus =
            "Connected to $deviceSSID. Waiting for provisioning...";
        isPolling = true;
      });
      startPollingProvisionRequest();
    } else {
      setState(() {
        connectionStatus = "Failed to connect to $deviceSSID.";
        isConnecting = false;
      });
    }
  }

  void startPollingProvisionRequest() {
    pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      log.info("Polling for provisioning request...");
      final code = await ApiManager.sendProvisioningRequest();

      setState(() {
        connectionStatus = "Polling... (HTTP $code)";
      });

      if (code == 200) {
        setState(() {
          connectionStatus = "Provisioning successful! ✅";
          isPolling = false;
          isConnecting = false;
        });
        pollingTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add a New Plant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isConnecting ? null : connectToPlantStation,
              child: const Text("Connect to PlantStation"),
            ),
            const SizedBox(height: 16),
            Text(connectionStatus),
            if (isPolling) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
