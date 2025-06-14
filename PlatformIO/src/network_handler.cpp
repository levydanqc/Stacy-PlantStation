#include "network_handler.h"
#include "credentials.h"
#include "debug.h"

#include <HTTPClient.h>
#include <WiFi.h>
#include <esp_wifi.h>

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network.
 * Has a timeout to avoid getting stuck.
 */
void NetworkHandler::connectToWiFi() {
  DEBUG("Connecting to WiFi: ");
  DEBUGLN(WIFI_SSID);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(DELAY_STANDARD);
    // Timeout after 5 seconds
    if (millis() - startTime > 5000) {
      DEBUGLN("\nWiFi Connection Timeout!");
      return;
    }
  }

  if (WiFi.status() != WL_CONNECTED) {
    DEBUGLN("Failed to connect to WiFi. Going back to sleep.");
    return;
    // powerOff();
  }

  DEBUGLN("\nWiFi Connected!");
  DEBUG("IP Address: ");
  DEBUGLN(WiFi.localIP());
}
/**
 * @brief Sends the provided temperature and humidity data to the server via
 * HTTP POST.
 * @param temperature The temperature value.
 * @param humidity The humidity value.
 */
void NetworkHandler::sendDataToServer(SensorData sensorData) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClient client; // Create a WiFiClient (needed for HTTPClient on ESP32)

    DEBUG("Connecting to server: ");
    DEBUGLN(SERVER_URL);

    // Begin HTTP connection
    if (http.begin(client, SERVER_URL)) {
      // Set headers
      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));
      http.addHeader("Device-ID", getMacAddress());
      http.addHeader("UID", "d2ae76dd32239411");

      String jsonPayload =
          "{\"temperature\":" + String(sensorData.temperature) +
          ",\"humidity\":" + String(sensorData.humidity) +
          ",\"moisture\":" + String(sensorData.moisture) +
          ",\"pressure\":" + String(sensorData.pressure) +
          ",\"hic\":" + String(sensorData.hic) +
          ",\"dewPoint\":" + String(sensorData.dewPoint) +
          ",\"batteryPercentage\":" + String(sensorData.batteryPercentage) +
          ",\"batteryVoltage\":" + String(sensorData.batteryVoltage) + "}";

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      // Send POST request
      int httpResponseCode = http.POST(jsonPayload);

      // Check response
      if (httpResponseCode > 0) {
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
      } else {
        DEBUGLN(String("HTTP POST failed, error: ") +
                http.errorToString(httpResponseCode));
      }

      // End HTTP connection
      http.end();
    } else {
      DEBUGLN("HTTP connection failed. Unable to begin.");
    }
  } else {
    DEBUGLN("WiFi not connected. Cannot send data.");
  }
}

/**
 * @brief Reads the MAC address of the ESP32 and prints it to the Serial
 * Monitor.
 * @return The MAC address as a String.
 */
String NetworkHandler::getMacAddress() {
  DEBUG("Reading MAC address... ");
  uint8_t baseMac[6];
  esp_err_t ret = esp_wifi_get_mac(WIFI_IF_STA, baseMac);

  if (ret == ESP_OK) {
    char macStr[18];
    snprintf(macStr, sizeof(macStr), "%02X:%02X:%02X:%02X:%02X:%02X",
         baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4], baseMac[5]);
    String macAddress = String(macStr);
    macAddress.toUpperCase();
    DEBUGLN("MAC Address: " + macAddress);

    return macAddress;
  } else {
    DEBUGLN("Failed to read MAC address");
    DEBUGLN("Error code: " + String(ret));

    return "00:00:00:00:00:00";
  }
}