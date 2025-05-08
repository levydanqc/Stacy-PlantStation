const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');
const User = require('../models/User');

const usersRoutes = (app) => {
  app.use('/users', authenticateToken);

  app.post('/users', (req, res) => {
    const rawDataFromDevice = req.body;

    const userObject = User.fromObject(rawDataFromDevice);

    console.log('Received data : ', JSON.stringify(userObject));

    database.createUser(userObject).then(() => {
      console.log('Created user');

      return res
        .status(200)
        .send({ message: 'Data received and stored successfully' });
    });
  });

  app.get('/users', (req, res) => {
    const sql = 'SELECT * FROM users';
    database.all(sql, [], (err, rows) => {
      if (err) {
        console.error('Error fetching users:', err.message);
        return res.status(500).send({ message: 'Internal Server Error' });
      }
      res.status(200).json(rows);
    });
  });
};

module.exports = usersRoutes;
