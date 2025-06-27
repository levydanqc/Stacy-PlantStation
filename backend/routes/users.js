const crypto = require('crypto');

const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');

const User = require('../models/User');

const usersRoutes = (app) => {
  app.use('/users', authenticateToken);
  app.use('/users/:uid/plants', authenticateToken);

  app.post('/users', (req, res) => {
    const rawDataFromDevice = req.body;
    const uid = crypto.randomBytes(8).toString('hex');
    rawDataFromDevice.uid = uid;

    const userObject = User.fromObject(rawDataFromDevice);

    console.log('Received data : ', JSON.stringify(userObject));

    database
      .createUser(userObject)
      .then((uid) => {
        console.log('Created user');

        return res.status(201).send({ uid: uid });
      })
      .catch((err) => {
        console.error('Error creating user:', err.message);
        return res.status(500).send({ message: 'Internal Server Error' });
      });
  });

  app.get('/users/:uid/plants', (req, res) => {
    const uid = req.params.uid;

    database
      .getPlantsDataByUserUID(uid)
      .then((plants_data) => {
        console.log('Retrieved plants for user:', uid);
        return res.status(200).send({ plants: plants_data });
      })
      .catch((err) => {
        console.error('Error retrieving plants:', err.message);
        return res.status(500).send({ message: 'Internal Server Error' });
      });
  });
};

module.exports = usersRoutes;
