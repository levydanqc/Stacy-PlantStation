const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const {
  createUsersTable,
  createDevicesTable,
  createPlantsTable,
  createSensorDataTable,
  createIndex,
} = require('../sql/createTable.js');

const dbPath = path.resolve(__dirname, '../plant_station.db');

let db;

function connectDatabase() {
  return new Promise((resolve, reject) => {
    db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Error connecting to database:', err.message);
        reject(err);
      } else {
        db.get(
          "SELECT name FROM sqlite_master WHERE type='table' LIMIT 1",
          (err, row) => {
            if (err) {
              console.error('Error checking for existing tables:', err.message);
              reject(err);
              return;
            }
            if (!row) {
              initializeDatabase().catch((error) => {
                console.error('Error initializing database:', error);
                reject(error);
              });
              console.log('Connected to a new SQLite database.');
            } else {
              console.log('Connected to an existing SQLite database.');
            }
            resolve(db);
          }
        );
      }
    });
  });
}

async function initializeDatabase() {
  try {
    await new Promise((resolve, reject) =>
      db.exec(createUsersTable, (err) => (err ? reject(err) : resolve()))
    );
    await new Promise((resolve, reject) =>
      db.exec(createDevicesTable, (err) => (err ? reject(err) : resolve()))
    );
    await new Promise((resolve, reject) =>
      db.exec(createPlantsTable, (err) => (err ? reject(err) : resolve()))
    );
    await new Promise((resolve, reject) =>
      db.exec(createSensorDataTable, (err) => (err ? reject(err) : resolve()))
    );
    await new Promise((resolve, reject) =>
      db.exec(createIndex, (err) => (err ? reject(err) : resolve()))
    );
    console.log('Database initialized successfully.');
  } catch (error) {
    console.error('Failed to initialize database:', error);
  }
}

/**
 * Saves weather data to the database.
 * @param {object} weatherData - The weather data object (SensorData)
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<void>} A promise that resolves when data is saved, or rejects on error.
 */
function saveDataToDatabase(weatherData, device_id) {
  return new Promise((resolve, reject) => {
    const {
      client_id,
      temperature,
      humidity,
      moisture,
      pressure,
      hic,
      batteryVoltage,
      batteryPercentage,
    } = weatherData;

    if (!device_id) {
      console.error('Error: device_id is missing in weatherData');
      return reject(new Error('device_id is required'));
    }

    const insertSql = `
      INSERT INTO weather_data (client_id, temperature, humidity, pressure)
      VALUES (?, ?, ?, ?);
    `;

    // The timestamp will be added automatically by the database (DEFAULT CURRENT_TIMESTAMP)
    db.run(
      insertSql,
      [client_id, temperature, humidity, pressure],
      function (err) {
        // Use function keyword to access `this.lastID`
        if (err) {
          console.error('Error inserting data into database:', err.message);
          reject(err);
        } else {
          console.log(
            `A row has been inserted with rowid ${this.lastID} for client_id: ${client_id}`
          );
          resolve();
        }
      }
    );
  });
}

/**
 * Retrieves all weather data for a specific client.
 * @param {string} clientId - The ID of the client.
 * @returns {Promise<Array<object>>} A promise that resolves with an array of data rows.
 */
function getDataByClient(clientId) {
  return new Promise((resolve, reject) => {
    const selectSql = `SELECT * FROM weather_data WHERE client_id = ? ORDER BY timestamp DESC;`;
    db.all(selectSql, [clientId], (err, rows) => {
      if (err) {
        console.error('Error fetching data by client_id:', err.message);
        reject(err);
      } else {
        resolve(rows);
      }
    });
  });
}

/**
 * Retrieves the client ID associated with a given device ID.
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<string>} A promise that resolves with the client ID.
 */
function getClientIdByDeviceId(device_id) {
  return new Promise((resolve, reject) => {
    const selectSql = `
      SELECT client_id FROM devices WHERE device_id = ?;
    `;
    db.get(selectSql, [device_id], (err, row) => {
      if (err) {
        console.error('Error fetching client_id by device_id:', err.message);
        reject(err);
      } else if (row) {
        resolve(row.client_id);
      } else {
        resolve(null); // No matching client_id found
      }
    });
  });
}

/**
 * Retrieves all weather data.
 * @returns {Promise<Array<object>>} A promise that resolves with an array of all data rows.
 */
function getAllData() {
  return new Promise((resolve, reject) => {
    const selectSql = `SELECT * FROM weather_data ORDER BY timestamp DESC;`;
    db.all(selectSql, [], (err, rows) => {
      if (err) {
        console.error('Error fetching all data:', err.message);
        reject(err);
      } else {
        resolve(rows);
      }
    });
  });
}

// Close the database connection when the application exits
// This is important for graceful shutdowns
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      return console.error('Error closing database:', err.message);
    }
    console.log('Database connection closed.');
    process.exit(0);
  });
});

module.exports = {
  connectDatabase,
  saveDataToDatabase,
  getDataByClient,
  getAllData,
  getClientIdByDeviceId,
};
