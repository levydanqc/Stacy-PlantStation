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

    console.log('Received data from device: ', device_id);

    if (!device_id || device_id.length === 0) {
      console.warn('Unauthorized: No Device-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No Device-ID provided.' });
    }

    try {
      const sensorDataObject = SensorData.fromObject(rawDataFromDevice);

      // Get a plain object for database and broadcasting
      const dataToStoreAndBroadcast = sensorDataObject.toObject();

      console.log(
        `Data received from device_id "${device_id}":`,
        JSON.stringify(dataToStoreAndBroadcast)
      );

      database.getClientIdByDeviceId(device_id).then((client_id) => {
        if (!client_id) {
          console.warn(
            `No client_id found for device_id "${device_id}". Data will not be broadcasted.`
          );
          return res.status(404).send({
            message: `No client_id found for device_id "${device_id}".`,
          });
        }
        broadcast(
          clients,
          JSON.stringify({ type: 'update', ...dataToStoreAndBroadcast }),
          client_id
        );

        res
          .status(200)
          .send({ message: 'Data received and stored successfully' });
      });

      // Store the data in the database
      // database
      //   .saveDataToDatabase(dataToStoreAndBroadcast, device_id)
      //   .then(() => {
      //     console.log(
      //       `Data for device_id "${device_id}" saved to database successfully.`
      //     );
      //     // Broadcast the new data to all connected WebSocket clients
      //     broadcast(
      //       JSON.stringify({ type: 'update', ...dataToStoreAndBroadcast })
      //     );
      //     res
      //       .status(200)
      //       .send({ message: 'Data received and stored successfully' });
      //   })
      //   .catch((error) => {
      //     console.error(
      //       `Error saving data to database for device_id "${device_id}":`,
      //       error
      //     );
      //     res.status(500).send({
      //       message: 'Error saving data to database. Check server logs.',
      //     });
      //   });
    } catch (error) {
      // This catch block will handle errors from SensorData.fromObject (validation errors)
      // or any other synchronous errors in the try block.
      console.error('Error processing incoming sensor data:', error.message);
      return res
        .status(400)
        .send({ message: `Invalid sensor data: ${error.message}` });
    }
  });

  // --- Example GET Endpoints (no auth added here, but you could add it) ---
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
