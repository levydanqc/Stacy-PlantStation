#define DEBUG_MODE 1

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
  String storedEmail = preferences.getString("email");
  String storedPwd = preferences.getString("user_password");
  String storedPlantName = preferences.getString("plant_name");
  String storedPlantId = preferences.getString("plant_id");

  DEBUGLN("Stored Wi-Fi SSID: " + storedSSID);
  DEBUGLN("Stored Wi-Fi Password: " + storedWifiPWD);
  DEBUGLN("Stored UID: " + storedUID);
  DEBUGLN("Stored Bearer Token: " + storedBearerToken);
  DEBUGLN("Stored Email: " + storedEmail);
  DEBUGLN("Stored Password: " + storedPwd);
  DEBUGLN("Stored Plant Name: " + storedPlantName);
  DEBUGLN("Stored Plant ID: " + storedPlantId);

  // if no UID is stored but email and password are present
  if (storedUID.length() < 1 && storedEmail.length() > 1 &&
      storedPwd.length() > 1) {
    DEBUGLN("No UID found but email and password are present. Attempting to "
            "login and create UID.");
    storedUID = NetworkHandler::loginUser(storedEmail, storedPwd);
    if (!storedUID.isEmpty()) {
      DEBUGLN("UID created successfully: " + storedUID);
      preferences.putString("uid", storedUID);
    } else {
      DEBUGLN("Failed to create UID. Please check your credentials.");
    }
  }

  // if uid is stored but no plant_id, create one
  if (storedUID.length() > 1 && storedPlantId.length() < 1 &&
      storedPlantName.length() > 1) {
    DEBUGLN("No Plant ID found but UID and Plant Name are present. Attempting "
            "to create Plant ID.");
    NetworkHandler::createPlant(storedPlantName);
  }

  // if email and password are present but no bearer token or no uid, get them
  if (storedEmail.length() > 1 && storedPwd.length() > 1 &&
      (storedBearerToken.length() < 1 || storedUID.length() < 1)) {
    DEBUGLN("No Bearer Token found but UID is present. Attempting to create "
            "Bearer Token.");
    NetworkHandler::loginUser(storedEmail, storedPwd);
  }

  preferences.end();

  if (storedSSID.length() > 1 && storedWifiPWD.length() > 1 &&
      storedUID.length() > 1) {
    DEBUGLN("Stored Wi-Fi credentials found. Starting Normal Mode.");
    startNormalMode();
  } else {
    DEBUGLN(
        "No Wi-Fi credentials found. Starting Initial Mode (Captive Portal).");
    // Start Captive Portal for Wi-Fi configuration
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
  // if (!SensorHandler::initHDC()) {
  //   DEBUGLN("Failed to initialize HDC3022 sensor. Exiting Normal Mode.");
  //   data.temperature = 0.0;
  //   data.humidity = 0.0;
  //   data.moisture = 0.0;
  //   data.hic = 0.0;
  //   return;
  // } else {
  //   SensorHandler::readSensorData(data);
  // }
  BatteryMonitor::getBatteryStatus(data);

  data.temperature = 25.0;
  data.humidity = 50.0;
  data.moisture = 20.0;
  data.hic = 25.1;
  data.batteryVoltage = 3.9;
  data.batteryPercentage = 95.0;

  NetworkHandler::sendDataToServer(data);

  // Signal the TPL5110 to turn off power
  // powerOff();
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
