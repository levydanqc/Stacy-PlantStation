const SensorData = require('../models/sensorData');
const database = require('../utilities/database');
const broadcast = require('../utilities/broadcast');
const authenticateToken = require('../middleware/authenticateToken.js');

const weatherRoutes = (app, clients) => {
  app.use('/weather', authenticateToken);

  // HTTP Endpoint for ESP32 to send data
  app.post('/weather', (req, res) => {
    const rawDataFromDevice = req.body;
    const device_id = req.headers['device-id'];
    const user_id = req.headers['user-id'];

    console.log('Received data from device: ', device_id);

    if (!device_id || device_id.length === 0) {
      console.warn('Unauthorized: No Device-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No Device-ID provided.' });
    }
    if (!user_id || user_id.length === 0) {
      console.warn('Unauthorized: No User-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No User-ID provided.' });
    }

    try {
      const sensorDataObject = SensorData.fromObject(rawDataFromDevice);

      // Get a plain object for database and broadcasting
      const dataToStoreAndBroadcast = sensorDataObject.toObject();

      console.log(
        `Data received from device_id "${device_id}":`,
        JSON.stringify(dataToStoreAndBroadcast)
      );

      database
        .saveDataToDatabase(dataToStoreAndBroadcast, device_id, user_id)
        .then(() => {
          console.log(
            `Data for device_id "${device_id}" saved to database successfully.`
          );
          // Broadcast the new data to all connected WebSocket clients
          broadcast(
            clients,
            JSON.stringify({ type: 'update', ...dataToStoreAndBroadcast }),
            user_id
          );
          return res
            .status(200)
            .send({ message: 'Data received and stored successfully' });
        })
        .catch((error) => {
          console.error(
            `Error saving data to database for device_id "${device_id}":`,
            error
          );
          return res.status(500).send({
            message: 'Error saving data to database. Check server logs.',
          });
        });
    } catch (error) {
      console.error('Error processing incoming sensor data:', error.message);
      return res
        .status(400)
        .send({ message: `Invalid sensor data: ${error.message}` });
    }
  });

  app.get('/weather/:client_id', (req, res) => {
    const { client_id } = req.params;

    database
      .getDataByClient(client_id)
      .then((data) => {
        if (data && data.length > 0) {
          res.status(200).json(data);
        } else {
          res
            .status(404)
            .json({ message: `No data found for client_id: ${client_id}` });
        }
      })
      .catch((err) => {
        console.error(`Error fetching data for client_id ${client_id}:`, err);
        res.status(500).json({ message: 'Error fetching data from database' });
      });
  });
};

module.exports = weatherRoutes;
