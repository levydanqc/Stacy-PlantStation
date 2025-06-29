#ifndef NETWORK_HANDLER_H
#define NETWORK_HANDLER_H

#include "configuration.h"
#include <Arduino.h>
#include <Preferences.h>

class NetworkHandler {
private:
  Preferences initialModePreferences;
  static String getMacAddress();

public:
  static void connectToWiFi();
  static void sendDataToServer(SensorData sensorData);
  static void createPlant(String plantName);
  static bool loginUser(const String &email, const String &password);
};

#endif