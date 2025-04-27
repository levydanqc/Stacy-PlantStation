#ifndef CONFIGURATION_H
#define CONFIGURATION_H

// Constants
#define PIN_I2C_POWER 7 // needed for I2C power management
#define PA_PER_METER                                                           \
  0.113 // approx. pressure change in hPa per meter of altitude (up to 1000m)
#define ALTITUDE                                                               \
  120.0 // CHANGEME meteo station altitude above sea level (in meters)
// Delays (in miliseconds) needed in program
#define DELAY_LONG 3000
#define DELAY_STANDARD 250
#define DELAY_SHORT 25

// Variables
typedef struct SensorData {
  float temperature = 0.0;
  float humidity = 0.0;
  float pressure = 0.0;
  float hic = 0.0;
  float batteryVoltage = 0.0;
  float batteryPercentage = 0.0;
} SensorData;
SensorData sensorData;
#endif
