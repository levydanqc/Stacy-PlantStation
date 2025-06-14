#include "sensor_handler.h"
#include "debug.h"
#include <Adafruit_BME280.h>
#include <Adafruit_Sensor.h>
#include <EnvironmentCalculations.h>
#include <Wire.h>

Adafruit_BME280 SensorHandler::bme280;

/**
 * @brief Initializes the BME280 sensor.
 * @return True if the sensor is initialized successfully, false otherwise.
 */
bool SensorHandler::initBME() {
  if (!SensorHandler::bme280.begin(BME280_ADDR)) {
    DEBUG("BME280 sensor initialization failed");
    return false;
  }
  delay(DELAY_STANDARD);
  return true;
}

/**
 * @brief Reads the BME280 sensor data and populates the SensorData struct.
 * @param sensorData Reference to the SensorData struct to populate.
 */
void SensorHandler::readBME(SensorData &sensorData) {
  DEBUGLN("Reading BME280 sensor...");

  sensorData.temperature = SensorHandler::bme280.readTemperature();
  sensorData.humidity = SensorHandler::bme280.readHumidity();
  sensorData.pressure = SensorHandler::bme280.readPressure() / 100.0;
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
  readBME(sensorData);
  sensorData.moisture = getMoisture();
  sensorData.dewPoint = EnvironmentCalculations::DewPoint(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);
  sensorData.hic = EnvironmentCalculations::HeatIndex(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);
}
