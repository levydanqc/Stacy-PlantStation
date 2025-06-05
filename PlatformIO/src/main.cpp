#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <WiFi.h>
#include <Preferences.h>

void startInitialMode();
void startNormalMode();

Preferences preferences;

void setup() {
  Serial.begin(115200);
  DEBUGLN("\nESP32 Woke Up!");

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
}

void loop() {}