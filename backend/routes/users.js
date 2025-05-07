const database = require('../utilities/database');

const usersRoutes = (app, clients) => {
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
