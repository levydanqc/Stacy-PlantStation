const createUsersTable = `
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);`;

const createPlantsTable = `
CREATE TABLE IF NOT EXISTS plants (
    plant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    device_id TEXT NOT NULL,
    plant_name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);`;

const createSensorDataTable = `
CREATE TABLE IF NOT EXISTS sensor_data (
    data_id INTEGER PRIMARY KEY AUTOINCREMENT,
    plant_id INTEGER NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    temperature REAL,
    humidity REAL,
    moisture REAL,
    hic REAL,
    batteryVoltage REAL,
    batteryPercentage REAL,
    FOREIGN KEY (plant_id) REFERENCES plants(plant_id)
);`;

const createIndex = `
CREATE INDEX IF NOT EXISTS idx_plant_id_timestamp ON sensor_data (plant_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_user_id_plant_id ON plants (user_id, plant_id);
`;

module.exports = {
  createUsersTable,
  createPlantsTable,
  createSensorDataTable,
  createIndex,
};
