#ifndef NETWORK_HANDLER_H
#define NETWORK_HANDLER_H

#include "configuration.h"
#include <Arduino.h>

class NetworkHandler {
public:
  static void connectToWiFi();
  static void sendDataToServer(SensorData sensorData);
  static String getMacAddress(); // Moved from main.cpp
};

#endif