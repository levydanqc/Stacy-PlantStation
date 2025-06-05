#include "normal_mode.h"
#include "configuration.h"
#include "credentials.h" // For SensorData struct, if defined there
#include "debug.h"
#include <DHT.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <WiFi.h>
#include <esp_wifi.h>
#include <Preferences.h> // To retrieve stored credentials

// Declare DHT object (assuming pin 4 is fixed)
DHT dht(4, DHT11);

// --- Function Prototypes ---
void connectToWiFiNormalMode(); // Renamed to avoid conflict
void sendDataToServer(SensorData sensorData);
SensorData readSensors();
void goToDeepSleep();
void powerOn();
String getMacAddress();

Preferences normalModePreferences; // NVS object for normal mode

// --- Setup Function (runs once on boot/wake for normal mode) ---
void startNormalMode() {
  Serial.begin(115200); // Already done in main.cpp, but safe to re-initialize
  DEBUGLN("\nESP32 Woke Up into Normal Mode!");

  // Configure the ESP32 to wake up using a timer
  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);

  // Attempt to connect to Wi-Fi using stored credentials
  connectToWiFiNormalMode();

  // If WiFi is connected, proceed to send data
  if (WiFi.status() == WL_CONNECTED) {
    // 1. Simulate reading sensor data
    SensorData data = readSensors();
    // 2. Send data to the server
    sendDataToServer(data);
  } else {
    DEBUGLN("Failed to connect to WiFi in Normal Mode. Going back to sleep or re-entering setup.");
    // Optionally, if Wi-Fi fails after credentials were saved, you could
    // clear credentials and reboot to initial mode or retry
  }

  // 3. Go to deep sleep regardless of whether data was sent or not
  goToDeepSleep();
}

// --- Loop Function (empty, as logic is in setup after wake) ---
// This loop will only run if startNormalMode() doesn't put the device to sleep immediately
// For deep sleep, the loop is effectively not used after setup.
void loop() {}

// --- Helper Functions ---

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network using stored credentials.
 * Has a timeout to avoid getting stuck.
 */
void connectToWiFiNormalMode() {
  normalModePreferences.begin("wifi-creds", true); // Open NVS in read-only
  String ssid = normalModePreferences.getString("ssid");
  String password = normalModePreferences.getString("password");
  normalModePreferences.end();

  if (ssid.length() == 0) {
    DEBUGLN("Error: No SSID found in NVS for normal mode.");
    return;
  }

  DEBUG("Connecting to WiFi: ");
  DEBUGLN(ssid);

  WiFi.begin(ssid.c_str(), password.c_str());

  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(DELAY_STANDARD);
    // Timeout after 10 seconds (longer for normal operation)
    if (millis() - startTime > 10000) {
      DEBUGLN("\nWiFi Connection Timeout in Normal Mode!");
      return;
    }
  }

  DEBUGLN("\nWiFi Connected!");
  DEBUG("IP Address: ");
  DEBUGLN(WiFi.localIP());
}

SensorData readSensors() {
  powerOn(); // turn on the I2C power
  delay(DELAY_STANDARD);

  DEBUGLN("Reading DHT sensor...");
  dht.begin();
  delay(DELAY_SHORT);

  SensorData sensorData;
  sensorData.temperature = dht.readTemperature();
  sensorData.humidity = dht.readHumidity();
  sensorData.hic =
      dht.computeHeatIndex(sensorData.temperature, sensorData.humidity, false);

  // TODO : add moisture
  sensorData.moisture = 0.0;
  // TODO : add battery voltage and percentage
  sensorData.batteryVoltage = 0.0;
  sensorData.batteryPercentage = 0.0;


  DEBUG("Temperature: ");
  DEBUG(sensorData.temperature);
  DEBUG(" °C, Humidity: ");
  DEBUG(sensorData.humidity);
  DEBUG(" %, HIC: ");
  DEBUG(sensorData.hic);
  DEBUGLN(" °C");
  DEBUG("Moisture: ");
  DEBUG(sensorData.moisture);
  DEBUGLN(" %");

  return sensorData;
}

/**
 * @brief Sends the provided sensor data to the server via HTTP POST.
 * @param sensorData The struct containing sensor values.
 */
void sendDataToServer(SensorData sensorData) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClient client; // Create a WiFiClient (needed for HTTPClient on ESP32)

    DEBUG("Connecting to server: ");
    DEBUGLN(SERVER_URL);

    // Begin HTTP connection
    if (http.begin(client, SERVER_URL)) {
      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + String(AUTH_TOKEN));
      http.addHeader("Device-ID", getMacAddress()); // Call the function

      String jsonPayload =
          "{\"temperature\":" + String(sensorData.temperature) +
          ",\"humidity\":" + String(sensorData.humidity) +
          ",\"hic\":" + String(sensorData.hic) +
          ",\"moisture\":" + String(sensorData.moisture) +
          ",\"batteryVoltage\":" + String(sensorData.batteryVoltage) +
          ",\"batteryPercentage\":" + String(sensorData.batteryPercentage) + "}";


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
 * @brief Powers on the I2C bus by setting the power pin to LOW.
 */
void powerOn() {
  // turn on the I2C power by setting pin to LOW
  pinMode(PIN_I2C_POWER, OUTPUT);
  digitalWrite(PIN_I2C_POWER, LOW);
}

/**
 * @brief Puts the ESP32 into deep sleep mode.
 */
void goToDeepSleep() {
  DEBUGLN(String("Going to sleep for ") + String(TIME_TO_SLEEP) +
          String(" seconds..."));
  WiFi.disconnect();
  delay(DELAY_SHORT);
  WiFi.mode(WIFI_OFF);

  pinMode(PIN_I2C_POWER, OUTPUT);
  digitalWrite(PIN_I2C_POWER, HIGH);
  delay(DELAY_SHORT);

  esp_deep_sleep_start();
  // Code execution stops here until the ESP32 wakes up
}

/**
 * @brief Reads the MAC address of the ESP32 and prints it to the Serial Monitor.
 * @return The MAC address as a String.
 */
String getMacAddress(){
  uint8_t baseMac[6];
  esp_err_t ret = esp_wifi_get_mac(WIFI_IF_STA, baseMac);
  if (ret == ESP_OK) {
    String macAddress = String(baseMac[0], HEX) + ":" +
                  String(baseMac[1], HEX) + ":" +
                  String(baseMac[2], HEX) + ":" +
                  String(baseMac[3], HEX) + ":" +
                  String(baseMac[4], HEX) + ":" +
                  String(baseMac[5], HEX);
    macAddress.toUpperCase();
    DEBUGLN("MAC Address: " + macAddress);
    return macAddress;
  } else {
    DEBUGLN("Failed to read MAC address");
    return "UNKNOWN"; // Return a default or error string
  }
}