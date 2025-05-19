const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const sql = require('../sql/sql');
const sqlInitialize = require('../sql/createTable.js');

const User = require('../models/User');
const SensorData = require('../models/sensorData.js');

const dbPath = path.resolve(__dirname, '../plant_station.db');

let db;

/**
 * Connects to the SQLite database.
 * If the database file does not exist, it will be created.
 * @returns {Promise<sqlite3.Database>} A promise that resolves with the database connection.
 */
function connectDatabase() {
  return new Promise((resolve, reject) => {
    db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Error connecting to database:', err.message);
        reject(err);
      } else {
        db.get(sql.getTablesSQL, (err, row) => {
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
        });
      }
    });
  });
}

/**
 * Initializes the database by creating necessary tables.
 * This function is called when the database is first created.
 * @returns {Promise<void>} A promise that resolves when the database is initialized.
 */
async function initializeDatabase() {
  try {
    await new Promise((resolve, reject) =>
      db.exec(
        sqlInitialize.createUsersTable +
          sqlInitialize.createPlantsTable +
          sqlInitialize.createSensorDataTable +
          sqlInitialize.createIndex,
        (err) => (err ? reject(err) : resolve())
      )
    );
    console.log('Database initialized successfully.');
  } catch (error) {
    console.error('Failed to initialize database:', error);
  }
}

/**
 * Saves weather data to the database.
 * @param {SensorData} weatherData - The weather data object (SensorData)
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<void>} A promise that resolves when data is saved, or rejects on error.
 */
function storeSensorData(weatherData, device_id, user_id) {
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
    if (!user_id) {
      console.error('Error: user_id is missing in weatherData');
      return reject(new Error('user_id is required'));
    }

    getPlantIdByUserIdAndDeviceId(user_id, device_id)
      .then((plant_id) => {
        if (!plant_id) {
          console.error(
            `Error: No plant_id found for device_id "${device_id}" and user_id "${user_id}"`
          );
          return reject(new Error('plant_id is required'));
        }

        console.log(
          `Obtained plant_id "${plant_id}" for device_id "${device_id}" and user_id "${user_id}"`
        );

        return new Promise((resolve, reject) => {
          db.run(
            sql.addSensorDataSQL,
            [
              plant_id,
              temperature,
              humidity,
              moisture,
              pressure,
              hic,
              batteryVoltage,
              batteryPercentage,
            ],
            function (err) {
              if (err) {
                console.error(
                  'Error inserting data into database:',
                  err.message
                );
                reject(err);
              } else {
                console.log(
                  `A row has been inserted with rowid ${this.lastID} for user_id: ${user_id}`
                );
                resolve();
              }
            }
          );
        });
      })
      .then(() => resolve())
      .catch((error) => {
        console.error('Error storing sensor data:', error);
        reject(error);
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
    db.get(sql.getPlantIdSQL, [user_id, device_id], (err, row) => {
      if (err) {
        console.error('Error fetching plant_id:', err.message);
        reject(err);
      } else if (row) {
        resolve(row.plant_id);
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

function createPlant(plant, user_id) {
  // TODO : it needs to return the plant_id for the client
  return new Promise((resolve, reject) => {
    db.run(
      sql.addPlantSQL,
      [user_id, plant.device_id, plant.plant_name],
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
  // getDataByClient,
  storeSensorData,
  getClientIdByDeviceId,
  createUser,
  createPlant,
};
