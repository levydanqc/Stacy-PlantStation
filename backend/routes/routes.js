const weatherRoutes = require('./weather.js');
const usersRoutes = require('./users.js');
const plantsRoutes = require('./plants.js');
const sessionsRoutes = require('./sessions.js');

const appRouter = (app, clients) => {
  weatherRoutes(app, clients);
  usersRoutes(app);
  plantsRoutes(app);
  sessionsRoutes(app);
};

module.exports = appRouter;
