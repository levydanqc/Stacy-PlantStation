#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <WiFi.h>
#include <Preferences.h>

void startInitialMode();
void startNormalMode();

Preferences preferences;

#include <battery_monitor.h>
#include <network_handler.h>
#include <sensor_handler.h>

// --- Function Prototypes ---
void powerOff();

void setup() {
  Serial.begin(115200);
  while (!Serial)
    ;
  DEBUGLN("ESP32 Woke Up!");

  preferences.begin("wifi-creds", false);

  String storedSSID = preferences.getString("ssid", "");
  String storedPassword = preferences.getString("password", "");

  if (storedSSID.length() > 0 && storedPassword.length() > 0) {
    DEBUGLN("Stored Wi-Fi credentials found. Starting Normal Mode.");
    startNormalMode();
  } else {
    DEBUGLN("No Wi-Fi credentials found. Starting Initial Mode (Captive Portal).");
    startInitialMode();
  }

  preferences.end();

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
