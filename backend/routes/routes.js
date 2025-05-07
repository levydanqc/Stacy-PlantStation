const weatherRoutes = require('./weather.js');
const usersRoutes = require('./users.js');

const appRouter = (app, clients) => {
  app.get('/', (req, res) => {
    res.send('welcome to the development api-server');
  });

  // other routes
  weatherRoutes(app, clients);
  usersRoutes(app, clients);
};

module.exports = appRouter;
