const SensorData = require('../models/sensorData');
const database = require('../utilities/database');
const broadcast = require('../utilities/broadcast');
const authenticateToken = require('../middleware/authenticateToken.js');

const weatherRoutes = (app, clients) => {
  app.use('/weather', authenticateToken);

  app.post('/weather', (req, res) => {
    const rawDataFromDevice = req.body;
    const device_id = req.headers['device-id'];
    const user_id = req.headers['user-id'];

    console.log('Received data from device: ', device_id);
    console.log('Received data from user: ', user_id);

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

      const sensorData = sensorDataObject.toObject();

      database
        .storeSensorData(sensorData, device_id, user_id)
        .then(() => {
          broadcast(
            clients,
            JSON.stringify({ type: 'update', ...sensorData }),
            user_id
          );
          return res
            .status(200)
            .send({ message: 'Data stored and broadcast successfully' });
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
};

module.exports = weatherRoutes;
