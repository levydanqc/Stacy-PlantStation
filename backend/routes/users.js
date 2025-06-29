const database = require('../utilities/database');
const verifyToken = require('../middleware/verifyToken.js');

const usersRoutes = (app) => {
  app.use('/users/:uid/plants', verifyToken);

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
