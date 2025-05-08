const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const User = require('../models/User');
const sql = require('../sql/sql');
const sqlInitialize = require('../sql/createTable.js');

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
      db.exec(sqlInitialize.createUsersTable, (err) =>
        err ? reject(err) : resolve()
      )
    );
    await new Promise((resolve, reject) =>
      db.exec(sqlInitialize.createPlantsTable, (err) =>
        err ? reject(err) : resolve()
      )
    );
    await new Promise((resolve, reject) =>
      db.exec(sqlInitialize.createDevicesTable, (err) =>
        err ? reject(err) : resolve()
      )
    );
    await new Promise((resolve, reject) =>
      db.exec(sqlInitialize.createSensorDataTable, (err) =>
        err ? reject(err) : resolve()
      )
    );
    await new Promise((resolve, reject) =>
      db.exec(sqlInitialize.createIndex, (err) =>
        err ? reject(err) : resolve()
      )
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
function saveDataToDatabase(weatherData, device_id, user_id) {
  // TODO : Revise logic and data
  return new Promise((resolve, reject) => {
    const {
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

    // The timestamp will be added automatically by the database (DEFAULT CURRENT_TIMESTAMP)
    db.run(
      sql.addSensorDataSQL,
      [
        temperature,
        humidity,
        moisture,
        pressure,
        hic,
        batteryVoltage,
        batteryPercentage,
      ],
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
  // TODO : Revise logic and data
  return new Promise((resolve, reject) => {
    db.all(getAllDataFromClientIdSQL, [clientId], (err, rows) => {
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
  // TODO : Revise logic and data
  return new Promise((resolve, reject) => {
    db.get(selectIdFromDeviceID, [device_id], (err, row) => {
      if (err) {
        console.error('Error fetching client_id by device_id:', err.message);
        reject(err);
      } else if (row) {
        resolve(row.client_id);
      } else {
        resolve(null);
      }
    });
  });
}

function getPlantIdByUserIdAndDeviceId(user_id, device_id) {
  // TODO : Revise logic and data
  return new Promise((resolve, reject) => {
    db.get(getPlantIdSQL, [user_id, device_id], (err, row) => {
      if (err) {
        console.error('Error fetching client_id by device_id:', err.message);
        reject(err);
      } else if (row) {
        resolve(row.client_id);
      } else {
        resolve(null);
      }
    });
  });
}

/**
 * Saves a new User in the database.
 * @param {User} user - The User data object.
 * @returns {Promise<string>} A promise that resolves with the user ID.
 */
function createUser(user) {
  // TODO : it needs to return the user_id for the client
  return new Promise((resolve, reject) => {
    db.run(
      sql.addUserSQL,
      [user.username, user.email, user.password_hash],
      function (err) {
        if (err) {
          console.error('Error inserting data into database:', err.message);
          reject(err);
        } else {
          console.log('A row in user table has been inserted');
          resolve();
        }
      }
    );
  });
}

function createDevice(device_id, user_id) {
  return new Promise((resolve, reject) => {
    db.run(sql.addDeviceSQL, [device_id, user_id], function (err) {
      if (err) {
        console.error('Error inserting data into database:', err.message);
        reject(err);
      } else {
        console.log('A row in user table has been inserted');
        resolve();
      }
    });
  });
}

/**
 * Saves a new Plant in the database.
 * @param {Plant} plant - The Plant data object.
 * @returns {Promise<string>} A promise that resolves with plant ID
 */
function createPlant(plant) {
  // TODO : it needs to return the plant_id for the client
  return new Promise((resolve, reject) => {
    db.run(
      sql.addPlantSQL,
      [plant.device_id, plant.plant_name],
      function (err) {
        if (err) {
          console.error('Error inserting data into database:', err.message);
          reject(err);
        } else {
          console.log('A row in plant table has been inserted');
          resolve();
        }
      }
    );
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
  getClientIdByDeviceId,
  createUser,
  createDevice,
};
