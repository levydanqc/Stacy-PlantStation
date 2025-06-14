#ifndef BATTERY_MONITOR_H
#define BATTERY_MONITOR_H

#include "configuration.h"
#include <Arduino.h>

class BatteryMonitor {
private:
  static float readBatteryVoltage();
  static float calculateBatteryPercentage(float voltage);

public:
  static void getBatteryStatus(SensorData &sensorData);
};

#endif