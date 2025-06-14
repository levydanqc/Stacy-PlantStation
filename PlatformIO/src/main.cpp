#include "configuration.h"
#include "credentials.h"
#include "debug.h"

#include <battery_monitor.h>
#include <network_handler.h>
#include <sensor_handler.h>

// --- Function Prototypes ---
void powerOff();

// --- Setup Function (runs once on boot/wake) ---
void setup() {
  Serial.begin(115200);
  while (!Serial)
    ;
  DEBUGLN("ESP32 Woke Up!");

  pinMode(TPL5110_DONE_PIN, OUTPUT);

  // Attempt to connect to Wi-Fi
  NetworkHandler::connectToWiFi();


  SensorData data;
  SensorHandler::initBME();
  SensorHandler::readSensorData(data);

  BatteryMonitor::getBatteryStatus(data);

  NetworkHandler::sendDataToServer(data);

  // Signal the TPL5110 to turn off power
  // powerOff();
}

// --- Loop Function (empty, as logic is in setup after wake) ---
void loop() {}

// --- Helper Functions ---

/**
 * @brief Turn off power by controlling the TPL5110 DONE pin.
 * This function sets the TPL5110 DONE pin to LOW and then HIGH to signal
 * the TPL5110 to turn off power.
 */
void powerOff() {
  digitalWrite(TPL5110_DONE_PIN, LOW);
  digitalWrite(TPL5110_DONE_PIN, HIGH);
  delay(100);
}