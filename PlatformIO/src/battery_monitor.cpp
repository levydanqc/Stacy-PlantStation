#include "battery_monitor.h"
#include "configuration.h"
#include "debug.h"
#include <Arduino.h>

/**
 * @brief Reads the battery voltage from the ADC pin.
 * @return The battery voltage.
 */
float BatteryMonitor::readBatteryVoltage() {
  uint32_t Vbatt = 0;
  for (int i = 0; i < 16; i++) {
    Vbatt = Vbatt + analogReadMilliVolts(BATTERY_PIN);
  }
  // attenuation ratio 1/2, mV --> V
  float Vbattf = 2 * Vbatt / 16 / 1000.0;

  return Vbattf;
}

/**
 * @brief Calculates the battery percentage based on the voltage.
 * @param voltage The voltage value.
 * @return The calculated battery percentage.
 */
float BatteryMonitor::calculateBatteryPercentage(float voltage) {
  float percentage =
      ((voltage - BATTERY_MIN) / (BATTERY_MAX - BATTERY_MIN)) * 100.0;
  if (percentage > 100)
    percentage = 100;
  if (percentage < 0)
    percentage = 0;
  return (float)percentage;
}

/**
 * @brief Gets the battery status including voltage and percentage.
 * @param voltage Reference to store the battery voltage.
 * @param percentage Reference to store the battery percentage.
 */
void BatteryMonitor::getBatteryStatus(SensorData &sensorData) {
  sensorData.batteryVoltage = readBatteryVoltage();
  sensorData.batteryPercentage =
      calculateBatteryPercentage(sensorData.batteryVoltage);
}