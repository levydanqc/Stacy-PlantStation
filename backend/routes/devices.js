const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');

const devicesRoutes = (app) => {
  app.use('/devices', authenticateToken);

  app.post('/devices', (req, res) => {
    const device_id = req.headers['device-id'];
    const user_id = req.headers['user-id'];

    console.log('Received device ID : ', device_id);
    console.log('Received user ID : ', user_id);

    database
      .createDevice(device_id, user_id)
      .then(() => {
        console.log('Created Device');

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

module.exports = devicesRoutes;
