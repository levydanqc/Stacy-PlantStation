const database = require('../utilities/database');
const verifyToken = require('../middleware/verifyToken.js');
const Plant = require('../models/Plant');

const plantsRoutes = (app) => {
  app.use('/plants', verifyToken);

  app.post('/plants', (req, res) => {
    const { plant_name } = req.body;
    const device_id = req.headers['device-id'];
    const uid = req.headers['uid'];

    if (!uid || uid.length === 0) {
      console.warn('Unauthorized: No User-ID provided');
      return res
        .status(401)
        .send({ message: 'Unauthorized: No User-ID provided.' });
    }

    try {
      const plantObject = Plant.fromObject({
        device_id: device_id,
        plant_name: plant_name,
      });

      console.log('Received data : ', JSON.stringify(plantObject));

      database
        .createPlant(plantObject, uid)
        .then((plant_id) => {
          console.log('Created plant with ID:', plant_id);

          return res
            .status(201)
            .send({
              message: 'Plant created successfully',
              plant_id: plant_id,
            });
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
      console.error('Error creating Plant object:', error);
      return res.status(400).send({
        error: error.message || 'Invalid plant data provided.',
      });
    }
  });
};

module.exports = plantsRoutes;
