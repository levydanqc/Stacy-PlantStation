const getClientIdFromDeviceIdSQL = `
SELECT user_id FROM devices WHERE device_id = ?;
`;

const getAllDataFromClientIdSQL = `
SELECT * FROM sensor_data WHERE user_id = ? ORDER BY timestamp DESC;
`;

const addSensorDataSQL = `
INSERT INTO sensor_data (user_id, temperature, humidity, moisture, pressure, hic, batteryVoltage, batteryPercentage) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?);
`;

const addUserSQL = `
INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)
`;

const addPlantSQL = `
INSERT INTO plants (user_id, device_id, plant_name) VALUES (?, ?, ?)
`;

const addDeviceSQL = `
INSERT INTO devices (device_id, user_id) VALUES (?, ?)
`;

const getPlantIdSQL = `
SELECT 
`;

module.exports = {
  getClientIdFromDeviceIdSQL,
  getAllDataFromClientIdSQL,
  addSensorDataSQL,
  getPlantIdSQL,
  addUserSQL,
  addPlantSQL,
  addDeviceSQL,
};
