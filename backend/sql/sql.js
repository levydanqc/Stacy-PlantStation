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

const getPlantIdSQL = `
SELECT plant_id FROM plants WHERE user_id = ? AND device_id = ?;
`;

module.exports = {
  addSensorDataSQL,
  getPlantIdSQL,
  addUserSQL,
  addPlantSQL,
  getTablesSQL,
};
