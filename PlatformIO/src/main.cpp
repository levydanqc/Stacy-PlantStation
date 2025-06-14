#define DEBUG_MODE 1

#include "configuration.h"
#include "credentials.h"
#include "debug.h"
#include <Adafruit_BME280.h>
#include <Adafruit_Sensor.h>
#include <EnvironmentCalculations.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <WiFi.h>
#include <Wire.h>

Adafruit_BME280 bme280;

// --- Function Prototypes ---
void connectToWiFi();
void sendDataToServer(SensorData sensorData);
SensorData readSensors();
void powerOff();
float readMoisture();
float readBatteryVoltage();
int calculateBatteryPercentage(float voltage);

// --- Setup Function (runs once on boot/wake) ---
void setup() {
  Serial.begin(115200);
  DEBUGLN("\nESP32 Woke Up!");

  // pinMode(TPL5110_DONE_PIN, OUTPUT);

  // Attempt to connect to Wi-Fi
  connectToWiFi();

  // If WiFi is connected, proceed to send data
  if (WiFi.status() != WL_CONNECTED) {
    DEBUGLN("Failed to connect to WiFi. Going back to sleep.");
    return;
  }

  SensorData data = readSensors();
  data.batteryVoltage = readBatteryVoltage();
  data.batteryPercentage = calculateBatteryPercentage(data.batteryVoltage);

  sendDataToServer(data);

  // Signal the TPL5110 to turn off power
  // powerOff();
}

// --- Loop Function (empty, as logic is in setup after wake) ---
void loop() {}

// --- Helper Functions ---

/**
 * @brief Connects the ESP32 to the configured Wi-Fi network.
 * Has a timeout to avoid getting stuck.
 */
void connectToWiFi() {
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

  DEBUGLN("\nWiFi Connected!");
  DEBUG("IP Address: ");
  DEBUGLN(WiFi.localIP());
}

SensorData readSensors() {
  unsigned status = bme280.begin(BME280_ADDR);

  if (!status) {
    DEBUG("BME280 sensor initialization failed with status: ");
    DEBUGLN(status);
    // powerOff();
  }

  DEBUGLN("Reading BME280 sensor...");

  SensorData sensorData;
  sensorData.temperature = bme280.readTemperature();
  sensorData.humidity = bme280.readHumidity();
  sensorData.pressure = bme280.readPressure() / 100.0;
  sensorData.moisture = readMoisture();

  sensorData.dewPoint = EnvironmentCalculations::DewPoint(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);
  sensorData.hic = EnvironmentCalculations::HeatIndex(
      sensorData.temperature, sensorData.humidity, ENV_TEMP_UNIT);

  return sensorData;
}

/**
 * @brief Sends the provided temperature and humidity data to the server via
 * HTTP POST.
 * @param temperature The temperature value.
 * @param humidity The humidity value.
 */
void sendDataToServer(SensorData sensorData) {
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
      http.addHeader("Device-ID", "F1:F1:F1:F1:F1:F1");
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
 * @brief Turn off power by controlling the TPL5110 DONE pin.
 * This function sets the TPL5110 DONE pin to LOW and then HIGH to signal
 * the TPL5110 to turn off power.
 */
void powerOff() {
  digitalWrite(TPL5110_DONE_PIN, LOW);
  digitalWrite(TPL5110_DONE_PIN, HIGH);
  delay(100);
}

/**
 * @brief Reads the battery voltage from the ADC pin.
 * @return The battery voltage.
 */
float readBatteryVoltage() {
  analogSetPinAttenuation(BATTERY_PIN,
                          ADC_11db);      // Configure ADC for 0-2.5V range
  uint16_t raw = analogRead(BATTERY_PIN); // Read raw ADC value
  float vOut = (raw / 4095.0) * 2.5;      // Convert ADC value to voltage
  float vBattery = vOut / 0.5;            // Scale to battery voltage
  return vBattery;
}

/**
 * @brief Calculates the battery percentage based on the voltage.
 * @param voltage The voltage value.
 * @return The calculated battery percentage.
 */
int calculateBatteryPercentage(float voltage) {
  float percentage =
      ((voltage - BATTERY_MIN) / (BATTERY_MAX - BATTERY_MIN)) * 100.0;
  if (percentage > 100)
    percentage = 100;
  if (percentage < 0)
    percentage = 0;
  return (int)percentage;
}

/**
 * @brief Reads the moisture from the sensor.
 * @return The moisture value.
 */
float readMoisture() {
  uint16_t sensorValue = analogRead(CAPACITANCE_PIN);

  float voltage = sensorValue * (3.3 / 4095.0);
  // TODO : calibrate this value
  float moisture = (voltage * 10.0) + 5.0;
  return moisture;
}
