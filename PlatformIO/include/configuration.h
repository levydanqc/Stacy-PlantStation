#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include <BME280I2C.h>
#include <EnvironmentCalculations.h>

// Battery
#define BATTERY_PIN A1
#define BATTERY_MAX 4.2
#define BATTERY_MIN 3.0

// BME280
#define SEALEVELPRESSURE_HPA (1013.25)
#define BME280_ADDR BME280I2C::I2CAddr_0x76

// I2C
#define I2C_SDA_PIN 8
#define I2C_SCL_PIN 9
#define PIN_I2C_POWER 7 // needed for I2C power management

// Constants
#define DELAY_LONG 3000
#define DELAY_STANDARD 250
#define DELAY_SHORT 25
#define uS_TO_S_FACTOR 1000000ULL
#define TIME_TO_SLEEP 5

// BME280 sensor Units
BME280::TempUnit TEMP_UNIT = BME280::TempUnit_Celsius;
BME280::PresUnit PRES_UNIT = BME280::PresUnit_Pa;
EnvironmentCalculations::TempUnit ENV_TEMP_UNIT =
    EnvironmentCalculations::TempUnit_Celsius;

typedef struct SensorData {
  float temperature = 0.0;
  float humidity = 0.0;
  float pressure = 0.0;
  float hic = 0.0;
  float dewPoint = 0.0;
  float batteryPercentage = 0.0;
} SensorData;
SensorData sensorData;

#endif
