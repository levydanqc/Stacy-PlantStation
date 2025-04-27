// import other routes
const weatherRoutes = require('./weather.js');

const appRouter = (app, fs) => {
  app.get('/', (req, res) => {
    res.send('welcome to the development api-server');
  });

  // other routes
  weatherRoutes(app, fs);
};

module.exports = appRouter;
