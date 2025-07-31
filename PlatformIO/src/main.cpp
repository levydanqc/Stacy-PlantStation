#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <Preferences.h>
#include <WiFi.h>

Preferences preferences;

#include <battery_monitor.h>
#include <captive_portal.h>
#include <network_handler.h>
#include <sensor_handler.h>

// --- Function Prototypes ---
void powerOff();
void startNormalMode();

void setup() {
  SERIAL_BEGIN(115200);
  SERIAL_WAIT_FOR_SERIAL;
  SERIAL_SET_DEBUG_OUTPUT(true);

  delay(DELAY_SHORT);

  DEBUGLN("ESP32 Woke Up!");

  pinMode(TPL5110_DONE_PIN, OUTPUT);

  preferences.begin("stacy", false);
  String storedSSID = preferences.getString("ssid");
  String storedWifiPWD = preferences.getString("wifi_password");
  String storedUID = preferences.getString("uid");
  String storedBearerToken = preferences.getString("bearer_token");
  String storedPlantName = preferences.getString("plant_name");
  String storedPlantId = preferences.getString("plant_id");
  preferences.end();

  DEBUGLN("Stored Wi-Fi SSID: " + storedSSID);
  DEBUGLN("Stored Wi-Fi Password: " + storedWifiPWD);
  DEBUGLN("Stored UID: " + storedUID);
  DEBUGLN("Stored Bearer Token: " + storedBearerToken);
  DEBUGLN("Stored Plant Name: " + storedPlantName);
  DEBUGLN("Stored Plant ID: " + storedPlantId);

  // if uid is stored but no plant_id, create one
  if (storedUID.length() > 1 && storedPlantId.length() < 1) {
    DEBUGLN("No Plant ID found but UID and Plant Name are present. Attempting "
            "to create Plant ID.");
    NetworkHandler::createPlant(storedPlantName);
  }

  if (storedSSID.length() > 1 && storedWifiPWD.length() > 1 &&
      storedUID.length() > 1 && storedBearerToken.length() > 1) {
    DEBUGLN("Stored Wi-Fi credentials found. Starting Normal Mode.");
    startNormalMode();
  } else if (storedSSID.length() > 1 && storedWifiPWD.length() > 1 &&
             storedUID.length() < 1) {
    DEBUGLN("No UID found but Wi-Fi credentials are present. Starting "
            "mDNS.");
    CaptivePortal captivePortal;
    captivePortal.startMDNS();
  } else {
    DEBUGLN("No stored Wi-Fi credentials found. Starting Captive Portal.");
    CaptivePortal captivePortal;
    captivePortal.begin();
  }
}

// --- Loop Function (empty, as logic is in setup after wake) ---
void loop() {}

// --- Helper Functions ---

void startNormalMode() {
  DEBUGLN("Normal Mode Sequence Started");
  NetworkHandler::connectToWiFi();

  SensorData data;
  if (!SensorHandler::initHDC()) {
    DEBUGLN("Failed to initialize HDC3022 sensor.");
    data.temperature = 0.0;
    data.humidity = 0.0;
    data.moisture = 0.0;
    data.hic = 0.0;
    // return;
  } else {
    SensorHandler::readSensorData(data);
  }
  BatteryMonitor::getBatteryStatus(data);
  // data.batteryPercentage = 1.0;
  // data.batteryVoltage = 1.0;

  NetworkHandler::sendDataToServer(data);

  // Signal the TPL5110 to turn off power
  powerOff();
}

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
