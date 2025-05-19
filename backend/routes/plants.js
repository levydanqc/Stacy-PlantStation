const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');
const Plant = require('../models/Plant');

const plantsRoutes = (app) => {
  app.use('/plants', authenticateToken);

  app.post('/plants', (req, res) => {
    const rawDataFromDevice = req.body;
    const device_id = req.headers['device-id'];
    const user_id = req.headers['user-id'];

    const plantObject = Plant.fromObject({
      device_id: device_id,
      plant_name: rawDataFromDevice.plant_name,
    });

    console.log('Received data : ', JSON.stringify(plantObject));

    database
      .createPlant(plantObject, user_id)
      .then(() => {
        console.log('Created plant');

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
  });
};

module.exports = plantsRoutes;
