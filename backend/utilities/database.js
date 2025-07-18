const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const sql = require('../sql/sql');
const sqlInitialize = require('../sql/createTable.js');

const User = require('../models/User');
const PlantData = require('../models/PlantData.js');

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
        return reject(err);
      } else {
        db.get(sql.getTablesSQL, (err, row) => {
          if (err) {
            console.error('Error checking for existing tables:', err.message);
            return reject(err);
          }
          if (!row) {
            initializeDatabase().catch((error) => {
              console.error('Error initializing database:', error);
              return reject(error);
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
          sqlInitialize.createPlantDataTable +
          sqlInitialize.createIndex,
        (err) => {
          if (err) {
            console.error('Error initializing database:', err.message);
            return reject(err);
          }
          resolve();
        }
      )
    );
    console.log('Database initialized successfully.');
  } catch (error) {
    console.error('Failed to initialize database:', error);
  }
}

/**
 * Saves weather data to the database.
 * @param {PlantData} weatherData - The weather data object (PlantData)
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<void>} A promise that resolves when data is saved, or rejects on error.
 */
function storePlantData(weatherData, device_id, uid) {
  return new Promise((resolve, reject) => {
    const {
      temperature,
      humidity,
      moisture,
      hic,
      batteryVoltage,
      batteryPercentage,
    } = weatherData;

    if (!device_id) {
      console.error('Error: device_id is missing in weatherData');
      return reject(new Error('device_id is required'));
    }
    if (!uid) {
      console.error('Error: uid is missing in weatherData');
      return reject(new Error('uid is required'));
    }

    getPlantByUIDAndDeviceId(uid, device_id)
      .then((plant) => {
        if (!plant) {
          console.error(
            `Error: No plant found for device_id "${device_id}" and uid "${uid}"`
          );
          return reject(new Error('plant is required'));
        }
        return new Promise((resolveInsertAndFetch, rejectInsertAndFetch) => {
          db.run(
            sql.addPlantDataSQL,
            [
              plant.plant_id,
              temperature,
              humidity,
              moisture,
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
                rejectInsertAndFetch(err);
              } else {
                console.log(
                  `A row has been inserted with rowid ${this.lastID} for user "${uid}"`
                );
                db.get(sql.getDataByRowIdSQL, [this.lastID], (err, row) => {
                  if (err) {
                    console.error(
                      'Error fetching plant data by ID:',
                      err.message
                    );
                    rejectInsertAndFetch(err);
                  } else if (row) {
                    resolveInsertAndFetch({
                      plant_name: plant.plant_name,
                      plant_data: new PlantData(
                        row.temperature,
                        row.humidity,
                        row.moisture,
                        row.hic,
                        row.batteryVoltage,
                        row.batteryPercentage
                      ).toObject([row.timestamp]),
                    });
                  } else {
                    rejectInsertAndFetch(new Error('Plant data not found'));
                  }
                });
              }
            }
          );
        });
      })
      .then((insertedRowData) => {
        resolve(insertedRowData);
      })
      .catch((error) => {
        console.error('Error in storePlantData execution chain:', error);
        reject(error);
      });
  });
}

/**
 * Retrieves the plant ID associated with a given user ID and device ID.
 * @param {string} uid - The unique identifier of the user.
 * @param {string} device_id - The ID of the device (MAC address).
 * @returns {Promise<string>} A promise that resolves with the plant ID.
 */
function getPlantByUIDAndDeviceId(uid, device_id) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByUIDSQL, [uid], (err, row) => {
      if (err) {
        console.error('Error fetching user by UID:', err.message);
        reject(err);
      } else if (row) {
        db.get(
          sql.getPlantFromUserIdAndDeviceIdSQL,
          [row.user_id, device_id],
          (err, row) => {
            if (err) {
              console.error('Error fetching plant_id:', err.message);
              reject(err);
            } else if (row) {
              resolve(row);
            } else {
              resolve(null);
            }
          }
        );
      } else {
        resolve(null);
      }
    });
  });
}

/**
 * Creates a new user in the database.
 * @param {User} user - The user object containing username, email, and password.
 * @return {Promise<string>} A promise that resolves with the user's uid, or rejects on error.
 */
function createUser(user) {
  return new Promise((resolve, reject) => {
    db.run(
      sql.addUserSQL,
      [user.username, user.uid, user.email, user.password],
      function (err) {
        if (err) {
          console.error('Error inserting data into database:', err.message);
          reject(err);
        } else {
          console.log('A row in user table has been inserted');
          resolve(user.uid);
        }
      }
    );
  });
}

/**
 * Creates a new plant in the database.
 * @param {Object} plant - The plant object containing device_id and plant_name.
 * @param {string} uid - The unique identifier of the user.
 * @return {Promise<number>} A promise that resolves with the plant ID, or rejects on error.
 */
