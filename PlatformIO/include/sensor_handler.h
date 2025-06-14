#ifndef SENSOR_HANDLER_H
#define SENSOR_HANDLER_H

#include "configuration.h"
#include <Adafruit_BME280.h>

class SensorHandler {
private:
  static Adafruit_BME280 bme280; // BME280 sensor instance
  static void readBME(SensorData &sensorData);
  static float getMoisture();

public:
  static bool initBME();
  static void readSensorData(SensorData &sensorData);
};

#endif