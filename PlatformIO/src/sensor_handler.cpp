#include "sensor_handler.h"
#include "debug.h"
#include <Adafruit_Sensor.h>
#include <EnvironmentCalculations.h>
#include <Wire.h>

// Adafruit_BME280 SensorHandler::bme280;
Adafruit_HDC302x SensorHandler::hdc3022;

/**
 * @brief Initializes the HDC3022 sensor.
 * @return True if the sensor is initialized successfully, false otherwise.
 */
bool SensorHandler::initHDC() {
  // if (!SensorHandler::bme280.begin(BME280_ADDR)) {
  //   DEBUG("BME280 sensor initialization failed");
  //   return false;
  // }
  if (!SensorHandler::hdc3022.begin(HDC3022_ADDR)) {
    DEBUG("HDC3022 sensor initialization failed");
    return false;
  }
  delay(DELAY_STANDARD);
  return true;
}

/**
 * @brief Reads the HDC3022 sensor data and populates the SensorData struct.
 * @param sensorData Reference to the SensorData struct to populate.
 */
void SensorHandler::readHDC(SensorData &sensorData) {
  DEBUGLN("Reading HDC3022 sensor...");

  if (!SensorHandler::hdc3022.readTemperatureHumidityOnDemand(
          sensorData.temperature, sensorData.humidity, TRIGGERMODE_LP0)) {
    DEBUGLN("Failed to read temperature and humidity from HDC3022 sensor.");
    return;
  }
}

/**
 * @brief Reads the moisture from the sensor.
 * @return The moisture value as a float.
 */
float SensorHandler::getMoisture() {
  uint16_t sensorValue = analogRead(CAPACITANCE_PIN);

  float voltage = sensorValue * (3.3 / 4095.0);
  // TODO : calibrate this value
  float moisture = (voltage * 10.0) + 5.0;
  return moisture;
}

/**
 * @brief Reads all sensor data and populates the SensorData struct.
 * @param sensorData Reference to the SensorData struct to populate.
 */
void SensorHandler::readSensorData(SensorData &sensorData) {
  readHDC(sensorData);
  sensorData.moisture = getMoisture();
  sensorData.dewPoint = EnvironmentCalculations::DewPoint(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);
  sensorData.hic = EnvironmentCalculations::HeatIndex(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);
}
