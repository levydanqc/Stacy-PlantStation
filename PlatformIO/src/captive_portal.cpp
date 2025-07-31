#include "captive_portal.h"

#include "configuration.h"
#include "debug.h"

#include <ArduinoJson.h>
#include <DNSServer.h>
#include <ESPmDNS.h>
#include <Preferences.h>
#include <WebServer.h>
#include <WiFi.h>
#include <network_handler.h>

DNSServer dnsServer;
WebServer server(80);
Preferences initialModePreferences;

void CaptivePortal::begin() {
  DEBUGLN("Starting Initial Mode (Captive Portal)");

  // random 4 digit suffix for the SSID
  String randomSuffix = String(random(1000, 9999));
  String SSID = AP_SSID + '-' + randomSuffix;

  // Set up Access Point
  WiFi.mode(WIFI_AP);
  WiFi.softAP(SSID);
  IPAddress apIP(192, 168, 4, 1);
  if (!WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0))) {
    DEBUGLN("Failed to configure AP");
  }
  DEBUGLN("AP IP address: " + apIP.toString());
  dnsServer.start(DNS_PORT, "*", apIP);

  startServer();
}

void CaptivePortal::startServer() {
  // Set up web server routes
  server.on("/", [this]() { handleRoot(); });
  server.on("/connect", HTTP_POST, [this]() { handleConnect(); });
  server.on("/scan", [this]() { handleScan(); });
  server.on("/credentials", HTTP_POST, [this]() { handleCredentials(); });
  server.onNotFound([this]() { handleNotFound(); });

  server.begin();
  DEBUGLN("HTTP server started.");

  while (true) {
    if (WiFi.getMode() == WIFI_AP) {
      dnsServer.processNextRequest();
    }
    server.handleClient();
    delay(10);
  }
}

void CaptivePortal::handleRoot() { server.send(200, "text/html", INDEX_HTML); }

void CaptivePortal::handleCredentials() {
  String body = server.arg("plain");
  if (body.isEmpty()) {
    server.send(400, "text/plain", "No credentials provided.");
    return;
  }

  DEBUGLN("Received body: " + body);

  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    DEBUGLN("JSON parsing failed: " + String(error.c_str()));
    server.send(400, "application/json",
                R"({"success":false,"error":"Invalid JSON"})");
    return;
  }

  String uid = doc["uid"] | "";
  String bearer_token = doc["bearer_token"] | "";
  String plant_name = doc["plant_name"] | "My New Plant";

  if (uid.isEmpty() || bearer_token.isEmpty()) {
    server.send(400, "application/json",
                R"({"success":false,"error":"Missing fields"})");
    return;
  }

  DEBUGLN("UID: " + uid);
  DEBUGLN("Bearer Token: " + bearer_token);

  initialModePreferences.begin("stacy", false);
  initialModePreferences.putString("uid", uid);
  initialModePreferences.putString("bearer_token", bearer_token);
  initialModePreferences.putString("plant_name", plant_name);
  initialModePreferences.end();

  delay(DELAY_SHORT);
  NetworkHandler::createPlant(String(plant_name));

  server.send(200, "application/json",
              R"({"success":true,"message":"Credentials saved"})");
  delay(DELAY_SHORT);

  ESP.restart();
  return;
}

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
                R"({"success":false, "error":"Invalid JSON"})");
    return;
  }

  DEBUGLN("Credentials received.");
  DEBUGLN("Request body: " + doc.as<String>());

  const char *ssid = doc["ssid"];
  const char *wifi_password = doc["wifi_password"];
  const char *plant_name = doc["plant_name"];

  DEBUGLN("SSID: " + String(ssid));
  DEBUGLN("wifi_password: " + String(wifi_password));
  DEBUGLN("plant_name: " + String(plant_name));
  // DEBUGLN("email: " + String(email));
  // DEBUGLN("user_password: " + String(user_password));

  if (!plant_name || !ssid || !wifi_password) {
    server.send(400, "application/json",
                R"({"success":false, "error":"Missing fields"})");
    return;
  }

  initialModePreferences.begin("stacy", false);
  initialModePreferences.putString("ssid", ssid);
  initialModePreferences.putString("wifi_password", wifi_password);
  initialModePreferences.putString("plant_name", plant_name);
  initialModePreferences.end();

  server.send(200, "application/json", R"({"success":true})");

  delay(DELAY_STANDARD);

  // Stop captive portal services
  dnsServer.stop();
  server.stop();
  WiFi.softAPdisconnect(true);
  WiFi.mode(WIFI_STA);
  DEBUGLN("Captive portal stopped.");

  CaptivePortal::startMDNS();
  return;
}

void CaptivePortal::startMDNS() {
  NetworkHandler::connectToWiFi();
  delay(DELAY_SHORT);

  if (WiFi.status() != WL_CONNECTED) {
    DEBUGLN("Failed to connect to WiFi. Cannot start mDNS.");
    initialModePreferences.begin("stacy", false);
    initialModePreferences.remove("ssid");
    initialModePreferences.remove("wifi_password");
    initialModePreferences.end();
    return;
  }

  if (!MDNS.begin("plantstation")) {
    DEBUGLN("Error setting up mDNS responder!");
    return;
  }
  DEBUGLN("mDNS responder started: http://plantstation.local");
  MDNS.addService("http", "tcp", 80);

  startServer();
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
