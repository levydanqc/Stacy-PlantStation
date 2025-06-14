/**
 * Represents a Plant with an ESP32 module
 */
class Plant {
  /**
   * Creates an instance of User.
   * @param {string} device_id - The MAC address of the esp32 module.
   * @param {string} plant_name - The name of the plant that is being monitored.
   */
  constructor(device_id, plant_name) {
    // TODO : implement logic to validate mac address
    console.log('device id : ', device_id);
    console.log('typeoff device id : ', typeof device_id);

    if (typeof device_id !== 'string' || device_id.length == 0) {
      throw new Error(
        'Invalid or missing device_id: must be a valid MAC address.'
      );
    }
    // TODO : implement logic to validate plant_name
    if (typeof plant_name !== 'string' || plant_name.length == 0) {
      throw new Error('Invalid or missing plant_name: must be a valid email.');
    }

    this.device_id = device_id;
    this.plant_name = plant_name;
  }

  /**
   * Returns a plain object representation of the Plant instance.
   * This is useful for sending as JSON or inserting into databases.
   * @returns {object} Plain object with Plant data.
   */
  toObject() {
    const obj = {
      device_id: this.device_id,
      plant_name: this.plant_name,
    };
    return obj;
  }

  /**
   * Static factory method to create a Plant instance from a raw object.
   * @param {object} rawData - The raw data object, typically from req.body.
   * @param {string} rawData.device_id
   * @param {string} rawData.plant_name
   * @returns {Plant}
   * @throws {Error} if validation fails.
   */
  static fromObject(rawData) {
    if (!rawData) {
      throw new Error('Raw data object is required.');
    }
    return new Plant(rawData.device_id, rawData.plant_name);
  }
}

module.exports = Plant;
