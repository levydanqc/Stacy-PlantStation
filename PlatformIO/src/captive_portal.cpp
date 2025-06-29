#include "captive_portal.h"

#include "configuration.h"
#include "debug.h"
#include <ArduinoJson.h>
#include <DNSServer.h>
#include <Preferences.h>
#include <WebServer.h>
#include <WiFi.h>
#include <network_handler.h>

DNSServer dnsServer;
WebServer server(80);
Preferences initialModePreferences;

void CaptivePortal::begin() {
  DEBUGLN("Starting Initial Mode (Captive Portal)");

  // Set up Access Point
  WiFi.mode(WIFI_AP);
  WiFi.softAP(AP_SSID);
  IPAddress apIP = WiFi.softAPIP();
  DEBUGLN("AP IP address: " + apIP.toString());

  // Set up DNS server for captive portal
  dnsServer.start(DNS_PORT, "*", apIP);

  // Set up web server routes
  server.on("/", [this]() { handleRoot(); });
  server.on("/connect", HTTP_POST, [this]() { handleConnect(); });
  server.on("/scan", [this]() { handleScan(); });
  server.onNotFound([this]() { handleNotFound(); });

  server.begin();
  DEBUGLN("HTTP server started.");

  // Keep the ESP32 awake and handle client requests in the loop
  // This loop will run until the device reboots after successful config
  while (true) {
    dnsServer.processNextRequest();
    server.handleClient();
    delay(10); // Small delay to prevent watchdog timer issues
  }
}

void CaptivePortal::handleRoot() { server.send(200, "text/html", INDEX_HTML); }

void CaptivePortal::handleConnect() {
  JsonDocument doc;
  String body = server.arg("plain");

  // Parse the JSON from the request body
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    // If parsing fails, send an error response
    DEBUG("deserializeJson() failed: ");
    DEBUGLN(error.c_str());
    server.send(400, "application/json",
                "{\"success\":false,\"message\":\"Invalid JSON\"}");
    return;
  }

  DEBUGLN("Credentials received. Attempting to connect to WiFi...");
  DEBUGLN("Request body: " + doc.as<String>());

  const char *email = doc["email"];
  const char *user_password = doc["password"];
  const char *ssid = doc["ssid"];
  const char *wifi_password = doc["wifi_password"];
  const char *plant_name = doc["plant_name"];

  DEBUGLN("SSID: " + String(ssid));
  DEBUGLN("wifi_password: " + String(wifi_password));
  DEBUGLN("email: " + String(email));
  DEBUGLN("user_password: " + String(user_password));
  DEBUGLN("plant_name: " + String(plant_name));

  if (!plant_name || !ssid || !wifi_password || !email || !user_password) {
    server.send(400, "text/plain", "Invalid request. Missing required fields.");
    return;
  }
  delay(DELAY_SHORT);

  initialModePreferences.begin("stacy", false);
  initialModePreferences.putString("ssid", ssid);
  initialModePreferences.putString("wifi_password", wifi_password);
  initialModePreferences.putString("email", email);
  initialModePreferences.putString("user_password", user_password);
  initialModePreferences.putString("plant_name", plant_name);
  initialModePreferences.end();

  NetworkHandler::connectToWiFi();
  delay(DELAY_STANDARD);

  bool loggedIn = NetworkHandler::loginUser(email, user_password);
  if (!loggedIn) {
    NetworkHandler::createPlant(String(plant_name));
  }

  server.send(200, "text/plain",
              "Attempting to connect to WiFi. The device will restart soon.");

  delay(DELAY_SHORT);

  ESP.restart();
}

void CaptivePortal::handleScan() {
  DEBUGLN("Scanning for WiFi networks...");
  int n = WiFi.scanNetworks();
  String json = "[";
  for (int i = 0; i < n; ++i) {
    if (i > 0)
      json += ",";
    json += "\"" + WiFi.SSID(i) + "\"";
  }
  json += "]";
  server.send(200, "application/json", json);
  DEBUGLN("Scan complete. Sent " + String(n) + " networks.");
}

void CaptivePortal::handleNotFound() {
  server.sendHeader("Location", "http://" + WiFi.softAPIP().toString() + "/");
  server.send(302, "text/plain", "");
}
