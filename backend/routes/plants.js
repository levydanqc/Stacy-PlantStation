const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');
const Plant = require('../models/Plant');

const plantsRoutes = (app) => {
  app.use('/plants', authenticateToken);

  app.post('/plants', (req, res) => {
    const rawDataFromDevice = req.body;
    const device_id = req.headers['device-id'];
    const uid = req.headers['uid'];

    const plantObject = Plant.fromObject({
      device_id: device_id,
      plant_name: rawDataFromDevice.plant_name,
    });

    console.log('Received data : ', JSON.stringify(plantObject));

    database
      .createPlant(plantObject, uid)
      .then((plant_id) => {
        console.log('Created plant with ID:', plant_id);

        return res
          .status(200)
          .send({ message: 'Plant created successfully', plant_id: plant_id });
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
