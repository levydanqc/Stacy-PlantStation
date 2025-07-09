#include "network_handler.h"
#include "credentials.h"
#include "debug.h"

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <esp_wifi.h>

Preferences networkPreferences;

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network.
 * Has a timeout to avoid getting stuck.
 */
void NetworkHandler::connectToWiFi() {
  networkPreferences.begin("stacy", true);
  String ssid = networkPreferences.getString("ssid");
  String password = networkPreferences.getString("wifi_password");
  networkPreferences.end();

  // check if already connected
  if (WiFi.status() == WL_CONNECTED) {
    DEBUGLN("Already connected to WiFi.");
    DEBUG("IP Address: ");
    DEBUGLN(WiFi.localIP());
    return;
  }

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
    WiFiClientSecure client;
    client.setInsecure();

    // Begin HTTP connection
    if (http.begin(client, String(SERVER_URL) + "/weather")) {
      DEBUG("Connecting to server: ");
      DEBUGLN(String(SERVER_URL) + "/weather");

      networkPreferences.begin("stacy", true);
      String bearerToken = networkPreferences.getString("bearer_token", "");
      String uid = networkPreferences.getString("uid", "");
      networkPreferences.end();

      DEBUG("Bearer Token: ");
      DEBUGLN(bearerToken);
      DEBUG("UID: ");
      DEBUGLN(uid);

      // Set headers
      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + bearerToken);
      http.addHeader("Device-id", getMacAddress());
      http.addHeader("UID", uid);

      String jsonPayload =
          "{\"temperature\":" + String(sensorData.temperature) +
          ",\"humidity\":" + String(sensorData.humidity) +
          ",\"moisture\":" + String(sensorData.moisture) +
          ",\"hic\":" + String(sensorData.hic) +
          ",\"batteryPercentage\":" + String(sensorData.batteryPercentage) +
          ",\"batteryVoltage\":" + String(sensorData.batteryVoltage) + "}";

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      // Send POST request
      int httpResponseCode = http.POST(jsonPayload);

      // Check response
      if (httpResponseCode > 0) {
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
        if (httpResponseCode == HTTP_CODE_FORBIDDEN) {
          DEBUGLN("Expired or invalid token.");
          // TODO : FIX
          // networkPreferences.begin("stacy", true);
          // String email = networkPreferences.getString("email");
          // String password = networkPreferences.getString("user_password");
          // networkPreferences.end();

          // NetworkHandler::loginUser(email, password);
          // DEBUGLN("Re-attempting to send data after re-login.");
          // NetworkHandler::sendDataToServer(sensorData);
        }
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
 * @return True if login is successful, false otherwise.
 */
bool NetworkHandler::loginUser(const String &email, const String &password) {

  if (WiFi.status() != WL_CONNECTED) {
    NetworkHandler::connectToWiFi();
    delay(DELAY_STANDARD);
  }

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClientSecure client;
    client.setInsecure();

    DEBUG("Logging in user: ");
    DEBUGLN(email);

    // Begin HTTP connection
    if (http.begin(client, String(SERVER_URL) + "/login")) {
      http.addHeader("Content-Type", "application/json");

      String jsonPayload =
          "{\"email\":\"" + email + "\",\"password\":\"" + password + "\"}";

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      // Send POST request and get response headers for auth_token
      const char *headerKeys[] = {"auth_token"};
      const size_t headerKeysCount = sizeof(headerKeys) / sizeof(headerKeys[0]);
      http.collectHeaders(headerKeys, headerKeysCount);

      int httpResponseCode = http.POST(jsonPayload);

      // Check response
      if (httpResponseCode > 0) {
        String response = http.getString();
        String authToken = http.header("auth_token");
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
        DEBUGLN("Response: " + response);
        http.end();

        // Parse the user ID from the response (assuming it's in JSON format :
        // {"uid":"..."} )
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        if (!error) {
          DEBUGLN("Parsed JSON successfully.");
          // Show the document content
          DEBUGLN("Document content: " + doc.as<String>());
          String uid = doc["uid"].as<String>();
          DEBUGLN("User ID: " + uid);

          // Store the auth token and user ID in preferences
          networkPreferences.begin("stacy", false);
          networkPreferences.putString("bearer_token", authToken);
          networkPreferences.putString("uid", uid);
          networkPreferences.end();

          if (uid.isEmpty())
            return false;

          return true;
        } else {
          DEBUGLN("Failed to parse JSON response: " + String(error.c_str()));
          return false;
        }
      } else {
        DEBUGLN(String("HTTP POST failed, error: ") +
                http.errorToString(httpResponseCode));
        http.end();
        return false;
      }
    } else {
      DEBUGLN("HTTP connection failed. Unable to begin.");
      return false;
    }
  } else {
    DEBUGLN("WiFi not connected. Cannot log in.");
    return false;
  }
}

void NetworkHandler::createPlant(String plantName) {
  delay(DELAY_STANDARD);

  if (WiFi.status() != WL_CONNECTED) {
    NetworkHandler::connectToWiFi();
    delay(DELAY_STANDARD);
  }

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClientSecure client;
    client.setInsecure();

    if (http.begin(client, String(SERVER_URL) + "/plants")) {
      DEBUG("Creating plant on server: ");
      DEBUGLN(String(SERVER_URL) + "/plants");

      networkPreferences.begin("stacy", true);
      String uid = networkPreferences.getString("uid", "");
      String bearerToken = networkPreferences.getString("bearer_token", "");
      networkPreferences.end();

      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + bearerToken);
      http.addHeader("Device-ID", getMacAddress());
      http.addHeader("UID", uid);

      String jsonPayload = "{\"plant_name\":\"" + plantName + "\"}";

      delay(DELAY_STANDARD);
      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);
      DEBUG("UID: ");
      DEBUGLN(uid);
      DEBUG("Bearer Token: ");
      DEBUGLN(bearerToken);

      // Send POST request
      int httpResponseCode = http.POST(jsonPayload);

      if (httpResponseCode == HTTP_CODE_FORBIDDEN) {
        DEBUGLN("Expired or invalid token. Refreshing token...");
        bool worked = NetworkHandler::refreshToken();

        if (!worked) {
          DEBUGLN("Failed to refresh token. Cannot create plant.");
          return;
        }
        DEBUGLN("Re-attempting to create plant after token refresh.");
        NetworkHandler::createPlant(plantName);
      } else if (httpResponseCode == HTTP_CODE_CREATED) {
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));

        String response = http.getString();
        DEBUGLN("Response: " + response);

        // Parse the plant ID from the response (assuming it's in JSON format)
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        if (!error) {
          String plantId = doc["plant_id"].as<String>();
          DEBUGLN("Parsed JSON successfully.");
          DEBUGLN("Plant ID: " + plantId);
          // Store the plant ID in preferences
          networkPreferences.begin("stacy", false);
          networkPreferences.putString("plant_id", plantId);
          networkPreferences.end();

          if (plantId.isEmpty()) {
            DEBUGLN("Failed to create plant. Plant ID is empty.");
          } else {
            DEBUGLN("Plant created successfully with ID: " + plantId);
          }
        } else {
          DEBUGLN("Failed to parse JSON response: " + String(error.c_str()));
        }
      } else {
        DEBUGLN(String("HTTP POST failed, code: ") + String(httpResponseCode) +
                ", error: " + http.errorToString(httpResponseCode));
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
 * @brief Refreshes the bearer token by using the /refresh endpoint.
 * This function should be called when the token is expired or invalid.
 * It should send the expired token as well as the device ID and UID.
 * @return True if the token was refreshed successfully, false otherwise.
 */
bool NetworkHandler::refreshToken() {
  delay(DELAY_STANDARD);
  if (WiFi.status() != WL_CONNECTED) {
    NetworkHandler::connectToWiFi();
    delay(DELAY_STANDARD);
  }
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClientSecure client;
    client.setInsecure();

    DEBUGLN("Refreshing bearer token...");

    if (http.begin(client, String(SERVER_URL) + "/refresh")) {
      networkPreferences.begin("stacy", true);
      String bearerToken = networkPreferences.getString("bearer_token", "");
      String uid = networkPreferences.getString("uid", "");
      networkPreferences.end();

      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + bearerToken);
      http.addHeader("Device-ID", getMacAddress());
      http.addHeader("UID", uid);

      DEBUG("Sending JSON payload: ");
      DEBUGLN(jsonPayload);

      int httpResponseCode = http.POST("{}");

      if (httpResponseCode == HTTP_CODE_OK) {
        String response = http.getString();
        DEBUGLN(String("HTTP POST response code: ") + String(httpResponseCode));
        DEBUGLN("Response: " + response);

        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        if (!error) {
          String newToken = doc["auth_token"].as<String>();
          DEBUGLN("Parsed JSON successfully.");
          DEBUGLN("New Bearer Token: " + newToken);

          networkPreferences.begin("stacy", false);
          networkPreferences.putString("bearer_token", newToken);
          networkPreferences.end();

          return true;
        } else {
          DEBUGLN("Failed to parse JSON response: " + String(error.c_str()));
          return false;
        }
      } else {
        DEBUGLN(String("HTTP POST failed, code: ") + String(httpResponseCode) +
                ", error: " + http.errorToString(httpResponseCode));
        return false;
      }
      http.end();
    } else {
      DEBUGLN("HTTP connection failed. Unable to begin.");
      return false;
    }
  } else {
    DEBUGLN("WiFi not connected. Cannot refresh token.");
    return false;
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