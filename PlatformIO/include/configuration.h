#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include <EnvironmentCalculations.h>

// Battery
#define BATTERY_PIN A1
#define BATTERY_MAX 3.8
#define BATTERY_MIN 3.0

// HDC3022
#define HDC3022_ADDR 0x44

// Capacitance
#define CAPACITANCE_PIN A2
#define AIR_VALUE 3725
#define WATER_VALUE 2125

// I2C
#define I2C_SDA_PIN 8
#define I2C_SCL_PIN 9

// TPL5110
#define TPL5110_DONE_PIN 10

// EEPROM addresses for calibration values
#define EEPROM_OFFSET_ADDR 0
#define EEPROM_SCALE_ADDR 4

// Constants
#define DELAY_LONG 750
#define DELAY_STANDARD 250
#define DELAY_SHORT 25
#define uS_TO_S_FACTOR 1000000ULL
#define TIME_TO_SLEEP 3600
#define AP_SSID "PlantStation"
#define DNS_PORT 53

// EnvironmentCalculations settings
#define ENV_TEMP_UNIT EnvironmentCalculations::TempUnit_Celsius

typedef struct SensorData {
  double temperature = 0.0;
  double humidity = 0.0;
  float moisture = 0.0;
  float hic = 0.0;
  float dewPoint = 0.0;
  float batteryVoltage = 0.0;
  float batteryPercentage = 0.0;
} SensorData;

#endif
