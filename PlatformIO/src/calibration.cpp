// #include "configuration.h"

// void calibrate();
// float readCapacitance();

// void setup() {
//   Serial.begin(115200);
//   Serial.println("\nESP32 in Calibration Mode!");
// }

// void loop() {
//   calibrate();

//   delay(1000);
// }

// /**
//  * @brief Calibrates the capacitance sensor by taking readings in known
//  * environments.
//  * The calibration values are stored in EEPROM.
//  **/
// void calibrate() {
//   uint16_t sensorValue = analogRead(CAPACITANCE_PIN);

//   for (int i = 0; i < 5; i++) {
//     sensorValue = (sensorValue + analogRead(CAPACITANCE_PIN)) / 2;
//   }

//   float voltage = sensorValue * (3.3 / 4095.0);
//   float capacitance = (voltage * 10.0) + 5.0;

//   Serial.print("Sensor Value: ");
//   Serial.println(sensorValue);
//   Serial.print("Capacitance: ");
//   Serial.println(capacitance);
//   Serial.print("Voltage: ");
//   Serial.println(voltage);
// }
