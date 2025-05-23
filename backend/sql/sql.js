const getTablesSQL = `
SELECT name FROM sqlite_master WHERE type='table' LIMIT 1;
`;

const addSensorDataSQL = `
INSERT INTO sensor_data (plant_id, temperature, humidity, moisture, pressure, hic, batteryVoltage, batteryPercentage) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?);
`;

const addUserSQL = `
INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?);
`;

const addPlantSQL = `
INSERT INTO plants (user_id, device_id, plant_name) VALUES (?, ?, ?);
`;

const getPlantIdFromUserIdAndDeviceIdSQL = `
SELECT plant_id FROM plants WHERE user_id = ? AND device_id = ?;
`;

const getPlantIdFromUserIdSQL = `
SELECT plant_id FROM plants WHERE user_id = ?;
`;

const getDataByPlantIdSQL = `
SELECT * FROM sensor_data WHERE plant_id = ? ORDER BY timestamp DESC LIMIT 100;
`;

module.exports = {
  addSensorDataSQL,
  getPlantIdFromUserIdAndDeviceIdSQL,
  getPlantIdFromUserIdSQL,
  getDataByPlantIdSQL,
  addUserSQL,
  addPlantSQL,
  getTablesSQL,
};
