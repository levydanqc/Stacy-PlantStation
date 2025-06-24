const getTablesSQL = `
SELECT name FROM sqlite_master WHERE type='table' LIMIT 1;
`;

const addSensorDataSQL = `
INSERT INTO sensor_data (plant_id, temperature, humidity, moisture, hic, batteryVoltage, batteryPercentage) 
VALUES (?, ?, ?, ?, ?, ?, ?);
`;

const addUserSQL = `
INSERT INTO users (username, uid, email, password) VALUES (?, ?, ?, ?);
`;

const addPlantSQL = `
INSERT INTO plants (user_id, device_id, plant_name) VALUES (?, ?, ?);
`;

const getPlantFromUserIdAndDeviceIdSQL = `
SELECT * FROM plants WHERE user_id = ? AND device_id = ?;
`;

const getPlantIdFromUserIdSQL = `
SELECT plant_id FROM plants WHERE user_id = ?;
`;

const getDataByPlantIdSQL = `
SELECT * FROM plant_data WHERE plant_id = ? ORDER BY timestamp ASC LIMIT 100;
`;

const getUserByEmailSQL = `
SELECT * FROM users WHERE email = ?;
`;

const getUserByUIDSQL = `
SELECT * FROM users WHERE uid = ?;
`;

const getUserPasswordSQL = `
SELECT password FROM users WHERE user_id = ?;
`;

const getPlantsByUserIdSQL = `
SELECT * FROM plants WHERE user_id = ?;
`;

const getPlantByDeviceIdSQL = `
SELECT * FROM plants WHERE device_id = ?;
`;

const getPlantByIdSQL = `
SELECT * FROM plants WHERE plant_id = ?;
`;

const getDataByRowIdSQL = `
SELECT * FROM plant_data WHERE data_id = ?;
`;

module.exports = {
  addPlantDataSQL,
  getPlantFromUserIdAndDeviceIdSQL,
  getPlantIdFromUserIdSQL,
  getDataByPlantIdSQL,
  addUserSQL,
  addPlantSQL,
  getTablesSQL,
  getUserByEmailSQL,
  getUserPasswordSQL,
  getUserByUIDSQL,
  getPlantsByUserIdSQL,
  getPlantByDeviceIdSQL,
  getPlantByIdSQL,
  getDataByRowIdSQL,
};
