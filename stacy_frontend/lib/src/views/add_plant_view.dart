import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddPlantView extends StatefulWidget {
  const AddPlantView({super.key});

  static const String routeName = '/add_plant';

  @override
  State<AddPlantView> createState() => _AddPlantViewState();
}

class _AddPlantViewState extends State<AddPlantView> {
  List<WiFiAccessPoint> wifiList = [];
  String selectedSSID = '';
  String wifiPassword = '';
  String connectionStatus = '';
  bool isScanning = false;
  bool isConnectedToDevice = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    setState(() {
      connectionStatus = 'Checking Wi-Fi...';
    });

    try {
      // Check if the device is connected to the specified SSID "Stacy-WeatherStation"
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          connectionStatus = 'Not connected to Wi-Fi.';
          isConnectedToDevice = false;
        });
        return;
      }
      final wifiName = await NetworkInfo().getWifiName();
      if (wifiName != dotenv.env['DEVICE_SSID']) {
        setState(() {
          connectionStatus = 'Not connected to the correct Wi-Fi.';
          isConnectedToDevice = false;
        });
        return;
      }

      setState(() {
        isConnectedToDevice = true;
        connectionStatus = 'Connected to Wi-Fi.';
      });

      if (!kIsWeb) {
        await scanNetworks(); // only scan on mobile
      }
    } catch (e) {
      setState(() {
        connectionStatus = 'Not connected to Wi-Fi.';
        isConnectedToDevice = false;
      });
      log.severe('Error checking connection: $e');
      return;
    }
  }

  Future<void> scanNetworks() async {
    if (kIsWeb) return;

    final status = await Permission.location.request();
    if (!status.isGranted) {
      log.warning('Location permission not granted, requesting...');
      PermissionStatus permissionStatus =
          await Permission.locationWhenInUse.request();
      if (permissionStatus.isGranted) {
        wifiList = await WiFiScan.instance.getScannedResults();
        // Handle scan results
      } else {
        // Handle the case where location permission is denied
      }

      setState(() => connectionStatus = 'Location permission denied.');
      return;
    }

    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      setState(() => connectionStatus = 'Cannot scan Wi-Fi.');
      return;
    }

    setState(() {
      isScanning = true;
      connectionStatus = 'Scanning for Wi-Fi...';
    });

    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(seconds: 2));
    final results = await WiFiScan.instance.getScannedResults();

    setState(() {
      wifiList = results.toSet().toList();
      isScanning = false;
      connectionStatus = 'Scan complete.';
    });
  }

  Future<void> sendProvisioningRequest() async {
    ApiManager.sendProvisioningRequest(
      selectedSSID,
      wifiPassword,
    ).then((_) {
      setState(() => connectionStatus = 'Provisioning request sent.');
    }).catchError((error) {
      setState(() => connectionStatus = 'Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canScan = !kIsWeb && isConnectedToDevice && wifiList.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Plant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(connectionStatus),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkConnection,
              child: const Text('Check Connection Again'),
            ),
            if (kIsWeb && isConnectedToDevice) ...[
              const SizedBox(height: 16),
              const Text('Enter Your Wi-Fi Network:'),
              TextField(
                decoration: const InputDecoration(labelText: 'Wi-Fi SSID'),
                onChanged: (value) => selectedSSID = value,
              ),
            ],
            if (canScan) ...[
              const SizedBox(height: 16),
              const Text('Select Your Home Wi-Fi:'),
              DropdownButton<String>(
                value: selectedSSID.isNotEmpty ? selectedSSID : null,
                hint: const Text('Choose Wi-Fi'),
                items: wifiList
                    .map((ap) => DropdownMenuItem(
                          value: ap.ssid,
                          child: Text(ap.ssid),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSSID = value ?? '');
                },
              ),
            ],
            if (isConnectedToDevice) ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Wi-Fi Password'),
                obscureText: true,
                onChanged: (value) => wifiPassword = value,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  log.fine(
                      'Selected SSID: $selectedSSID, Password: $wifiPassword');
                  if (selectedSSID.isNotEmpty && wifiPassword.isNotEmpty) {
                    sendProvisioningRequest();
                  } else {
                    setState(
                        () => connectionStatus = 'Please fill all fields.');
                  }
                },
                child: const Text('Add Plant'),
              ),
            ],
            if (isScanning) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const Text('Scanning...'),
            ],
          ],
        ),
      ),
    );
  }
}
