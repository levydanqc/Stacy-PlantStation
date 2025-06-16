// #define DEBUG_MODE 1

#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <Preferences.h>
#include <WiFi.h>

Preferences preferences;

// TODO : NEED TO REMOVE PRESSURE FROM BACKEND

#include <battery_monitor.h>
#include <captive_portal.h>
#include <network_handler.h>
#include <sensor_handler.h>

// --- Function Prototypes ---
void powerOff();
void startNormalMode();

void setup() {
  SERIAL_BEGIN(115200);

#ifdef DEBUG_MODE
  while (!Serial)
    ;
#endif

  Serial.setDebugOutput(true);
  delay(DELAY_SHORT);

  DEBUGLN("ESP32 Woke Up!");

  pinMode(TPL5110_DONE_PIN, OUTPUT);

  preferences.begin("wifi-creds", false);
  String storedSSID = preferences.getString("ssid");
  String storedPassword = preferences.getString("wifi_password");
  String storedUID = preferences.getString("uid");
  String storedEmail = preferences.getString("email");
  String storedPwd = preferences.getString("user_password");
  String storedPlantName = preferences.getString("plant_name");

  // if no UID is stored but email and password are present,
  if (storedUID.length() < 1 && storedEmail.length() > 1 &&
      storedPwd.length() > 1) {
    DEBUGLN("No UID found but email and password are present. Attempting to "
            "login and create UID.");
    storedUID = NetworkHandler::loginUser(storedEmail, storedPwd);
    if (!storedUID.isEmpty()) {
      DEBUGLN("UID created successfully: " + storedUID);
      preferences.putString("uid", storedUID);
      NetworkHandler::createPlant(String(storedPlantName));
    } else {
      DEBUGLN("Failed to create UID. Please check your credentials.");
    }
  }

  preferences.end();

  if (storedSSID.length() > 1 && storedPassword.length() > 1 &&
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
