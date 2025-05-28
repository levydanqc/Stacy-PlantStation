/**
 * Represents a weather data reading from a client device.
 */
class PlantData {
  /**
   *
   * Creates an instance of PlantData.
   * @param {number} temperature - The temperature reading in Celsius.
   * @param {number} humidity - The humidity reading in percentage.
   * @param {number} moisture - The soil moisture reading in percentage.
   * @param {number} pressure - The atmospheric pressure reading in hPa.
   * @param {number} hic - The heat index in Celsius.
   * @param {number} batteryVoltage - The battery voltage in volts.
   * @param {number} batteryPercentage - The battery percentage.
   */
  constructor(
    temperature,
    humidity,
    moisture,
    pressure,
    hic,
    batteryVoltage,
    batteryPercentage
  ) {
    if (typeof temperature !== 'number' || isNaN(temperature)) {
      throw new Error('Invalid or missing temperature: must be a number.');
    }
    if (typeof humidity !== 'number' || isNaN(humidity)) {
      throw new Error('Invalid or missing humidity: must be a number.');
    }
    if (typeof moisture !== 'number' || isNaN(moisture)) {
      throw new Error('Invalid or missing moisture: must be a number.');
    }
    if (typeof pressure !== 'number' || isNaN(pressure)) {
      throw new Error('Invalid or missing pressure: must be a number.');
    }
    if (typeof hic !== 'number' || isNaN(hic)) {
      throw new Error('Invalid or missing hic: must be a number.');
    }
    if (typeof batteryVoltage !== 'number' || isNaN(batteryVoltage)) {
      throw new Error('Invalid or missing batteryVoltage: must be a number.');
    }
    if (typeof batteryPercentage !== 'number' || isNaN(batteryPercentage)) {
      throw new Error(
        'Invalid or missing batteryPercentage: must be a number.'
      );
    }

    this.temperature = temperature;
    this.humidity = humidity;
    this.moisture = moisture;
    this.pressure = pressure;
    this.hic = hic;
    this.batteryVoltage = batteryVoltage;
    this.batteryPercentage = batteryPercentage;
  }

  /**
   * Returns a plain object representation of the WeatherData instance.
   * This is useful for sending as JSON or inserting into databases.
   * @returns {object} Plain object with weather data.
   */
  toObject() {
    const obj = {
      temperature: this.temperature,
      humidity: this.humidity,
      moisture: this.moisture,
      pressure: this.pressure,
      hic: this.hic,
      batteryVoltage: this.batteryVoltage,
      batteryPercentage: this.batteryPercentage,
    };
    return obj;
  }

  /**
   * Static factory method to create a PlantData instance from a raw object.
   * @param {object} rawData - The raw data object, typically from req.body.
   * @param {number} rawData.temperature
   * @param {number} rawData.humidity
   * @param {number} rawData.moisture
   * @param {number} rawData.pressure
   * @param {number} rawData.hic
   * @param {number} rawData.batteryVoltage
   * @param {number} rawData.batteryPercentage
   * @returns {PlantData}
   * @throws {Error} if validation fails.
   */
  static fromObject(rawData) {
    if (!rawData) {
      throw new Error('Raw data object is required.');
    }
    return new PlantData(
      rawData.temperature,
      rawData.humidity,
      rawData.moisture,
      rawData.pressure,
      rawData.hic,
      rawData.batteryVoltage,
      rawData.batteryPercentage
    );
  }
}

module.exports = PlantData;
