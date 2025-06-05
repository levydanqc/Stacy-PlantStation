#include "initial_mode.h"
#include "configuration.h"
#include "debug.h"
#include <WiFi.h>
#include <WebServer.h>
#include <DNSServer.h>
#include <Preferences.h>

DNSServer dnsServer;
WebServer server(80);
Preferences initialModePreferences;

// HTML for the captive portal
const char PROGMEM INDEX_HTML[] = R"rawliteral(
<!DOCTYPE HTML><html><head>
  <title>ESP32 Wi-Fi Setup</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  </head><body>
  <h3>ESP32 Wi-Fi Setup</h3>
  <form action="/connect" method="post">
    <label for="ssid">Wi-Fi Network (SSID):</label><br>
    <select id="ssid" name="ssid">
      </select><br><br>
    <label for="password">Password:</label><br>
    <input type="password" id="password" name="password"><br><br>
    <input type="submit" value="Connect">
  </form>
  <script>
    // JavaScript to fetch and display Wi-Fi networks
    fetch('/scan')
      .then(response => response.json())
      .then(data => {
        const ssidSelect = document.getElementById('ssid');
        data.forEach(network => {
          const option = document.createElement('option');
          option.value = network;
          option.textContent = network;
          ssidSelect.appendChild(option);
        });
      });
  </script>
</body></html>
)rawliteral";

void handleRoot() {
  server.send(200, "text/html", INDEX_HTML);
}

void handleConnect() {
  if (server.hasArg("ssid") && server.hasArg("password")) {
    String ssid = server.arg("ssid");
    String password = server.arg("password");

    initialModePreferences.begin("wifi-creds", false);
    initialModePreferences.putString("ssid", ssid);
    initialModePreferences.putString("password", password);
    initialModePreferences.end();

    DEBUGLN("Credentials received. Attempting to connect to WiFi...");
    DEBUGLN("SSID: " + ssid);
    DEBUGLN("Password: " + password);

    server.send(200, "text/plain", "Attempting to connect to WiFi. The device will restart soon.");

    delay(2000);
    ESP.restart();
  } else {
    server.send(400, "text/plain", "Invalid request. Missing SSID or password.");
  }
}

void handleScan() {
  DEBUGLN("Scanning for WiFi networks...");
  int n = WiFi.scanNetworks();
  String json = "[";
  for (int i = 0; i < n; ++i) {
    if (i > 0) json += ",";
    json += "\"" + WiFi.SSID(i) + "\"";
  }
  json += "]";
  server.send(200, "application/json", json);
  DEBUGLN("Scan complete. Sent " + String(n) + " networks.");
}

void handleNotFound() {
  server.sendHeader("Location", "http://" + WiFi.softAPIP().toString() + "/");
  server.send(302, "text/plain", "");
}

void startInitialMode() {
  DEBUGLN("Starting Initial Mode (Captive Portal)");

  // Set up Access Point
  WiFi.mode(WIFI_AP);
  WiFi.softAP(AP_SSID);
  IPAddress apIP = WiFi.softAPIP();
  DEBUGLN("AP IP address: " + apIP.toString());

  // Set up DNS server for captive portal
  dnsServer.start(DNS_PORT, "*", apIP);

  // Set up web server routes
  server.on("/", handleRoot);
  server.on("/connect", HTTP_POST, handleConnect);
  server.on("/scan", handleScan);
  server.onNotFound(handleNotFound);

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