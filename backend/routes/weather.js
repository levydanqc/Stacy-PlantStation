const PlantData = require('../models/PlantData');
const database = require('../utilities/database');
const broadcast = require('../utilities/broadcast');
const verifyToken = require('../middleware/verifyToken.js');

const weatherRoutes = (app, clients) => {
  app.use('/weather', verifyToken);

  app.post('/weather', (req, res) => {
    const rawDataFromDevice = req.body;
    const device_id = req.headers['device-id'];
    const uid = req.headers['uid'];

    console.log('Received data from device: ', device_id);
    console.log('Received data from user: ', uid);

    if (
      rawDataFromDevice.temperature == 0 ||
      rawDataFromDevice.humidity == 0 ||
      rawDataFromDevice.moisture == 0 ||
      rawDataFromDevice.hic == 0 ||
      rawDataFromDevice.batteryVoltage == 0 ||
      rawDataFromDevice.batteryPercentage == 0
    ) {
      console.warn('Unauthorized: Invalid sensor data received');
      return res
        .status(400)
        .send({ message: 'Unauthorized: Invalid sensor data received.' });
    }

    if (!device_id || device_id.length === 0) {
      console.warn('Unauthorized: No Device-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No Device-ID provided.' });
    }
    if (!uid || uid.length === 0) {
      console.warn('Unauthorized: No User-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No User-ID provided.' });
    }

    try {
      const plantDataObject = PlantData.fromObject(rawDataFromDevice);

      database
        .storePlantData(plantDataObject, device_id, uid)
        .then((plant) => {
          console.log(`Data stored successfully: `, plant);
          broadcast(
            clients,
            JSON.stringify({
              type: 'update',
              plants: plant,
            }),
            uid
          );
          return res
            .status(201)
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
