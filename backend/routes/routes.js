const weatherRoutes = require('./weather.js');
const usersRoutes = require('./users.js');
const plantsRoutes = require('./plants.js')
const devicesRoutes = require('./devices.js')

const appRouter = (app, clients) => {
  weatherRoutes(app, clients);
  usersRoutes(app);
  plantsRoutes(app);
  devicesRoutes(app);
};

module.exports = appRouter;
