#ifndef SENSOR_HANDLER_H
#define SENSOR_HANDLER_H

#include "configuration.h"
#include <Adafruit_HDC302x.h>

class SensorHandler {
private:
  static Adafruit_HDC302x hdc3022;
  static void readHDC(SensorData &sensorData);
  static float getMoisture();

public:
  static bool initHDC();
  static void readSensorData(SensorData &sensorData);
};

#endif