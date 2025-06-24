#include "network_handler.h"
#include "credentials.h"
#include "debug.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <WiFi.h>
#include <esp_wifi.h>

Preferences networkPreferences;

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network.
 * Has a timeout to avoid getting stuck.
 */
void NetworkHandler::connectToWiFi() {
  networkPreferences.begin("wifi-creds", true);
  String ssid = networkPreferences.getString("ssid");
  String password = networkPreferences.getString("wifi_password");
  networkPreferences.end();

  DEBUG("Connecting to WiFi: ");
  DEBUGLN(ssid);
  WiFi.begin(ssid, password);

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
    if (http.begin(client, String(SERVER_URL) + "/weather")) {
      // Set headers
      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));
      http.addHeader("Device-ID", getMacAddress());

      networkPreferences.begin("wifi-creds", true);
      String uid = networkPreferences.getString("uid", "");
      networkPreferences.end();

      http.addHeader("UID", uid);

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
 * @brief Logs in the user with the provided email and password.
 * @param email The user's email.
 * @param password The user's password.
 * @return The user ID if login is successful, empty string otherwise.
 */
String NetworkHandler::loginUser(const String &email, const String &password) {
  NetworkHandler::connectToWiFi();
  delay(DELAY_STANDARD);

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClient client;

    DEBUG("Logging in user: ");
    DEBUGLN(email);

    // Begin HTTP connection
    if (http.begin(client, String(SERVER_URL) + "/sessions")) {

      String hashedPassword = NetworkHandler::hashPassword(password);

      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));

      String jsonPayload = "{\"email\":\"" + email + "\",\"password\":\"" +
                           hashedPassword + "\"}";

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      // Send POST request
      int httpResponseCode = http.POST(jsonPayload);

      // Check response
      if (httpResponseCode > 0) {
        String response = http.getString();
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
        DEBUGLN("Response: " + response);
        http.end();

        // Parse the user ID from the response (assuming it's in JSON format)
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        if (!error) {
          DEBUGLN("Parsed JSON successfully.");
          DEBUG("User ID: ");
          DEBUGLN(doc["uid"].as<String>());

          return doc["uid"].as<String>();
        } else {
          DEBUGLN("Failed to parse JSON response: " + String(error.c_str()));
          return "";
        }
      } else {
        DEBUGLN(String("HTTP POST failed, error: ") +
                http.errorToString(httpResponseCode));
        http.end();
        return "";
      }
    } else {
      DEBUGLN("HTTP connection failed. Unable to begin.");
      return "";
    }
  } else {
    DEBUGLN("WiFi not connected. Cannot log in.");
    return "";
  }
}

void NetworkHandler::createPlant(String plantName) {
  NetworkHandler::connectToWiFi();
  delay(DELAY_STANDARD);

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClient client;

    DEBUG("Creating plant on server: ");
    DEBUGLN(SERVER_URL);

    if (http.begin(client, String(SERVER_URL) + "/plants")) {
      networkPreferences.begin("wifi-creds", true);
      String uid = networkPreferences.getString("uid", "");
      networkPreferences.end();

      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));
      http.addHeader("Device-ID", getMacAddress());
      http.addHeader("UID", uid);

      String jsonPayload = "{\"plant_name\":\"" + plantName + "\"}";

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      // Send POST request
      int httpResponseCode = http.POST(jsonPayload);

      if (httpResponseCode > 0) {
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
      } else {
        DEBUGLN(String("HTTP POST failed, error: ") +
                http.errorToString(httpResponseCode));
      }

      http.end();
    } else {
      DEBUGLN("HTTP connection failed. Unable to begin.");
    }
  } else {
    DEBUGLN("WiFi not connected. Cannot create plant.");
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
             baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4],
             baseMac[5]);
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

String NetworkHandler::hashPassword(const String &password) {
  String toHash = password + SALT;

  byte hashResult[32];

  const mbedtls_md_info_t *md_info =
      mbedtls_md_info_from_type(MBEDTLS_MD_SHA256);
  if (md_info == NULL) {
    Serial.println("Failed to get mbedtls md_info for SHA256");
    return "";
  }
  int return_code = mbedtls_md(md_info, (const unsigned char *)toHash.c_str(),
                               toHash.length(), hashResult);

  if (return_code != 0) {
    Serial.printf("mbedtls_md() returned -0x%04X\n",
                  (unsigned int)-return_code);
    return "";
  }

  String hashString = "";
  for (int i = 0; i < 32; i++) {
    char hex[3];
    sprintf(hex, "%02x", hashResult[i]);
    hashString += hex;
  }

  return hashString;
}