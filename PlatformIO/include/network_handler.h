#ifndef NETWORK_HANDLER_H
#define NETWORK_HANDLER_H

#include "configuration.h"
#include <Arduino.h>

class NetworkHandler {
private:
  static String getMacAddress();

public:
  static void connectToWiFi();
  static void sendDataToServer(SensorData sensorData);
};

#endif