function createPlant(plant, uid) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByUIDSQL, [uid], (err, row) => {
      if (err) {
        console.error('Error fetching user by UID:', err.message);
        return reject(err);
      }
      if (!row) {
        console.error(`No user found with UID: ${uid}`);
        return reject(new Error('User not found'));
      }
      db.run(
        sql.addPlantSQL,
        [row.user_id, plant.device_id, plant.plant_name],
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
  });
}

/**
 * Retrieves all sensor data for a user by their UID.
 * @param {string} uid - The unique identifier of the user.
 * @return {Promise<Array>} A promise that resolves with an array of sensor data objects.
 */
function getDataByUID(uid) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByUIDSQL, [uid], (err, row) => {
      if (err) {
        console.error('Error fetching user by UID:', err.message);
        reject(err);
      }
      if (!row) {
        console.error(`No user found with UID: ${uid}`);
        reject(new Error('User not found'));
      }

      db.all(sql.getPlantIdFromUserIdSQL, [row.user_id], (err, rows) => {
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
        const PlantData = rows.map((row) => ({
          temperature: row.temperature,
          humidity: row.humidity,
          moisture: row.moisture,
          hic: row.hic,
          batteryVoltage: row.batteryVoltage,
          batteryPercentage: row.batteryPercentage,
        }));
        resolve(PlantData);
      }
    });
  });
}

/**
 * Retrieves a user by their email address.
 * @param {string} email - The email address of the user.
 * @return {Promise<User>} A promise that resolves with the user object, or null if not found.
 */
function getUserByEmail(email) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByEmailSQL, [email], (err, row) => {
      if (err) {
        console.error('Error fetching user by email:', err.message);
        reject(err);
      } else if (row) {
        resolve(row);
      } else {
        resolve(null);
      }
    });
  });
}
/**
 * Retrieves all plants and their data for a user by their UID.
 * @param {string} uid - The unique identifier of the user.
 * @return {Promise<Array>} A promise that resolves with an array of plant data objects.
 */
function getPlantsDataByUserUID(uid) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByUIDSQL, [uid], (err, row) => {
      if (err) {
        console.error('Error fetching user by UID:', err.message);
        return reject(err);
      }
      if (!row) {
        console.error(`No user found with UID: ${uid}`);
        return reject(new Error('User not found'));
      }

      console.log(`Fetching plants for user with ID: ${row}`);

      db.all(sql.getPlantsByUserIdSQL, [row.user_id], (err, rows) => {
        if (err) {
          console.error('Error fetching plants:', err.message);
          return reject(err);
        }
        const promises = rows.map((plant) => {
          return new Promise((resolve, reject) => {
            db.all(
              sql.getDataByPlantIdSQL,
              [plant.plant_id],
              (err, dataRows) => {
                if (err) {
                  console.error('Error fetching plant data:', err.message);
                  return reject(err);
                } else {
                  const plantData = dataRows.map((dataRow) => ({
                    timestamp: dataRow.timestamp,
                    temperature: dataRow.temperature,
                    humidity: dataRow.humidity,
                    moisture: dataRow.moisture,
                    hic: dataRow.hic,
                    batteryVoltage: dataRow.batteryVoltage,
                    batteryPercentage: dataRow.batteryPercentage,
                  }));
                  resolve({
                    plant_name: plant.plant_name,
                    plant_data: plantData,
                  });
                }
              }
            );
          });
        });
        Promise.all(promises)
          .then((plantDataArray) => {
            resolve(plantDataArray);
          })
          .catch((error) => {
            return reject(error);
          });
      });
    });
  });
}

/**
 * Retrieves a plant by its device ID.
 * @param {string} device_id - The ID of the device (MAC address).
 * @return {Promise<Object|null>} A promise that resolves with the plant object if found, or null if not found.
 */
function getPlantByDeviceID(device_id) {
  return new Promise((resolve, reject) => {
    db.get(sql.getPlantByDeviceIdSQL, [device_id], (err, row) => {
      if (err) {
        console.error('Error fetching plant by device ID:', err.message);
        reject(err);
      } else if (row) {
        resolve(row);
      } else {
        resolve(null);
      }
    });
  });
}

/**
 * Checks if an email is unique in the database.
 * @param {string} email - The email address to check.
 * @return {Promise<boolean>} A promise that resolves with true if the email is unique, false otherwise.
 */
function isUniqueEmail(email) {
  return new Promise((resolve, reject) => {
    db.get(sql.getUserByEmailSQL, [email], (err, row) => {
      if (err) {
        console.error('Error checking unique email:', err.message);
        reject(err);
      } else {
        resolve(!row); // If row is null, email is unique
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
  getDataByUID,
  storePlantData,
  createUser,
  createPlant,
  getUserByEmail,
  getPlantsDataByUserUID,
  getPlantByDeviceID,
  isUniqueEmail,
};
