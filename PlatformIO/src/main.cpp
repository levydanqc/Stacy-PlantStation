#define DEBUG_MODE 1

#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <Arduino.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <WiFi.h>

void uploadData(SensorData sensorData) {
  DEBUGLN("Uploading data to server...");
  WiFiClient client;
  HTTPClient http;
  http.begin(client, SERVER_URL);

  DEBUG("POST to server: ");
  DEBUGLN(SERVER_URL);

  // Specify content-type header
  http.addHeader("Authorization", "API_KEY");

  // Convert struct to JSON string
  String jsonString = "{\"temperature\":" + String(sensorData.temperature) +
                      ",\"humidity\":" + String(sensorData.humidity) +
                      ",\"pressure\":" + String(sensorData.pressure) + "}";
  // Send HTTP POST request
  http.addHeader("Content-Type", "application/json");
  int httpResponseCode = http.POST(jsonString);

  DEBUG("HTTP Response code: ");
  DEBUGLN(httpResponseCode);

  // Free resources
  http.end();

  DEBUGLN("Data uploaded successfully!");
}

void powerOn() {
  // turn on the I2C power by setting pin to LOW
  pinMode(PIN_I2C_POWER, OUTPUT);
  digitalWrite(PIN_I2C_POWER, LOW);
}

// void checkBattery() {
// // Get battery readings
// Adafruit_LC709203F lc;
// if (!lc.begin()) {
//   DEBUGLN("Could not find Adafruit LC709203F or battery not plugged in!");
//   return;
// }
// delay(DELAY_STANDARD);
// sensorData.batteryVoltage = lc.cellVoltage();
// delay(DELAY_STANDARD);
// sensorData.batteryPercentage = lc.cellPercent();
// DEBUG("Batt Voltage: ");
// DEBUGLN(sensorData.batteryVoltage);
// DEBUG("Batt Percent: ");
// DEBUGLN(sensorData.batteryPercentage);
// }

bool connectToWiFi() {
  DEBUG("Connecting to WiFi network: ");
  DEBUGLN(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  if (WiFi.status() != WL_CONNECTED) {
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  }
  if (WiFi.waitForConnectResult() == WL_CONNECTED) {
    DEBUG("WiFi connected: ");
    DEBUGLN(WiFi.localIP());

    return true;
  }
  DEBUGLN("WiFi not connected, check your credentials");
  return false;
}

void gotoSleep() {
  // Go to deep sleep
  DEBUGLN("Going to sleep for 10 minutes");
  WiFi.disconnect();
  delay(DELAY_SHORT);
  WiFi.mode(WIFI_OFF);
  pinMode(PIN_I2C_POWER, OUTPUT);
  digitalWrite(PIN_I2C_POWER, HIGH);
  delay(DELAY_SHORT);
  esp_sleep_enable_timer_wakeup(1000000); // 5 seconds
  esp_deep_sleep_start();
}

SensorData readSensors() {
  powerOn(); // turn on the I2C power
  delay(DELAY_LONG);
  // read the sensors

  // TODO: Add your sensor reading code here

  // TODO: Save the sensor data to the struct
  SensorData sensorData;
  float temperature = analogRead(4);
  sensorData.temperature = temperature;
  sensorData.humidity = 49.54;
  sensorData.pressure = 1005.14;

  return sensorData;
}

void setup() {
#ifdef DEBUG_MODE
  Serial.begin(115200);
  while (!Serial)
    ; // wait for serial connection to be ready
  delay(DELAY_LONG);
  Serial.flush();
#endif
  DEBUGLN("Debug mode on");
  delay(DELAY_SHORT);
  if (!connectToWiFi())
    gotoSleep();

  SensorData data = readSensors();
  uploadData(data);

  delay(DELAY_SHORT);
  gotoSleep();
}

void loop() {}
