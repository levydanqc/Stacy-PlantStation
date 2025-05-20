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
 * Retrieves the plant ID associated with a given user ID and device ID.
 * @param {string} user_id - The ID of the user.
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<string>} A promise that resolves with the plant ID.
 */
function getPlantIdByUserIdAndDeviceId(user_id, device_id) {
  return new Promise((resolve, reject) => {
    db.get(
      sql.getPlantIdFromUserIdAndDeviceIdSQL,
      [user_id, device_id],
      (err, row) => {
        if (err) {
          console.error('Error fetching plant_id:', err.message);
          reject(err);
        } else if (row) {
          resolve(row.plant_id);
        } else {
          resolve(null);
        }
      }
    );
  });
}

/**
 * Creates a new user in the database.
 * @param {User} user - The user object containing username, email, and password_hash.
 * @return {Promise<void>} A promise that resolves when the user is created, or rejects on error.
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

/**
 * Creates a new plant in the database.
 * @param {Object} plant - The plant object containing device_id and plant_name.
 * @param {string} user_id - The ID of the user.
 * @return {Promise<number>} A promise that resolves with the plant ID, or rejects on error.
 */
function createPlant(plant, user_id) {
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
          resolve(this.lastID);
        }
      }
    );
  });
}

function getDataByUserId(user_id) {
  return new Promise((resolve, reject) => {
    db.all(sql.getPlantIdFromUserIdSQL, [user_id], (err, rows) => {
      if (err) {
        console.error('Error fetching plant IDs:', err.message);
        reject(err);
      } else {
        const plantIds = rows.map((row) => row.plant_id);
        console.log('Plant IDs:', plantIds);

        const promises = plantIds.map((plantId) => getDataByPlantId(plantId));

        Promise.all(promises)
          .then((results) => {
            const allData = results.flat();
            resolve(allData);
          })
          .catch((error) => {
            console.error('Error fetching data by plant ID:', error);
            reject(error);
          });
      }
    });
  });
}

/**
 * Retrieves sensor data for a specific plant ID.
 * @param {number} plant_id - The ID of the plant.
 * @return {Promise<Array>} A promise that resolves with an array of sensor data.
 */
function getDataByPlantId(plant_id) {
  return new Promise((resolve, reject) => {
    db.all(sql.getDataByPlantIdSQL, [plant_id], (err, rows) => {
      if (err) {
        console.error('Error fetching sensor data:', err.message);
        reject(err);
      } else {
        const sensorData = rows.map((row) => ({
          temperature: row.temperature,
          humidity: row.humidity,
          moisture: row.moisture,
          pressure: row.pressure,
          hic: row.hic,
          batteryVoltage: row.batteryVoltage,
          batteryPercentage: row.batteryPercentage,
        }));
        resolve(sensorData);
      }
    });
  });
}

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
  getDataByUserId,
  storeSensorData,
  createUser,
  createPlant,
};
