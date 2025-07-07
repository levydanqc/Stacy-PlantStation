#include "web_provisioner.h"
#include "debug.h"
#include "network_handler.h"

#include <Preferences.h>
#include <WebServer.h>

WebProvisioner::WebProvisioner(const char *apSSID)
    : _apSSID(apSSID), _server(80) {}

void WebProvisioner::begin() {
  DEBUGLN("Starting WiFi Provisioner...");
  startAccessPoint();
  setupRoutes();
  _server.begin();
  DEBUGLN("HTTP server started");

  while (true) {
    _server.handleClient();
    delay(10);
  }
}

void WebProvisioner::startAccessPoint() {
  WiFi.softAP(_apSSID);
  DEBUG("Access Point started: ");
  DEBUGLN(_apSSID);
  // Set the access point IP address
  IPAddress apIP(192, 168, 4, 1);
  if (!WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0))) {
    DEBUGLN("Failed to configure AP");
  }
  DEBUG("AP IP address: ");
  DEBUGLN(WiFi.softAPIP());
}

void WebProvisioner::setupRoutes() {
  _server.on("/", [this]() { handleRoot(); });
  _server.on("/initiate", HTTP_POST, [this]() { handleSetWiFi(); });
}

void WebProvisioner::handleRoot() {
  _server.send(200, "text/plain", "ESP32 ready to receive Wi-Fi credentials.");
}

void WebProvisioner::handleSetWiFi() {
  if (_server.hasArg("ssid") && _server.hasArg("password")) {
    String ssid = _server.arg("ssid");
    String password = _server.arg("password");
    String uid = _server.arg("uid");
    String bearerToken = _server.arg("bearer_token");

    _preferences.begin("stacy", false);
    _preferences.putString("ssid", ssid);
    _preferences.putString("wifi_password", password);
    _preferences.putString("uid", uid);
    _preferences.putString("bearer_token", bearerToken);
    _preferences.end();

    _server.send(200, "text/plain",
                 "Wi-Fi credentials received. Attempting to connect...");

    NetworkHandler::connectToWiFi();
    delay(DELAY_STANDARD);

    String plant_name = "Device";
    NetworkHandler::createPlant(plant_name);

    DEBUGLN("Connecting to new Wi-Fi...");
  } else {
    _server.send(400, "text/plain", "Missing ssid or password");
  }
}