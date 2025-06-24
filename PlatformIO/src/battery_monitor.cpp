#include "battery_monitor.h"
#include "configuration.h"
#include "debug.h"
#include <Arduino.h>

/**
 * @brief Reads the battery voltage from the ADC pin.
 * @return The battery voltage.
 */
float BatteryMonitor::readBatteryVoltage() {
  //   uint32_t Vbatt = 0;
  // for(int i = 0; i < 16; i++) {
  //   Vbatt = Vbatt + analogReadMilliVolts(A0); // ADC with correction
  // }
  // float Vbattf = 2 * Vbatt / 16 / 1000.0;     // attenuation ratio 1/2,
  // mV --> V

  analogSetPinAttenuation(BATTERY_PIN,
                          ADC_11db);      // Configure ADC for 0-2.5V range
  uint16_t raw = analogRead(BATTERY_PIN); // Read raw ADC value
  float vOut = (raw / 4095.0) * 2.5;      // Convert ADC value to voltage
  float vBattery = vOut / 0.5;            // Scale to battery voltage
  return vBattery;
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